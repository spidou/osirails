class Adjustment < ActiveRecord::Base
  belongs_to :due_date
  
  has_attached_file :attachment,
                    :path => ':rails_root/assets/sales/:class/:attachment/:id.:extension',
                    :url  => "/adjustment_attachments/:id"
  
  validates_presence_of :comment
  
  validates_numericality_of :amount
  
  validates_persistence_of :due_date_id, :amount, :comment, :attachment_file_name, :attachment_file_size, :attachment_content_type
  
  validate :validates_amount_not_equal_to_zero
  
  cattr_accessor :form_labels
  @@form_labels = {}
  @@form_labels[:amount]      = 'Montant :'
  @@form_labels[:comment]     = 'Commentaire :'
  @@form_labels[:attachment]  = 'Pièce jointe :'
  
  def validates_amount_not_equal_to_zero
    errors.add(:amount, "ne doit pas être égal à 0 (zéro)") if amount == 0
  end
end
