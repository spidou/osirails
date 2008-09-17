module ContactsHelper
  def get_return_link(owner_type)
    eval "link_to 'Retour', #{owner_type.downcase}_contact_path(@owner, @contact, :owner_type => @owner_type)"
  end
  
  ## Return link to owner page
  def get_owner_link(owner_type)
    link = ""
    controller =owner_type.split("/")
    controller.pop
    controller.each {|c| link += (c.underscore + "_")}
    eval "link_to 'Retour', #{link}path(@owner)"
  end
  
  def get_edit_link(owner_type)
    link = ""
    controller =owner_type.split("/")
    controller.each {|c| link += (c.underscore + "_")}
    eval "link_to 'Modifier', edit_#{link}contact_path(@owner, @contact, :owner_type => @owner_type)"
  end
  
  def get_new_contact_form(params, cpt, error)
    render :partial => 'contacts/new_contact_form', 
      :locals => {:cpt=> cpt, :error => error, :owner_type => params[:owner_type], :owner_id => params[:owner_id], :params => params}
  end
  
  def get_new_contact_info(contact_id, cpt)
    @contact = Contact.find(contact_id)
    render :partial => 'contacts/contact_show_info', :locals => {:contact => @contact, :error => false, :cpt => cpt}
  end
  
end