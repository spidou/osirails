module DocumentsHelper

  def display_documents_list(documents_owner)
    html = "<div id=\"#{documents_owner.class.name.underscore}_documents\">"
    html << render_documents_list(documents_owner, :group_by => "date", :order_by => "asc")
    html << '</div>'
    html << render_new_documents_list(documents_owner)
  end

  def render_documents_list(documents_owner, options = {})
    @documents_owner = documents_owner
    documents = documents_owner.documents.select{ |document| !document.new_record? }
    html =  "<div class=\"resources_list documents_list\" id=\"documents_list\">"
    html << render(:partial => "documents/documents_list", :object => documents, :locals => options)
    html << "</div>"
  end
  
  def render_new_documents_list(documents_owner)
    new_documents = documents_owner.documents.select{ |document| document.new_record? }
    html =  "<div class=\"resource_group document_group new_records\" id=\"new_documents\" #{"style=\"display:none\"" if new_documents.empty?}>"
    html << "  <h1>Nouveaux documents</h1>"
    html << render(:partial => 'documents/document', :collection => new_documents, :locals => { :documents_owner => documents_owner })
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
    link_to_remote "#{method.capitalize} #{order_symbol}", :update  => "#{documents_owner.class.name.underscore}_documents",
                                                           :url     => documents_path( documents_owner,
                                                                                       :group_by => method,
                                                                                       :order_by => order_by,
                                                                                       :owner    => documents_owner.class.name,
                                                                                       :owner_id => documents_owner.id ),
                                                           :method  => :get
  end

  def display_document_add_button(documents_owner)
    content_tag( :p, link_to_function "Ajouter un document" do |page|
      page.insert_html :bottom, :new_documents, :partial  => 'documents/document',
                                                :object   => documents_owner.build_document,
                                                :locals   => { :documents_owner => documents_owner }
      page['new_documents'].show if page['new_documents'].visible
      last_document = page['new_documents'].select('.document').last
      last_document.show
      last_document.visual_effect :highlight
    end )
  end

  def display_document_edit_button(document)
    link_to_function "Modifier", "mark_resource_for_update(this)" if is_form_view?
  end

  def display_document_delete_button(document)
    link_to_function "Supprimer", "mark_resource_for_destroy(this)" if is_form_view?
  end

  def display_document_preview_button(document)
    link_to_function("Aperçu", :title => "Cliquer pour agrandir") do |page|
      #page.insert_html( :bottom, "document_preview_#{document.id}", image_tag(document.attachment.url(:medium), :class => "preview", :onclick => "this.remove()") )
    end
  end
  
  def display_document_close_form_button(document)
    if document.new_record?
      link_to_function "Annuler la création du document", "cancel_creation_of_new_resource(this)"
    else is_form_view?
      link_to_function "Annuler la modification du document", "mark_resource_for_dont_update(this)"
    end
  end

  def display_document_download_button(document)
    link_to "Télécharger", attachment_path(document.id, :download => "1")
  end
  
  private
  
    def documents_path(documents_owner, options = {})
      send("#{documents_owner.class.singularized_table_name}_documents_path", documents_owner.id, options)
    end

    def document_path(documents_owner, document, options = {})
      send("#{documents_owner.class.singularized_table_name}_document_path", documents_owner.id, document.id, options)
    end
    
end
