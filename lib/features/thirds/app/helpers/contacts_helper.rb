module ContactsHelper
  
  def display_contacts_list(contacts_owner)
    return unless Contact.can_list?(current_user)
    html = "<h2>Contacts</h2>"
    html << "<div id=\"contacts\">"
    unless contacts_owner.contacts.empty?
      html << render(:partial => 'contacts/contact_in_one_line', :collection => contacts_owner.contacts, :locals => { :contacts_owner => contacts_owner } )
    else
      html << "<p>Aucun contact n'a été trouvé</p>"
    end
    html << "</div>"
  end
  
  def display_contact_add_button(contacts_owner)
    return unless Contact.can_add?(current_user)
    link_to_function "Ajouter un contact" do |page|
      page.insert_html :bottom, :contacts, :partial => 'contacts/contact_form', :object => Contact.new, :locals => { :contacts_owner => contacts_owner }
    end
  end
  
end
