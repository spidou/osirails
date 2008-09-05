class DownloadsController < ApplicationController

  def show
    
    ## Store dynamiquely Document or DocumentVersion 
    @document = params[:document][:type].constantize.find(params[:document][:id])
    
    if @document.class.equal?(Document)
      send_file("documents/#{@document.owner_class}/#{@document.file_type_id}/#{@document.id}.#{@document.extension}")
    elsif @document.class.equal?(DocumentVersion)
      send_file("documents/#{@document.document.owner_class}/#{@document.document.file_type_id}/#{@document.document.id}/#{@document.version}.#{@document.document.extension}")
    end
    
    #FIXME Vérification des permissions sur le fichier et si le fichier existe ou pas
  end

end
