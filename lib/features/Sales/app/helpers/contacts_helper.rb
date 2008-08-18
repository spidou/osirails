module ContactsHelper
  def get_return_link(owner_type)
    eval "link_to 'Revenir sur la fiche du client', edit_#{owner_type.downcase}_path(@owner)"
  end
end