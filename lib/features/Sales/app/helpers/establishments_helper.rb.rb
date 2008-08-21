module EstablishmentsHelper
  def get_address_form(owner_address)
    render :partial => 'addresses/address',  :locals => {:owner_address => owner_address, :cpt => 1}
  end
end
