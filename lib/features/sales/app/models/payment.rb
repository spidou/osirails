class Payment < ActiveRecord::Base
  belongs_to :due_date
  belongs_to :payment_method
  
  has_attached_file :attachment,
                    :path => ':rails_root/assets/:class/:attachment/:id.:extension',
                    :url  => '/invoices/:invoice_id/due_dates/:due_date_id/payments/:id/attachment'
  
  validates_presence_of :paid_on
  validates_presence_of :payment_method_id
  validates_presence_of :payment_method, :if => :payment_method_id
  
  validates_numericality_of :amount
  
  validates_persistence_of :payment_method_id, :amount, :paid_on, :attachment_file_name, :attachment_file_size, :attachment_content_type
  
  def paid_by_factor?
    paid_by_factor == true
  end
  
end
