## DATABASE STRUCTURE
# A integer  "due_date_id"
# A integer  "payment_method_id"
# A date     "paid_on"
# A decimal  "amount",                  :precision => 65, :scale => 20
# A string   "bank_name"
# A string   "payment_identifier"
# A string   "attachment_file_name"
# A string   "attachment_content_type"
# A integer  "attachment_file_size"
# A datetime "created_at"
# A datetime "updated_at"

class Payment < ActiveRecord::Base
  belongs_to :due_date
  belongs_to :payment_method
  
  has_attached_file :attachment,
                    :path => ':rails_root/assets/sales/:class/:attachment/:id.:extension',
                    :url  => '/payment_attachments/:id'
  
  validates_presence_of :paid_on
  #validates_presence_of :payment_method_id                             # TODO before remove that lines, test if the code put in invoice.rb can replace them
  #validates_presence_of :payment_method, :if => :payment_method_id     #
  
  validates_numericality_of :amount
  
  validates_persistence_of :due_date_id, :payment_method_id, :amount, :paid_on, :attachment_file_name, :attachment_file_size, :attachment_content_type
  
  validate :validates_amount_not_equal_to_zero
  
  journalize :attributes        => [:paid_on, :amount, :payment_method_id, :bank_name, :payment_identifier],
             :attachments       =>  :attachment,
             :identifier_method => Proc.new{ |p| "#{p.payment_method && p.payment_method.name}#{" n°#{p.payment_identifier}" unless p.payment_identifier.blank?} - #{p.amount}" }
  
  def validates_amount_not_equal_to_zero
    errors.add(:amount, "ne doit pas être égal à 0 (zéro)") if amount == 0
  end
end
