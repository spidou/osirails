class DownloadsController < ApplicationController

  def show
    
    ## Store dynamiquely Document or DocumentVersion 
    eval <<-EOV
    @document = #{params[:document][:type]}.find(#{params[:document][:id]})
    EOV
    
    if @document.class.name == "Document"  
      send_file("documents/#{@document.owner_class.downcase}/#{@document.file_type_id}/#{@document.id}.#{@document.extension}")
    elsif @document.class.name == "DocumentVersion"
      send_file("documents/#{@document.document.owner_class.downcase}/#{@document.document.file_type_id}/#{@document.document.id}/#{@document.document.document_versions.index(@document) + 1}.#{@document.document.extension}")
    end
    #FIXME Vérification des permissions sur le fichier et si le fichier existe ou pas
  end

end
