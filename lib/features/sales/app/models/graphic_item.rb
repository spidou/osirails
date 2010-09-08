class GraphicItem < ActiveRecord::Base
  # Relationships
  belongs_to :order
  belongs_to :graphic_unit_measure
  belongs_to :creator, :class_name => "User"
  
  has_many :graphic_item_versions, :order => "created_at DESC"
  has_many :graphic_item_spool_items

  # Validations
  validates_presence_of :name, :description, :order_id, :graphic_unit_measure_id, :creator_id
  validates_presence_of :order, :if => :order_id
  validates_presence_of :graphic_unit_measure, :if => :graphic_unit_measure_id
  validates_presence_of :creator, :if => :creator_id
  validates_presence_of :reference
  
  validates_persistence_of :graphic_unit_measure_id, :order_id
  
  validates_associated :graphic_item_versions
  
  validate :validates_persistence_of_name
  validate :validates_simultaneous_actions
  validate :validates_new_graphic_item_version
  validate :validates_uniqueness_of_is_current_version_set_to_true 
  
  # Accessors
  attr_accessor :should_add_version
  attr_accessor :should_change_version
  attr_accessor :old_graphic_item_version
  attr_accessor :new_graphic_item_version
  
  # Callbacks
  before_validation_on_create :update_reference
  
  before_save     :destroy_spool_items_on_update
  after_save      :save_graphic_item_versions
  
  before_destroy  :destroy_spool_items_on_destroy, :destroy_graphic_item_versions

  # Methods
  def validates_persistence_of_name
    if name != name_was and !new_record?
      if is_in_spool("image") or is_in_spool("source")
        errors.add(:name, "Le nom ne peut être modifié car l'élément graphique se trouve dans la file d'attente d'un ou plusieurs utilisateurs")
      end
    end
  end
  
  def validates_simultaneous_actions
    errors.add(:graphic_item_version,"ne peut être ajoutée en même temps qu'un changement de version") if (should_add_version and should_change_version)
  end
  
  def validates_new_graphic_item_version
    if new_graphic_item_version.nil?
      if should_add_version
        errors.add(:new_graphic_item_version,"est requis")
      elsif new_record?
        errors.add(:new_graphic_item_version,"est requis")
      end
    else          
      if ((new_record? or should_add_version)              and 
          (new_graphic_item_version.image_file_name.nil?   and 
           new_graphic_item_version.image_file_size.nil?   and 
           new_graphic_item_version.image_content_type.nil?  ))
        errors.add(:new_graphic_item_version,"[image] est requise")
      end
    end                                                                          
  end
  
  def validates_uniqueness_of_is_current_version_set_to_true
    errors.add(:graphic_item_versions,"Un seul graphic item version peut être sélectionné à la fois comme current version") unless graphic_item_versions.select {|giv| giv.is_current_version}.size <= 1
  end
  
  def destroy_spool_items_on_update
    unless new_record?
      if (should_add_version or should_change_version or cancelled?)
        User.find(:all).each do |user|
          ["image","source"].each do |type|
            remove_from_graphic_item_spool(type,user)
          end
        end
      end
    end
  end

  def destroy_spool_items_on_destroy
    User.find(:all).each do |user|
      ["image","source"].each do |type|
        remove_from_graphic_item_spool(type,user)
      end
    end
  end
  
  def destroy_graphic_item_versions
    graphic_item_versions.each do |giv|
      giv.destroy
    end
  end
  
  def current_version
    graphic_item_versions.detect {|giv| giv.is_current_version_was}
  end
  
  def current_version_id
    current_version.id
  end
  
  def current_version=(giv_id)
    unless new_record?
      unless current_version_id.to_s == giv_id.to_s
        self.should_change_version = true
        self.old_graphic_item_version = current_version
        self.old_graphic_item_version.is_current_version = false
        self.new_graphic_item_version = graphic_item_versions.detect {|giv| giv.id == giv_id.to_i}
        self.new_graphic_item_version.is_current_version = true
      end
    end
  end
  
  def current_version_id=(giv_id)
    self.current_version=(giv_id)
  end
  
  def current_source
    unless graphic_item_versions.empty?
      current_version.source
    end
  end
  
  def current_image
    unless graphic_item_versions.empty?
      current_version.image
    end
  end
  
  def graphic_item_version_attributes=(attributes) 
    unless (attributes[:image].blank? and attributes[:source].blank?)
      self.should_add_version = true
      self.old_graphic_item_version = current_version
      self.old_graphic_item_version.is_current_version = false unless old_graphic_item_version.nil?
      self.new_graphic_item_version = graphic_item_versions.build(:image => attributes[:image], :source => attributes[:source], :is_current_version => true)
    else
      false
    end
  end 

  def save_graphic_item_versions
    if (should_add_version or should_change_version)
      old_graphic_item_version.save(false) unless old_graphic_item_version.nil?
      new_graphic_item_version.save(false)
      self.should_add_version = false
      self.should_change_version = false
      self.old_graphic_item_version = nil
      self.new_graphic_item_version = nil
      return true # IMPORTANT for not returning nil to the callback
    end
  end
  
  def cancelled?
    cancelled
  end
  
  def can_be_cancelled?
    !cancelled?
  end
  
  def cancel
    if can_be_cancelled?
      self.cancelled = true
      self.save
    end
  end 
  
  def add_to_graphic_item_spool(type,user)
    return false if new_record?
    return false if (!["image","source"].include?(type) or is_in_user_spool(type,user) or send("current_#{type}").path.nil?)
    
    gisi = GraphicItemSpoolItem.new({:user => user, :graphic_item => self, :file_type => type}) 
    spool_directory = "#{GraphicItemSpoolItem::SPOOL_DIRECTORY}"
    
    unless File.exists?("#{spool_directory}/#{gisi.user_spool_directory}/")
      system "mkdir -p #{spool_directory}/#{gisi.user_spool_directory}/"
    end
    
    gisi.save
  end
  
  def remove_from_graphic_item_spool(type,user)
    return false if new_record?
    return false if (!["image","source"].include?(type) or !is_in_user_spool(type,user) or send("current_#{type}").path.nil?)
    
    GraphicItemSpoolItem.find(spool_item_id(type,user)).destroy
  end
  
  def is_in_user_spool(type,user)
    return false if new_record?
    return false if (!["image","source"].include?(type) or send("current_#{type}").path.nil?)
    
    user.graphic_item_spool_items(true).select{|gisi| gisi.graphic_item == self and gisi.file_type == type}.any?
  end
  
  def is_in_spool(type)
    return false if new_record?
    return false if (!["image","source"].include?(type) or send("current_#{type}").path.nil?)
    
    returns = []
    
    User.find(:all).each do |user|
      returns << is_in_user_spool(type,user)
    end
    
    returns.include?(true)
  end
  
  def spool_item_id(type,user)
    return nil if new_record?
    return false if (!["image","source"].include?(type) or send("current_#{type}").path.nil?)

    gisi = graphic_item_spool_items.find(:first,:conditions => ["file_type = ? AND user_id = ?",type,user.id])
    
    gisi.id unless gisi.nil?
  end
  
  def short_description
    description.size <= 100 ? description : description[0..100] + "[...]"
  end
end
