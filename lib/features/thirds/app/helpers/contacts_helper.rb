module ContactsHelper
  
  def get_return_link(owner_type)
    eval "link_to 'Retour', #{owner_type.downcase}_contact_path(@owner, @contact, :owner_type => @owner_type)"
  end
  
  ## Return link to owner page
  def get_owner_link(owner_type)
    link = ""
    controller =owner_type.split("/")
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
    contact = Contact.find(contact_id)
    render :partial => 'contacts/contact_show_info', :locals => {:contact => contact, :error => false, :cpt => cpt}
  end
  
  
  ##########################################################################
  
  
  ## Display all contacts and add button (use in edit)
  def display_contacts_and_add_contact_button(owner, contacts, params, new_contact_number, error)
    contact_controller = Menu.find_by_name('contacts')
    html = ""
    if contact_controller.can_list?(current_user) and Contact.can_list?(current_user)
      html += "<p>"
      html += display_contacts(owner, contacts)
      html += "</p>"
    end
    
    if contact_controller.can_add?(current_user) and Contact.can_add?(current_user)
      html += "<p>"
      html += display_add_contact_button(owner, params, new_contact_number, error) + "<br/>"
      html += "</p>"
    end
    return html
  end
  
  ## Display contacts lists
  def display_contacts(owner, contacts)
    contact_controller = Menu.find_by_name('contacts')
    html = "<h2>Contacts</h2>"
    unless contacts.empty?
      for contact in contacts
        html += "<p>"
        html += contact.first_name + " " + contact.last_name + "&nbsp;"
        if contact_controller.can_view?(current_user) and Contact.can_view?(current_user)
          html += eval "link_to 'Plus d&#39;infos', #{owner.class.name.tableize.singularize}_contact_path(owner, contact, :owner_type => owner.class.name)"
        end
        if contact_controller.can_delete?(current_user) and Contact.can_delete?(current_user)
          html += "&nbsp;" + link_to("Supprimer", [owner,  contact], :method => :delete, :confirm => 'Etes vous sûr ?')
        end
        html += "</p>"
      end
    else
      html += "<p>"
      html += "Aucun contacts"
      html += "</p>"
    end
    return html
  end
  
  ## Display add contact button
  def display_add_contact_button(owner, params, new_contact_number, error)
    render :partial => 'contacts/new_contact', :locals => {:owner_type => owner.class.to_s, :owner_id => owner.id, :params => params, :new_contact_number => new_contact_number, :error => error}
  end
  
end