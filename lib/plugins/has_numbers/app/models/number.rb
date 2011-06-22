class Number < ActiveRecord::Base
  belongs_to :indicative
  belongs_to :number_type
  belongs_to :has_number, :polymorphic => true
  
  validates_presence_of :has_number_type, :indicative_id
  validates_presence_of :indicative, :if => :indicative_id
  
  validates_length_of :number, :minimum => 7, :unless => :should_destroy? #TODO validate format of number according to the choosen indicative
  
  attr_accessor :should_destroy
  
  named_scope :visibles, :conditions => ['visible=?',true]
  
  VISIBLE_STATES = { "Privé" => false, "Public" => true }
  
  journalize :attributes => :number, :identifier_method => :formatted_with_indicative
  
  has_search_index  :only_attributes        => [ :number ],
                    :additional_attributes  => { :formatted_with_indicative => :string },
                    :only_relationships     => [ :number_type, :indicative ]
  
  def formatted
    ActiveSupport::Deprecation.warn("formatted is now deprecated, please use number or formatted_with_indicative instead", caller)
    number
  end
  
  # display formatted number when we want to display it after the indicative (with "(0)")
  # OPTIMIZE see the helper method in NumberHelper called 'to_phone' to format the phone number
  def formatted_with_indicative
    return unless number
    if number.starts_with?("0")
      "(#{number.mb_chars.first.to_s})#{number[1..number.size]}"
    else
      number
    end
  end
  
  # remove spaces
  def number=(number)
    super( number.is_a?(String) ? number.gsub(" ", "") : number )
  end
  
  def visible?
    self.visible
  end
  
  def should_destroy?
    should_destroy.to_i == 1 or ( number_type_id.blank? and number.blank? )
  end
end
