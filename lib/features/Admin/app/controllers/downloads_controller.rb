class DownloadsController < ApplicationController
  def show
    @document = Document.find(params[:id])
    @owner = @document.has_document

    send_file("documents/#{@owner.class.name.downcase}/#{@document.file_type_id}/#{@document.id}.#{@document.extension}", :file_name => "test")
    #FIXME Vérification des permissions sur le fichier et si le fichier existe ou pas
  end
end
