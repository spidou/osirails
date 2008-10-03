class DocumentRouteDefinition
  
  def self.create_route_with_array(resource, document_route)
    unless document_route.empty?
      if document_route[0].plural?
        resource.resources "#{document_route[0]}" do 
          DocumentRouteDefinition.create_route(resource, document_route.delete_at(0))
        end
      else
        resource.resource "#{document_route[0]}" do 
          DocumentRouteDefinition.create_route(resource, document_route.delete_at(0))
        end
      end
    else
      resource.resources :document do |document|
        document.resources :document_versions
      end
    end
    
  end
  
  def self.create_route(model_name)
    ActionController::Routing::Routes.add_routes do |map|
      ### DOWLOADS
      map.resources :downloads
      ### END
 
      ### DOCUMENTS
      model = model_name
      puts model_name
      
      if model.constantize.document_route.nil?
        map.resources "#{model.tableize}" do |model_|
          model_.resources :documents do |document|
            document.resources :document_versions
          end
        end
      else
        map.resources "#{model.constantize.document_route[0]}" do |resource|
          DocumentRouteDefinition.create_route_with_array(resource, model.constantize.document_route.delete_at(0))
        end
      end    
    end
    ### END DOCUMENTS
  
  
  end
end
