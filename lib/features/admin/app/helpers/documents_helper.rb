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
  
end
