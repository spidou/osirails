class EstablishmentsController < ApplicationController
  
  def create
    @establishment = Establishment.new(params[:establishment])
    if @establishment.save
      flash[:notice] = "Etablissement ajouté avec succes"
      redirect_to  :controller => :customers, :action => 'index'
    else
      render :controller => :customers, :action => 'edit'
    end
  end
  
end