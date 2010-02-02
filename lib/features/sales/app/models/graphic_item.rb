class GraphicItem < ActiveRecord::Base
  # Relationships
  belongs_to :order
  belongs_to :graphic_unit_measure
  belongs_to :creator, :class_name => "Employee"
  
  has_many :graphic_item_versions, :dependent => :destroy

  # Validations
  validates_presence_of :name, :description, :order_id, :graphic_unit_measure_id, :creator_id
  validates_presence_of :order, :if => :order_id
  validates_presence_of :graphic_unit_measure, :if => :graphic_unit_measure_id
  validates_presence_of :creator, :if => :creator_id  
  validates_persistence_of :graphic_unit_measure_id, :reference, :order_id  
  validates_uniqueness_of :reference  
  validates_associated :graphic_item_versions
  validate :validates_simultaneous_actions
  validate :validates_new_graphic_item_version
  validate :validates_uniqueness_of_is_current_version_set_to_true 
  
  # Accessors
  attr_accessor :should_add_version
  attr_accessor :should_change_version
  attr_accessor :old_graphic_item_version
  attr_accessor :new_graphic_item_version
  
  # Callbacks
  before_create :generate_reference
  after_save :save_graphic_item_versions

  # Methods
  def validates_simultaneous_actions
    errors.add(:graphic_item_version,"ne peut être ajoutée en même temps qu'un changement de version") if (self.should_add_version and self.should_change_version)
  end
  
  def validates_new_graphic_item_version
    if self.new_graphic_item_version.nil?
      if self.should_add_version
        errors.add(:new_graphic_item_version,"est requis")
      elsif self.new_record?
        errors.add(:new_graphic_item_version,"est requis")
      end
    else          
      if ((self.new_record? or self.should_add_version)         and 
          (self.new_graphic_item_version.image_file_name.nil?   and 
           self.new_graphic_item_version.image_file_size.nil?   and 
           self.new_graphic_item_version.image_content_type.nil?  ))
        errors.add(:new_graphic_item_version,"[image] est requise")
      end
    end                                                                          
  end
  
  def validates_uniqueness_of_is_current_version_set_to_true
    errors.add(:graphic_item_versions,"Un seul graphic item version peut être sélectionné à la fois comme current version") unless self.graphic_item_versions.select {|giv| giv.is_current_version}.size <= 1
  end
  
  def generate_reference
    #TODO improve that method with pattern management
    if GraphicItem.find(:all).empty?
      self.reference = 1
    else
      self.reference = GraphicItem.last.reference.to_i + 1
    end
  end
  
  def current_version
    self.graphic_item_versions.detect {|giv| giv.is_current_version_was}
  end
  
  def current_version_id
    self.current_version.id
  end
  
  def current_version=(giv_id)
    unless self.new_record?
      unless self.current_version_id.to_s == giv_id.to_s
        self.should_change_version = true
        self.old_graphic_item_version = self.current_version
        self.old_graphic_item_version.is_current_version = false
        self.new_graphic_item_version = self.graphic_item_versions.detect {|giv| giv.id == giv_id.to_i}
        self.new_graphic_item_version.is_current_version = true
      end
    end
  end
  
  def current_version_id=(giv_id)
    self.current_version=(giv_id)
  end
  
  def current_source
    unless self.graphic_item_versions.empty?
      self.current_version.source
    end
  end
  
  def current_image
    unless self.graphic_item_versions.empty?
      self.current_version.image
    end
  end
  
  def graphic_item_version_attributes=(attributes) 
    unless (attributes[:image].blank? and attributes[:source].blank?)
      self.should_add_version = true
      self.old_graphic_item_version = self.current_version
      self.old_graphic_item_version.is_current_version = false unless self.old_graphic_item_version.nil?
      self.new_graphic_item_version = self.graphic_item_versions.build(:image => attributes[:image], :source => attributes[:source], :is_current_version => true)
    else
      false
    end
  end 

  def save_graphic_item_versions
    if (self.should_add_version or self.should_change_version)
      self.old_graphic_item_version.save(false) unless self.old_graphic_item_version.nil?
      self.new_graphic_item_version.save(false)
      self.should_add_version = false
      self.should_change_version = false
      self.old_graphic_item_version = nil
      self.new_graphic_item_version = nil
      return true # IMPORTANT for not returning nil to the callback
    end
  end
  
  def cancelled?
    self.cancelled
  end
  
  def can_be_cancelled?
    !self.cancelled?
  end
  
  def cancel
    if self.can_be_cancelled?
      self.cancelled = true
      self.save
    end
  end
end
