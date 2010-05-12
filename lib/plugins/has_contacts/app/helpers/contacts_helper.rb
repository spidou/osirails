module ContactsHelper
  
  def display_contact(contact, options = {})
    render :partial => contact, :locals => options
  end
  
  def display_contacts_list(contacts_owner, group_by_owner = false)
    html = '<div id="contacts" class="resources">'
    html << render_contacts_list(contacts_owner, :group_by => "first_name", :order_by => "asc", :group_by_owner => group_by_owner)
    html << '</div>'
    html << render_new_contacts_list(contacts_owner)
  end
  
  # Method to display contacts stored into +all_contacts+ method 
  #
  def display_all_contacts(owner)
    html = '<div id="contacts" class="resources">'
    html << render( :partial => 'contacts/contact', :collection => owner.all_contacts, :locals => { :contacts_owner => owner })
    html << '</div>'
  end
  
  def display_new_contacts_list(contacts_owner)
    render_new_contacts_list(contacts_owner)
  end
  
  def display_contact_picker(contact_owner, contacts, options = {})
    render :partial => 'contacts/contact_picker', :object => contact_owner, :locals => options.merge({ :contact_list => contacts })
  end

  def display_contact_add_button(contacts_owner)
    html = "<p>"
    html << link_to_function("Ajouter un contact") do |page|
      partial = escape_javascript( render(:partial => 'contacts/contact',
                                          :object => contacts_owner.contacts.build,
                                          :locals => { :contacts_owner => contacts_owner }))
      page << h("$('new_contacts').insert({ bottom: '#{ partial }'})")
      page['new_contacts'].show if page['new_contacts'].visible
      last_contact = page['new_contacts'].select('.contact').last
      last_contact.show
      last_contact.visual_effect :highlight
    end
    html << "</p>"
  end
  
  def display_add_contact_button_for_owner(contacts_owner)
    div_id = "#{contacts_owner.class.singularized_table_name}_#{contacts_owner.id}_contacts"
    
    html = "<p>"
    html << link_to_function("Ajouter un contact", nil, :href => "##{div_id}")  do |page|
      partial = escape_javascript(render(:partial => 'contacts/contact',
                                        :object => contacts_owner.contacts.build,
                                        :locals => { :contacts_owner => contacts_owner }))
      page << h("$('#{ div_id }').insert({ bottom: '#{ partial }'})")
      
      # add a #FAKE_ID to the last new record to permit it to be linked with his numbers new records
      # That fake_id is retrieved into numbers_helper.rb 'add_number_link' method
      # TODO do not forget to remove that part when the trick will become useless.
      fake_id = "'new_record_' +(Math.floor(Math.random()*Math.pow(10,8)) + new Date().getSeconds()).toString()"
      page << "$('#{ div_id }').childElements().last().down('.contact_id').value = #{ fake_id }"
      #############################################################################################
      
      page[div_id].show if page[div_id].visible
      last_contact = page[div_id].select('.contact').last
      last_contact.show
      last_contact.visual_effect :highlight
    end
    html << "</p>"
  end

  def display_contact_edit_button(contact)
    return unless is_form_view? and Contact.can_edit?(current_user)
    link_to_function "Modifier", "mark_resource_for_update(this)"
  end

  def display_contact_hide_button(contact)
    return unless is_form_view? and Contact.can_hide?(current_user)
    message = '"Êtes vous sûr?\nAttention, les modifications seront appliquées à la soumission du formulaire."'
    link_to_function "Supprimer", "if (confirm(#{message})) mark_resource_for_hide(this)"
  end
  
  def display_contact_delete_button(contact)
    return unless is_form_view? and Contact.can_delete?(current_user)
    message = '"Êtes vous sûr?\nAttention, les modifications seront appliquées à la soumission du formulaire."'
    link_to_function "Supprimer définitivement", "if (confirm(#{message})) mark_resource_for_destroy(this)"
  end
  
  def display_contact_close_form_button(contact)
    if contact.new_record?
      link_to_function "Annuler la création du contact", "cancel_creation_of_new_resource(this)"
    else is_form_view?
      link_to_function "Annuler la modification du contact", "mark_resource_for_dont_update(this)"
    end
  end
  
  def get_letter_range(letter)
    if letter.between("A", "D")
      "A-D"
    elsif letter.between("E", "H")
      "E-H"
    elsif letter.between("I", "L")
      "I-L"
    elsif letter.between("M", "P")
      "M-P"
    elsif letter.between("Q", "T")
      "Q-T"
    elsif letter.between("U", "Z")
      "U-Z"
    elsif letter.empty?
      "Aucun"
    end
  end
  
  private
  
    def contacts_path(contacts_owner, options = {})
      send("#{contacts_owner.class.singularized_table_name}_contacts_path", contacts_owner.id, options)
    end

    def contact_path(contacts_owner, contact, options = {})
      send("#{contacts_owner.class.singularized_table_name}_contact_path", contacts_owner.id, contact.id, options)
    end
    
    def render_contacts_list(contacts_owner, options = {})
      @contacts_owner = contacts_owner
      contacts = contacts_owner.contacts.select{ |contact| !contact.new_record? }
      render(:partial => "contacts/contacts_list", :object => contacts, :locals => options)
    end
    
    def group_contacts_by_method(method, contacts_owner)
      if @group_by == method and @order_by == "asc"
        order_by = "desc"
        order_symbol = "↓"
      else
        order_by = "asc"
        order_symbol = "↑"
      end
      link_to_remote "#{method.humanize} #{order_symbol}", :update => :contacts,
                                                           :url    => contacts_path( contacts_owner,
                                                                                     :group_by => method,
                                                                                     :order_by => order_by ),
                                                           :method => :get
    end

    def render_new_contacts_list(contacts_owner)
      new_contacts = contacts_owner.contacts.select{ |contact| contact.new_record? }
      html =  "<div class=\"resource_group contact_group new_records\" id=\"new_contacts\" #{"style=\"display:none\"" if new_contacts.empty?}>"
      html << "  <h1>Nouveaux contacts</h1>"
      html << render(:partial => 'contacts/contact', :collection => new_contacts, :locals => { :contacts_owner => contacts_owner })
      html << "</div>"
    end
  
end
