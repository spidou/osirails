## DATABASE STRUCTURE
# A integer  "invoice_id"
# A date     "date"
# A decimal  "net_to_paid", :precision => 65, :scale => 20
# A datetime "created_at"
# A datetime "updated_at"

class DueDate < ActiveRecord::Base
  has_permissions :as_business_object
  
  belongs_to :invoice
  
  has_many :payments, :order => "paid_on ASC", :dependent => :nullify
  has_many :adjustments, :order => "created_at", :dependent => :nullify
  
  validates_presence_of :date
  
  validates_numericality_of :net_to_paid
  
  validates_persistence_of :date, :net_to_paid, :unless => :can_be_edited?
  validates_persistence_of :payments, :if => :was_paid?
  
  validates_associated :payments
  
  journalize :attributes        => [:date, :net_to_paid],
             :subresources      => [:payments, :adjustments],
             :identifier_method => Proc.new{ |d| "#{d.date} - #{d.net_to_paid.to_f.round_to(2).to_s(2)}" }
  
  after_save :save_payments, :save_adjustments
  
  attr_accessor :should_destroy
  
  def should_destroy?
    should_destroy.to_i == 1
  end
  
  def can_be_edited?
    invoice ? invoice.can_be_edited? : false
  end
  
  def total_amounts
    (payments + adjustments).collect{ |x| x.amount || 0 }.sum
  end
  
  def paid?
    total_amounts.to_f.round_to(2) == net_to_paid.to_f.round_to(2)
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
    return if was_paid?
    
    payment_attributes.each do |attributes|
      if attributes[:id].blank?
        payments.build(attributes)
      end
    end
  end
  
  def save_payments
    return if was_paid?
    
    payments.each do |p|
      p.save(false) if p.new_record?
    end
  end
  
  def adjustment_attributes=(adjustment_attributes)
    return if was_paid?
    
    adjustment_attributes.each do |attributes|
      if attributes[:id].blank?
        adjustments.build(attributes)
      end
    end
  end
  
  def save_adjustments
    return if was_paid?
    
    adjustments.each do |a|
      a.save(false) if a.new_record?
    end
  end
  
end
