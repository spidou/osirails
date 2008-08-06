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
      flash[:notice] = "Fournisseur ajouté avec succes"
      redirect_to :action => 'index'
    else
      render :action => 'new'
    end
  end
    
  def show
    @customer = Customer.find(params[:id])
    @establishments = @customer.establishments
  end
  
  def edit
    @customer = Customer.find(params[:id])
    @new_establishment = Establishment.new
    @establishments = @customer.establishments
    @new_address = Address.new
  end
  
  def update
    @customer = Customer.find(params[:id])
    @establishments = @customer.establishments
    @new_establishment =Establishment.new
    ok = true
    unless @customer.update_attributes(params[:customer])
      ok = false
    end
    
    params[:establishment].each_pair do |k,v| (
        puts params[:establishment][k][:id]
        @establishment = Establishment.find(params[:establishment][k][:id])
        unless @establishment.update_attributes(params[:establishment][k])
          ok = false
        end
      
        @address = @establishment.address
        unless @address.update_attributes(params[:establishment_address][k])
          ok = false
        end   
      )
      if ok
        redirect_to(customers_path)
      else
        render :action => 'edit'
      end
    end
  end
  
  def destroy
    @customer = Customer.find(params[:id])
    @customer.destroy
    redirect_to(customers_path) 
  end
  
end