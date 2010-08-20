class Establishment < ActiveRecord::Base
  include SiretNumber
  
  has_permissions :as_business_object, :additional_class_methods => [ :hide ]
  
  has_address   :address, :one_or_many => :many
  has_contacts
  has_documents :photos
  has_number    :phone
  has_number    :fax
  
  belongs_to :customer
  belongs_to :establishment_type
  belongs_to :activity_sector_reference
  
  validates_presence_of :name, :address, :establishment_type_id
  validates_presence_of :establishment_type, :if => :establishment_type_id
  
  validates_uniqueness_of :siret_number, :allow_blank => true
  
  validates_associated :address
  
  # define if the object should be destroyed (after clicking on the remove button via the web site) # see the /customers/1/edit
  attr_accessor :should_destroy
  
  # the same as above but do not destroy the object. It's marked as hidden.
  attr_accessor :should_hide
  
  # define if the object should be updated 
  # should_update = 1 if the form is visible # see the /customers/1/edit
  # should_update = 0 if the form is hidden (after clicking on the cancel button via the web site) # see the /customers/1/edit
  attr_accessor :should_update
  
  has_attached_file :logo, 
                    :styles => { :thumb => "120x120" },
                    :path   => ":rails_root/assets/thirds/establishments/:id/logo/:style.:extension",
                    :url    => "/establishments/:id.:extension"
  
  has_search_index :only_attributes    => [ :name, :activated ],
                   :only_relationships => [ :customer, :activity_sector_reference, :establishment_type, :contacts, :address, :phone, :fax ],
                   :main_model         => true
  
  def errors_on_attributes_except_on_contacts?
    [:name, :address, :establishment_type, :siret_number, :address].each do |attribute|
      return true if errors.on(attribute)
    end
    false
  end
  
  def name_and_full_address
    @name_and_full_address ||= "#{name} (#{full_address})"
  end
  
  def can_be_hidden?
    !new_record?
  end
  
  def hide
    if can_be_hidden?
      self.hidden = true 
      self.save
    end
  end
  
  def should_hide?
    should_hide.to_i == 1
  end
  
  def should_destroy?
    should_destroy.to_i == 1
  end
  
  def should_update?
    should_update.to_i == 1 or contacts.select(&:should_save?).any?
  end
end
