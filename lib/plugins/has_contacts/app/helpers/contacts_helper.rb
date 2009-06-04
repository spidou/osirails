module ContactsHelper
  
  def display_contacts_list(contacts_owner)
    html = '<div id="contacts" class="resources">'
    html << render_contacts_list(contacts_owner, :group_by => "last_name", :order_by => "asc")
    html << '</div>'
    html << render_new_contacts_list(contacts_owner)
  end

  def render_contacts_list(contacts_owner, options = {})
    @contacts_owner = contacts_owner
    contacts = contacts_owner.contacts.select{ |contact| !contact.new_record? }
    render(:partial => "contacts/contacts_list", :object => contacts, :locals => options)
  end
  
  def render_new_contacts_list(contacts_owner)
    new_contacts = contacts_owner.contacts.select{ |contact| contact.new_record? }
    html =  "<div class=\"resource_group contact_group new_records\" id=\"new_contacts\" #{"style=\"display:none\"" if new_contacts.empty?}>"
    html << "  <h1>Nouveaux contacts</h1>"
    html << render(:partial => 'contacts/contact', :collection => new_contacts, :locals => { :contacts_owner => contacts_owner })
    html << "</div>"
  end
  
  def display_contacts_picker(contacts_owner, contacts)
    render :partial => 'contacts/contacts_picker', :object => contacts, :locals => { :contacts_owner => contacts_owner }
  end

  def group_contacts_by_method(method, contacts_owner)
    if @group_by == method and @order_by == "asc"
      order_by = "desc"
      order_symbol = "v"
    else
      order_by = "asc"
      order_symbol = "^"
    end
    link_to_remote "#{method.humanize} #{order_symbol}", :update => :contacts,
                                                         :url => contacts_path(contacts_owner, :group_by => method, :order_by => order_by),
                                                         :method => :get
  end

  def display_contact_add_button(contacts_owner)
    html = "<p>"
    html << link_to_function("Ajouter un contact") do |page|
      page.insert_html :bottom, :new_contacts, :partial => 'contacts/contact',
                                                :object => contacts_owner.build_contact,
                                                :locals => { :contacts_owner => contacts_owner }
      page['new_contacts'].show if page['new_contacts'].visible
      last_contact = page['new_contacts'].select('.contact').last
      last_contact.show
      last_contact.visual_effect :highlight
    end
    html << "</p>"
  end

  def display_contact_edit_button(contact)
    link_to_function "Modifier", "mark_resource_for_update(this)" if is_form_view?
  end

  def display_contact_delete_button(contact)
    link_to_function "Supprimer", "mark_resource_for_destroy(this)" if is_form_view?
  end
  
  def display_contact_close_form_button(contact)
    if contact.new_record?
      link_to_function "Annuler la création du contact", "cancel_creation_of_new_resource(this)"
    else is_form_view?
      link_to_function "Annuler la modification du contact", "mark_resource_for_dont_update(this)"
    end
  end
  
  def contacts_path(contacts_owner, options = {})
    send("#{contacts_owner.class.singularized_table_name}_contacts_path", contacts_owner.id, options)
  end

  def contact_path(contacts_owner, contact, options = {})
    send("#{contacts_owner.class.singularized_table_name}_contact_path", contacts_owner.id, contact.id, options)
  end
  
end
