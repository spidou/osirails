module CustomersHelper
  
  def get_new_contact_form(cpt, params, error)
    render :partial => 'contacts/new_contact_form', 
      :locals => {:cpt=> cpt, :error => error, :owner_type => params[:owner_type], :owner_id => params[:owner_id]}
  end
  
  def get_new_contact_info(contact_id,cpt)
    contact = Contact.find(contact_id)
    render :partial => 'contacts/contact_show_info', 
      :locals => {:contact => contact, :cpt => cpt}
  end
  
end
