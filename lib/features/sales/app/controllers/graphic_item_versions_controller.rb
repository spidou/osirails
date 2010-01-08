class GraphicItemVersionsController < ApplicationController  
  # GET /graphic_item_versions/:id/:style.:extension
  #
  def show
    @graphic_item_version = GraphicItemVersion.find(params[:id])
    is_image = params[:name] != "source" ? true : false
    
    if GraphicItemVersion.can_view?(current_user)
      if params[:name] != "source"
        ext = File.extname(@graphic_item_version.image.path)
        dir = File.dirname(@graphic_item_version.image.path)
        url = "#{dir}/#{params[:name]}#{ext}"
      else
        url = @graphic_item_version.source.path
      end
      
      send_file url
    end
  end
  
end
