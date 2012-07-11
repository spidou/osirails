class Third < ActiveRecord::Base
  belongs_to :legal_form
  
  validates_presence_of :name
  
  validates_format_of :website, :with         => /^[a-z0-9]+([\-\.]{1}[a-z0-9]+)*\.[a-z]{2,5}(([0-9]{1,5})?\/.*)?$/ix,
                                :allow_blank  => true,
                                :message      => "L'adresse du site web ne respecte pas le format demandé"
  
  validates_uniqueness_of :name, :scope => :type
  
  RATINGS = { "0" => 0, "1" => 1, "2" => 2, "3" => 3, "4" => 4, "5" => 5 }
  
  def website_url
    @website_url ||= "http://#{website}" unless website.blank?
  end
  
  def collaboration_started_at
    self[:collaboration_started_at] || created_at
  end
end
