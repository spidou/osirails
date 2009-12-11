class Dunning < ActiveRecord::Base
  belongs_to :invoice
  belongs_to :dunning_method
  
  validates_presence_of :comment, :date
  validates_presence_of :dunning_method_id
  validates_presence_of :dunning_method, :if => :dunning_method_id
  
  validates_presence_of :cancelled_by, :if => :cancelled?
  
  validates_date :date, :on_or_after         => Proc.new{ invoice.confirmed_at if invoice.confirmed_at },
                        :on_or_after_message => "ne doit pas être AVANT la date d'émission de la facture&#160;(%s)",
                        :if                  => :invoice
  
  validates_date :paid_at, :on_or_before         => Proc.new{ Date.today },
                           :on_or_before_message => "ne doit pas être APRÈS aujourd'hui&#160;(%s)"
  
  validates_date :paid_at, :on_or_after         => Proc.new{ invoice.confirmed_at if invoice.confirmed_at },
                           :on_or_after_message => "ne doit pas être AVANT la date d'émission de la facture&#160;(%s)",
                           :if                  => :invoice
  
  validates_persistence_of :invoice_id, :dunning_method, :comment, :has_dunning_id, :has_dunning_type
  validates_persistence_of :cancelled_by, :cancelled_ad, :if => :was_cancelled?
  
  def cancelled?
    cancelled_at
  end
  
  def was_cancelled?
    cancelled_at_was
  end
  
  def can_be_cancelled?
  end
  
  def cancel
  end
end
