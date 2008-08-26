module EstablishmentsHelper
  def get_address_form(owner_address)
    render :partial => 'addresses/address',  :locals => {:owner_address => owner_address, :cpt => 1}
  end
  
  def get_new_contact_form(cpt, params, error)
    render :partial => 'contacts/new_contact_form', 
      :locals => {:cpt=> cpt, :error => error, :owner_type => params[:owner_type], :owner_id => params[:owner_id]}
  end
end
