class IbansController < ApplicationController
  # GET /ibans
  def index
    @ibans = Iban.find(:all)
  end

  # GET /ibans/1
  def show
    @iban = Iban.find(params[:id])
  end

  # GET /ibans/new
  def new
    @iban = Iban.new
  end

  # GET /ibans/1/edit
  def edit
    @iban = Iban.find(params[:id])
  end

  # POST /ibans
  def create
    @iban = Iban.new(params[:iban])
    if @iban.save
      flash[:notice] = 'Le RIB a été modifié avec  avec succès.'
      redirect_to(@iban) 
    else
      render :action => "new"
    end
  end

  #PUT /ibans/1
  def update
    params[:iban] ||= []
    @iban = Iban.find(params[:id]) 
    if @iban.update_attributes(params[:iban])
      flash[:notice] = 'Le RIB a été mis-à-jour avec succès.'
      redirect_to(@iban) 
    else
      render :action => "edit"
    end
  end

  # DELETE /ibans/1
  def destroy
    @iban = Iban.find(params[:id])
    @iban.destroy
    redirect_to(ibans_url) 
  end
end
