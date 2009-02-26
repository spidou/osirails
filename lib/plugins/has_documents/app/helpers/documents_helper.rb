module DocumentsHelper
  
  def display_documents_list(documents_owner)
    owner_identifier = documents_owner.class.name.downcase + "_id"
    render_component :controller => "documents", :action => "index", :params => { owner_identifier.to_sym => documents_owner.id, :authenticity_token => form_authenticity_token }
  end
  
  def group_by_method(method, documents)
    link_to_remote method.capitalize, :update => :documents, :url => { :controller => :documents, :action => :index, :customer_id => 21, :group_by => method, :order_by => "asc" }, :method => :get
  end
  
  def display_document_add_button(documents_owner)
    link_to_function "Ajouter un document" do |page|
      page.insert_html :bottom, :documents, :partial => 'documents/document_form', :object => documents_owner.documents.build , :locals => { :documents_owner => documents_owner }
    end
  end
  
end