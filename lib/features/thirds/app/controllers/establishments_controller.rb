class EstablishmentsController < ApplicationController

  def show
    @establishment = Establishment.find(params[:id])
    
    url     = @establishment.logo.path(:thumb)
    options = {:filename => @establishment.logo_file_name, :type => @establishment.logo_content_type, :disposition => 'inline'}
    
    respond_to do |format|
      format.jpg { send_data(File.read(url), options) }
      format.png { send_data(File.read(url), options) }
    end
  end

end
