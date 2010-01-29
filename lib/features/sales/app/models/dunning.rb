class Dunning < ActiveRecord::Base
  has_permissions :as_business_object, :additional_class_methods => [:cancel]
  
  named_scope :actives, :conditions => ["cancelled is NULL or cancelled = ?", false]
  named_scope :cancelled, :conditions => ["cancelled =?", true]
  
  attr_protected :cancelled, :cancelled_by
  
  belongs_to :has_dunning,  :polymorphic => true
  belongs_to :creator,      :class_name => 'User'
  belongs_to :cancelled_by, :class_name => 'User'
  belongs_to :dunning_sending_method

  validates_presence_of :date, :creator_id, :dunning_sending_method_id, :comment, :has_dunning_id
  
  validates_presence_of :dunning_sending_method, :if => :dunning_sending_method_id
  validates_presence_of :creator,                :if => :creator_id
  validates_presence_of :has_dunning,            :if => :has_dunning_id
  
  validate :validates_has_dunning_was_sended, :if => :new_record?
  
  validates_date :date, :on_or_after => Proc.new {|n| n.has_dunning.sended_on if n.has_dunning},
                        :on_or_after_message => "ne doit pas être AVANT la date de création de la Relance&#160;(%s)",
                        :on_or_before => Proc.new { Date.today },
                        :on_or_before_message => "ne doit pas être APRÈS aujourd'hui&#160;(%s)"
  

  
  validates_persistence_of :date, :creator_id, :dunning_sending_method_id, :comment, :has_dunning_id, :unless => :can_be_edited?
  
  before_destroy :can_be_destroyed?
  
  cattr_accessor :form_labels
  
  @@form_labels = {}
  @@form_labels[:date]                   = "Date d'envoi :"
  @@form_labels[:creator]                = "Créateur :"
  @@form_labels[:dunning_sending_method] = "Méthode d'envoi :"
  @@form_labels[:comment]                = "Commentaire :"
  
  def can_be_destroyed?
    false
  end
  
  def can_be_edited?
    new_record?
  end
  
  def cancel(user)
    self.cancelled = true
    self.cancelled_by = user
    self.save
  end
  
  private
    
    def validates_has_dunning_was_sended
      errors.add(:has_dunning) if self.has_dunning.nil? or !self.has_dunning.was_sended?
    end
end
