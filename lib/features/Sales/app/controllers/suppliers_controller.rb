class SuppliersController < ApplicationController
  def index
    @suppliers = Supplier.find(:all)
  end
  
  def new
    @supplier = Supplier.new
  end
  
  def create
    @supplier = Supplier.new(params[:supplier])
    if @supplier.save
      flash[:notice] = 'Clients ajouté avec succes'
      redirect_to :action => 'index'
    else
      render :action => 'new'
    end
  end
    
  def show
    @supplier = Supplier.find(params[:id])
  end
  
  def edit
    @supplier = Supplier.find(params[:id])
  end
  
  def update
    @supplier = Supplier.find(params[:id])
    if @supplier.update_attributes(params[:supplier])
      redirect_to(suppliers_path)
    else
      render :action => 'edit'
    end    
  end
  
    # DELETE /supplier/1
  def destroy
    @supplier = Supplier.find(params[:id])
    @supplier.destroy
    redirect_to(suppliers_path) 
  end
end