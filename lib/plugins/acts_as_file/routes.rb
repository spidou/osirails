ActionController::Routing::Routes.add_routes do |map|
    
  ### DOWLOADS
  map.resources :downloads
  ### END
 
  ### DOCUMENTS
  Document.models.each do |model|
    map.resources "#{model.tableize}" do |model_|
      model_.resources :documents do |document|
        document.resources :document_versions
      end
    end 
  end
  ### END DOCUMENTS
end
