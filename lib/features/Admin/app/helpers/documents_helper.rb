module DocumentsHelper
  def get_document_form(owner)
    if Document.can_have_document(owner.class.name)
      document = Document.new()
      render :partial => "documents/document_form", :locals => {:owner => owner, :document => document} 
    end
  end
  
  def get_file_type_select(document_helper, model_owner)
    document_helper.select(:file_type_id, FileType.find(:all, :conditions => ["model_owner = ?", model_owner]).collect {|a| [a.name + "(" + (t = a.file_type_extensions.each{|f| a.file_type_extensions[a.file_type_extensions.index(f)] = f.name}.join(",")
            ; t.split(",").size < 3 ? t : t.split(",")[0..2].join(",").concat("...") )+ ")", a.id]})
  end
  
  def get_return_link(document)
    eval <<-EOV
      link_to 'retour', #{document.owner_class.downcase}_path(document.has_document)
    EOV
  end
  
  def link_download_last_version(document)
    link_to("download", :controller => "Downloads", :action => "show", 
        :document => (last_document = document.document_versions.last; last_document.nil? ? {:id => document.id, :type => "Document"} :  {:id => last_document, :type => "DocumentVersion"} ))
  end
  
end
