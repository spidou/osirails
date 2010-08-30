module DocumentsHelper

  def display_documents_list(documents_owner, options = {})
    options[:div_id] ||= "#{documents_owner.class.singularized_table_name}_documents"
    
    html = "<div id=\"#{options[:div_id]}\" class=\"resources\">"
    html << render_documents_list(documents_owner, {:group_by => "date", :order_by => "asc"}.merge(options))
    html << '</div>'
    html << render_new_documents_list(documents_owner, options) if is_form_view?
    html
  end

  def render_documents_list(documents_owner, options = {})
    @documents_owner = documents_owner
    collection = documents_owner.documents.select{ |document| !document.new_record? }
    html = ''
    unless collection.empty?
      html << "<div class=\"resources_list documents_list\" id=\"documents_list\">"
      html << render(:partial => "documents/documents_list", :object => collection, :locals => options)
      html << "</div>"
    else
      html << "<p>Aucun document n'a été trouvé.</p>"
    end
  end
  
  def render_new_documents_list(documents_owner, options = {})
    options[:new_div_id] ||= "new_#{documents_owner.class.singularized_table_name}_documents"
    
    collection = documents_owner.documents.select{ |document| document.new_record? }
    html =  "<div class=\"resource_group document_group new_records\" id=\"#{options[:new_div_id]}\" #{"style=\"display:none\"" if collection.empty?}>"
    html << "  <h1>Nouveaux documents</h1>"
    html << render(:partial => 'documents/document', :collection => collection, :locals => {:documents_owner => documents_owner}.merge(options)) unless collection.empty?
    html << "</div>"
  end

  def group_documents_by_method(method, documents_owner)
    if @group_by == method and @order_by == "asc"
      order_by = "desc"
      order_symbol = "v"
    else
      order_by = "asc"
      order_symbol = "^"
    end
    link_to_remote "#{method.capitalize} #{order_symbol}", :update  => "#{documents_owner.class.singularized_table_name}_documents",
                                                           :url     => documents_path( documents_owner,
                                                                                       :group_by => method,
                                                                                       :order_by => order_by,
                                                                                       :owner    => documents_owner.class.name,
                                                                                       :owner_id => documents_owner.id ),
                                                           :method  => :get
  end

  def display_document_add_button(documents_owner, options = {})
    options[:new_div_id] ||= "new_#{documents_owner.class.singularized_table_name}_documents"
    
    content_tag( :p, link_to_function "Ajouter un document" do |page|
      page.insert_html :bottom, options[:new_div_id], :partial  => 'documents/document',
                                                      :object   => documents_owner.build_document,
                                                      :locals   => {:documents_owner => documents_owner}.merge(options)
      page[options[:new_div_id]].show if page[options[:new_div_id]].visible
      last_document = page[options[:new_div_id]].select('.document').last
      last_document.show
      last_document.visual_effect :highlight
    end )
  end

  def display_document_edit_button(document)
    return unless is_form_view? and document.can_edit?(current_user)
    link_to_function "Modifier", "mark_resource_for_update(this)"
  end

  def display_document_delete_button(document)
    return unless is_form_view? and document.can_delete?(current_user)
    message = '"Êtes vous sûr?\nAttention, les modifications seront appliquées à la soumission du formulaire."'
    link_to_function "Supprimer", "if (confirm(#{message})) mark_resource_for_destroy(this)"
  end
  
  def display_document_close_form_button(document)
    if document.new_record?
      link_to_function "Annuler la création du document", "cancel_creation_of_new_resource(this)"
    else is_form_view?
      link_to_function "Annuler la modification du document", "mark_resource_for_dont_update(this)"
    end
  end

  def display_document_download_button(document)
    return unless document.can_download?(current_user)
    image = image_tag("download_16x16.png", :alt => text = "Télécharger", :title => text)
    link_to(image, attachment_path(document.id, :download => "1"))
  end
  
  def display_document_preview_button(document)
    return unless document.can_view?(current_user)
    image = image_tag("preview_16x16.gif", :alt => text = "Aperçu", :title => text)
    link_to(image, document.attachment.url(:medium), :rel => "lightbox[#{document.has_document.class.name.underscore}_#{document.has_document.id}]", :title => "#{document.name} : #{document.short_description}")
  end
  
  private
  
    def documents_path(documents_owner, options = {})
      send("#{documents_owner.class.singularized_table_name}_documents_path", options)
    end

    def document_path(documents_owner, document, options = {})
      send("#{documents_owner.class.singularized_table_name}_document_path", document.id, options)
    end
    
end
