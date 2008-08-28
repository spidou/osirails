module ContactsHelper
  def get_return_link(owner_type)
    eval "link_to 'Retour', edit_#{owner_type.downcase}_path(@owner)"
  end
  
  def get_new_contact_form(params)
    render :partial => 'contacts/new_contact', 
      :locals => {:cpt=> params[:cpt], :error => false, :owner_type => params[:owner_type], :owner_id => params[:owner_id]}
  end
  
end