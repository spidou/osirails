class CustomersController < ApplicationController
  def index
    @customers = Customer.find(:all)
  end
  
  def new
    @customer = Customer.new
  end
  
  def create
    @customer = Customer.new(params[:third])
    if @customer.save
      flash[:notice] = 'Tiers ajouté avec succes'
      redirect_to :action => 'index'
    end
  end
    
  def show
    @customer = Customer.find(params[:id])
  end
  
  def edit
    @customer = Customer.find(params[:id])
  end
end