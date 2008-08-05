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
      flash[:notice] = 'Tiers ajouté avec succes'
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
    @customer = Customer.find(params[:id])
    @customer.update_attributes(params[:customer])
    redirect_to(customers_path)
  end
  
    # DELETE /supplier/1
  def destroy
    @supplier = Supplier.find(params[:id])
    @supplier.destroy
    redirect_to(suppliers_path) 
  end
end