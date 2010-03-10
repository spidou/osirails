module DunningsHelper
  
  def display_dunning_add_button(order, owner, message=nil)
    return unless Dunning.can_add?(current_user) and owner.was_sended?
    text = "Signaler une relance"
    message ||= " #{text}"
    link_to( image_tag( "relaunch_16x16.png",
                        :alt => text,
                        :title => text ) + message,
             new_order_dunning_path(order, :owner => owner.class.name, :owner_id => owner.id))
  end
  
  def display_dunning_cancel_button(dunning)
    return unless Dunning.can_cancel?(current_user)
    owner = dunning.has_dunning
    order = owner.order
    link_to( image_tag( "cancel_16x16.png",
                        :alt => text = "Invalider cette relance",
                        :title => text ),
             order_dunning_cancel_path(order, :dunning_id => dunning.id, :owner => owner.class.name, :owner_id => owner.id),
             :confirm => "Êtes-vous sûr ?" )
  end
  
end
