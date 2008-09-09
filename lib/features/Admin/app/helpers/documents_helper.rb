module DocumentsHelper
  
  def get_document_form(owner)
    if Document.can_have_document(owner.class.name)
      document = Document.new()
      render :partial => "documents/document_form", :locals => {:owner => owner, :document => document} 
    end
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
  
end
