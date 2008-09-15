class  ActAsFileRoute
  def self.add_routes_to(map)
    
    ### DOWLOADS
    map.resources :downloads
    ### END
   
    ### DOCUMENTS
    Document.models.each do |model|
      map.resources "#{model.downcase.pluralize}" do |model_|
        model_.resources :documents do |document|
          document.resources :document_verisons
        end
      end 
    end
    ### END DOCUMENTS
  
  end
end
