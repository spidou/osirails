class Dunning < ActiveRecord::Base
  has_permissions :as_business_object, :additional_class_methods => [ :cancel ]
  
  named_scope :actives, :conditions => ["cancelled is NULL or cancelled = ?", false]
  named_scope :cancelled, :conditions => ["cancelled =?", true]
  
  belongs_to :has_dunning,  :polymorphic => true
  belongs_to :creator,      :class_name => 'User'
  belongs_to :cancelled_by, :class_name => 'User'
  belongs_to :dunning_sending_method

  validates_presence_of :date, :creator_id, :dunning_sending_method_id, :comment, :has_dunning_id, :has_dunning_type
  
  validates_presence_of :dunning_sending_method, :if => :dunning_sending_method_id
  validates_presence_of :creator,                :if => :creator_id
  validates_presence_of :has_dunning,            :if => :has_dunning_id
  
  validates_date :date, :on_or_after          => Proc.new {|n| n.has_dunning.sended_on if n.has_dunning},
                        :on_or_after_message  => "ne doit pas être AVANT la date d'envoi au client&#160;(%s)",
                        :on_or_before         => Proc.new { Date.today },
                        :on_or_before_message => "ne doit pas être APRÈS aujourd'hui&#160;(%s)"
  

  
  validates_persistence_of :date, :creator_id, :dunning_sending_method_id, :comment, :has_dunning_id, :unless => :new_record?
  
  validate :validates_has_dunning_was_sended
  
  before_destroy :can_be_destroyed?
  
  attr_protected :cancelled, :cancelled_by, :has_dunning_type, :has_dunning_id
  
  cattr_accessor :form_labels
  @@form_labels = {}
  @@form_labels[:date]                   = "Effectuée le :"
  @@form_labels[:dunning_sending_method] = "Par :"
  @@form_labels[:comment]                = "Commentaire :"
  
  def can_be_added?
    return false unless has_dunning
    has_dunning.was_sended?
  end
  
  def can_be_destroyed?
    false
  end
  
  def can_be_cancelled?
    !new_record?
  end
  
  def was_cancelled?
    cancelled_was
  end
  
  def cancelled?
    cancelled
  end
  
  def cancel(user)
    return false unless can_be_cancelled?
    self.cancelled = true
    self.cancelled_by = user
    self.save
  end
  
  private
    def validates_has_dunning_was_sended
      errors.add(:has_dunning, "Vous ne pouvez signaler une relance que si l'objet est dans l'état 'envoyé au client'") unless can_be_added?
    end
end
