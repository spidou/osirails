module DocumentsHelper
  
  def display_documents_list(documents_owner)
    # owner_identifier = documents_owner.class.name.downcase + "_id"
    # render_component :controller => "documents", :action => "index", :params => { owner_identifier.to_sym => documents_owner.id, :authenticity_token => form_authenticity_token }
    render_documents_list documents_owner, :group_by => "date", :order_by => "asc"
  end
  
  def render_documents_list documents_owner, options = {}
    @documents_owner = documents_owner
    render :partial => "documents/documents_list", :object => documents_owner.documents, :locals => options
  end
  
  def group_by_method(method, documents_owner)
    owner_identifier = documents_owner.class.name.downcase + "_id"
    #link_to_remote method.capitalize, :update => :documents, :url => { :controller => :documents, :action => :index, owner_identifier.to_sym => documents_owner.id, :group_by => method, :order_by => "asc" }, :method => :get
    link_to_remote method.capitalize, :update => :documents, :url => send("#{documents_owner.class.name.tableize.singularize}_documents_path", documents_owner.id, :group_by => method, :order_by => "asc"), :method => :get
  end
  
  def display_document_add_button(documents_owner)
    link_to_function "Ajouter un document" do |page|
      #page.insert_html :bottom, :documents, :partial => 'documents/document_form', :object => documents_owner.documents.build , :locals => { :documents_owner => documents_owner }
      page.insert_html :bottom, :documents, :partial => 'documents/document_form', :object => documents_owner.build_document , :locals => { :documents_owner => documents_owner }
    end
  end
  
end