class CustomersController < ApplicationController
  def index
    @customers = Customer.find(:all)
  end
  
  def new
    @customer = Customer.new
  end
  
  def create
    @customer = Customer.new(params[:customer])
    if @customer.save
      flash[:notice] = "Tiers ajouté avec succes"
      redirect_to :action => 'index'
    else
      render :action => 'new'
    end
  end
    
  def show
    @customer = Customer.find(params[:id])
  end
  
  def edit
    @customer = Customer.find(params[:id])
  end
  
  def update
    @customer = Customer.find(params[:id])
    @customer.update_attributes(params[:customer])
    redirect_to(customers_path)
  end
  
  def destroy
    @customer = Customer.find(params[:id])
    @customer.destroy
    redirect_to(customers_path) 
  end
  
end