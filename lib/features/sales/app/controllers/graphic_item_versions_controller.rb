class GraphicItemVersionsController < ApplicationController  
  
  # GET /graphic_item_versions/:id/:type/:style
  def show
    error_access_page(400) unless ['image', 'source'].include?(params[:type])
    
    @graphic_item_version = GraphicItemVersion.find(params[:id])
    @graphic_item = @graphic_item_version.graphic_item
    
    if GraphicItemVersion.can_view?(current_user)
      url = @graphic_item_version.send(params[:type]).path(params[:style])
      ext = File.extname(url)
      
      send_file url, :filename  => "#{@graphic_item.name.underscore}#{'_source' if params[:type] == 'source'}#{ext}",
                     :type      => @graphic_item_version.send("#{params[:type]}_content_type")
    end
  end
  
end
