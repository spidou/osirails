# deprecated class
class DocumentRouteDefinition
#  
#  def self.parse_model
#    # This block is use because Document.add_model is call only when model is use
#    files = Dir.glob("**/**/**/app/models/*.rb")
#    files.each do |file|
#      file.split("/").last.chomp(".rb").camelize.constantize
#    end
#  end
#  
#  def self.create_route_with_array(resource, document_route)
#    unless document_route.empty?
#      if document_route[0].plural?
#        resource.resources "#{document_route[0]}" do |resource_|
#          DocumentRouteDefinition.create_route(resource_, document_route.delete_at(0))
#        end
#      else
#        resource.resource "#{document_route[0]}" do |resource_|
#          document_route.delete_at(0)
#          DocumentRouteDefinition.create_route_with_array(resource_, document_route)
#        end
#      end
#    else
#      resource.resources :documents do |document|
#        document.resources :document_versions
#      end
#    end
#    
#  end
#  
#  def self.create_route(model_name)
#    ActionController::Routing::Routes.add_routes do |map|
#      ### DOWLOADS
#      map.resources :downloads
#      ### END
# 
#      ### DOCUMENTS
#      model = model_name
#      
#      if model.constantize.document_route.nil?
#        map.resources "#{model.tableize}" do |model_|
#          model_.resources :documents do |document|
#            document.resources :document_versions
#          end
#        end
#      else
#        map.resources "#{model.constantize.document_route[0]}" do |resource|
#          document_route = model.constantize.document_route
#          document_route.delete_at(0)
#          DocumentRouteDefinition.create_route_with_array(resource, document_route)
#        end
#      end    
#    end
#    ### END DOCUMENTS
#  
#  
#  end
end
