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
    @new_establishment =Establishment.new
    ok = true
    unless @customer.update_attributes(params[:customer])
      ok = false
    end
    @customer.establishments.each do |establishment|
      unless establishment.activated == false
        instance_variable_set("@establishment#{establishment.id}",Establishment.find(establishment.id))
        if params["establishment#{establishment.id}"]["to_delete"].nil?
          eval "unless @establishment#{establishment.id}.update_attributes(params['establishment#{establishment.id}']); ok = false; end;"
        else
          eval "@establishment#{establishment.id}.activated = false; @establishment#{establishment.id}.save"
        end
        eval "instance_variable_set('@establishment#{establishment.id}_address', @establishment#{establishment.id}.address)"
        eval "unless @establishment#{establishment.id}_address.update_attributes(params['establishment#{establishment.id}_address']); ok = false; end;"
      end
    end

    unless params[:new_establishment_number].nil?
      new_estbalishment_number = params[:new_establishment_number].keys.last.to_i
      new_estbalishment_number.times do |i|
        eval "instance_variable_set('@new_establishment#{i+1}', Establishment.new(params[:new_establishment#{i+1}]))
                unless @new_establishment#{i+1}.save
                  ok = false
                  else
                  unless @customer.establishments << @new_establishment#{i+1}
                      ok = false
                  end
                end
                instance_variable_set('@new_establishment_address#{i+1}', Address.new(params[:new_establishment_address#{i+1}]))
                unless @new_establishment_address#{i+1}.save
                    @new_establishment#{i+1}.destroy
                    ok = false
                 else
                    
                    unless @new_establishment#{i+1}.address = @new_establishment_address#{i+1}
                      @new_establishment#{i+1}.destroy
                      ok = false
                    end
                end"
      end
    end
    if ok
      redirect_to(customers_path)
    else
      @error = true
      @establishments = @customer.establishments
      render :action => 'edit'
    end
  end


  def destroy
    @customer = Customer.find(params[:id])
    @customer.destroy
    redirect_to(customers_path) 
  end

end