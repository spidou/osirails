module DocumentsHelper
  def get_new_document_form(params, cpt,owner_type, owner_id, error)      
    render :partial => "documents/new_document_form", :locals => {:cpt => cpt, :owner_type => owner_type, 
      :owner_id => owner_id, :params => params, :error => error} 
  end
  
  def get_return_link(document)
    eval <<-EOV
      link_to 'retour', #{document.owner_class.downcase}_path(document.has_document)
    EOV
  end
  
  def link_download_last_version(document)
    link_to("download", :controller => "Downloads", :action => "show", 
      :document => (document.document_versions.empty? ? {:id => document.id, :type => "Document"} :  {:id => document.id, :type => "Document", :last => true} ))
  end
  
  def get_owner(owner_type, owner_id)
    owner_type.constantize.find(owner_id).inspect
  end
  
  def get_description(document)
    document.description.size < 30 ? document.description : document.description[0,25] + "..."
  end
  
  def osibox_initialisation(owner, url)
    html = ""
    owner.class_documents.each_pair do |type, documents|
      documents.each do |document|
        html += osibox_init :partial => "documents/edit_partial", :id => document.id,  :locals => 
          {:document => document, :url => url + document.id.to_s}, :width => "1000px", :height => "1000px" 
      end
    end
    return html
  end
  
  ## Display all documents and add button (use in edit)
  def display_documents_and_add_documents_button(owner, documents, params, new_document_number, error)
    document_controller = Menu.find_by_name('documents')
    html = ""
    if document_controller.can_list?(current_user) and Document.can_list?(current_user, owner.class)
      html += "<p>"
      html = display_documents(owner, documents)
      html += "</p>"
    end
    
    if document_controller.can_add?(current_user) and Document.can_add?(current_user, owner.class)
      html += "<p>"
      html += display_add_document_button(owner, params, new_document_number, error) + "<br/>"
      html += "</p>"
    end
    
    return html
  end
  
  ## Display documents lists
  def display_documents(owner, documents)
    document_controller = Menu.find_by_name('documents')
    html = ""
    if document_controller.can_list?(current_user) and Document.can_list?(current_user, owner.class.name)
    html = "<h2> Documents </h2>"
    unless documents.empty?
      owner.class_documents.each_pair do |type, documents|
        html += "<div class='document_view'>"
        html += "<h1> #{type} </h1>"
        documents.each do |document|
          html += "<div class='document_view_content'>"
          html += image_tag("/images/file_extensions/#{document.extension}_75x75.png")
          html += "<p>"
          html += "<strong>#{document.name}</strong><br />"
          html += "Enregistr&eacute; le #{document.updated_at.strftime('%d %B %Y')} à #{document.updated_at.strftime('%H:%M')}<br/>"
          html += "<a onclick='osibox_open(#{document.id});'>Modifier</a>"
          html += get_description(document)
          if document_controller.can_view?(current_user) and Document.can_view?(current_user, owner.class.name)
            html += "&nbsp;" + link_download_last_version(document)
          end
#          if document_controller.can_delete?(current_user) and Document.can_delete?(current_user, owner.class.name)
#            html += "&nbsp;" + link_to("Supprimer", [owner,  document], :method => :delete, :confirm => 'Etes vous sûr ?')
#          end
          html += "</p>"
          html += "</div>"
        end
        html += "</div>"
      end
    else 
      html += "<p>"
      html += "Aucun documents"
      html += "</p>"
    end
  end
    return html 
  end

  ## Display add document button
  def display_add_document_button(owner, params, new_document_number, error)
    render :partial => 'documents/new_document', :locals => {:params => params, :owner_type => owner.class.name, :owner_id => owner.id, :new_document_number => new_document_number, :error => error}
  end
  
end
