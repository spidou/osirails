class EstablishmentsController < ApplicationController
  helper :address

  def show
    @establishment = Establishment.find(params[:id])
    
    url     = @establishment.logo.path(:thumb)
    options = {:filename => @establishment.logo_file_name, :type => @establishment.logo_content_type, :disposition => 'inline'}
    
    respond_to do |format|
      format.jpg { send_data(File.read(url), options) }
      format.png { send_data(File.read(url), options) }
    end
  end
  
  def new
    error_access_page(400) if params[:owner_type].blank?
    
    respond_to do |format|
      format.js { render :partial => 'establishments/establishment_in_one_line',
                         :object  => Establishment.new,
                         :locals  => { :owner_type => params[:owner_type] } }
    end
  end
  
end
