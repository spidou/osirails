class DueDate < ActiveRecord::Base
  has_permissions :as_business_object, :additional_class_methods => [ :pay ]
  
  belongs_to :invoice
  has_many :payments
  
  validates_presence_of :date
  
  validates_numericality_of :net_to_paid, :greater_than => 0
  
  validates_persistence_of :date, :net_to_paid, :unless => :can_be_edited?
  validates_persistence_of :payments, :if => :was_paid?
  
  validates_associated :payments
  
  validate :validates_no_payments_at_creation, :if => :new_record?
  validate :validates_total_amounts_match_net_to_paid, :if => :while_paying
  
  after_save :save_payments
  
  attr_accessor :should_destroy, :while_paying
  
  def should_destroy?
    should_destroy.to_i == 1
  end
  
  def can_be_edited?
    invoice ? invoice.can_be_edited? : false
  end
  
  def validates_no_payments_at_creation
    errors.add(:payments, "Les paiements ne sont pas autorisées à la création de la facture") unless payments.empty?
  end
  
  def validates_total_amounts_match_net_to_paid
    errors.add(:payments, "La somme des règlements ne correspond pas au montant de l'échéance") unless paid?
  end
  
  def total_amounts
    payments.collect(&:amount).sum.to_f
  end
  
  def paid?
    total_amounts == net_to_paid
  end
  
  def paid_on
    payments.last.paid_on if paid?
  end
  
  def was_paid?
    paid? and payments.select(&:new_record?).empty?
  end
  
  def can_be_paid?
    !new_record? and !was_paid?
  end
  
  def payment_attributes=(payment_attributes)
    payment_attributes.each do |attributes|
      if attributes[:id].blank?
        payments.build(attributes)
      end
    end
  end
  
  def save_payments
    payments.each do |p|
      p.save(false) if p.new_record?
    end
  end
  
end
