class Product < ActiveRecord::Base
  named_scope :actives, :conditions => [ "cancelled_at IS NULL" ]
  
  validates_presence_of :name
  
  cattr_accessor :form_labels
  @@form_labels = {}
  @@form_labels[:reference]         = "Référence :"
  @@form_labels[:product_reference] = "Produit référence :"
  @@form_labels[:name]              = "Spécificité :"
  @@form_labels[:description]       = "Description :"
  @@form_labels[:dimensions]        = "Côtes :"
  @@form_labels[:designation]       = "Désignation :"
  @@form_labels[:vat]               = "Taux de TVA :"
  
  #TODO test that method
  def enabled?
    !cancelled_at
  end
  
  #TODO test that method
  def was_enabled?
    !cancelled_at_was
  end
  
#  before_destroy :cancel_if_cannot_be_destroyed
#  
#  def cancel
#    self.cancelled_at = Time.now
#    self.save
#  end
#  
#  # product cannot be destroyed if it already associated with at least one quote_item, mockup or press_proof
#  def can_be_destroyed?
#    quote_items.empty? and mockups.empty? and press_proofs.empty?
#  end
#  
#  private
#    
#    def cancel_if_cannot_be_destroyed
#      unless can_be_destroyed?
#        self.cancel
#        return false
#      end
#    end
#  
end
