class DownloadsController < ApplicationController

  def show
    @document = params[:document][:type].constantize.find(params[:document][:id])
    if Document.can_view?(current_user, Customer)
      if params[:document][:type].constantize.equal?(Document)
        @document = params[:document][:type].constantize.find(params[:document][:id])
        unless params[:document][:last] == 'true'
          send_file("documents/#{@document.owner_class}/#{@document.file_type_id}/#{@document.id}.#{@document.extension}")
        else
          send_file("documents/#{@document.owner_class}/#{@document.file_type_id}/#{@document.id}/#{@document.document_versions.size}.#{@document.extension}")
        end
     
      elsif params[:document][:type].constantize.equal?(DocumentVersion)
        @document_version = params[:document][:type].constantize.find(params[:document][:id])
        send_file("documents/#{@document_version.document.owner_class}/#{@document_version.document.file_type_id}/#{@document_version.document.id}/#{@document_version.id}.#{@document_version.document.extension}")      
      end
    else
      error_access_page(403)
    end
  end

end
