module DocumentssHelper
  def get_document_form
    render :partial => "/documents/document_form"
  end
  
  def get_file_type_select(document)
    document.select(:file_type_id, FileType.find(:all, :conditions => ["model_owner = ?",owner.class.name]).collect {|a| [ a.name + a.file_type_extensions.each {|f| extensions += f.name}, a.id ] })
  end
end
