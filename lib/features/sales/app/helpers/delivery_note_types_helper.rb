module DeliveryNoteTypesHelper
  
  def kind_of_delivery_note_type(delivery_note_type)
    delivery_note_type.installation? ? "Bon d'installation" : "Bon de livraison"
  end
  
end
