module ThirdsHelper
  
  def display_contact_form(third, error, params)
    render :partial => 'contacts/new_contact', :locals => {:owner_type => third.class.name,
                :owner_id => third.id, :params => params, :new_contact_number => @new_contact_number,
                :error => error}
  end
  
end