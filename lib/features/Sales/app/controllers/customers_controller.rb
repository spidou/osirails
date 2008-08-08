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
    @establishments = @customer.establishments
  end

  def update
    @customer = Customer.find(params[:id])
    # ok is use to know if all form is valide
    ok = true
    
    unless @customer.update_attributes(params[:customer])
      ok = false
    end
    
    # For all customers's etablishment, an instance variable is create
    @customer.establishments.each do |establishment|
      unless establishment.activated == false
        instance_variable_set("@establishment#{establishment.id}",Establishment.find(establishment.id))
        
        # If hidden_field to_delete is present for an establishment, his value activated is set to false  
        if params["establishment#{establishment.id}"]["to_delete"].nil?
          eval "unless @establishment#{establishment.id}.update_attributes(params['establishment#{establishment.id}']); ok = false; end;"
        else
          eval "@establishment#{establishment.id}.activated = false; @establishment#{establishment.id}.save"
        end
        
        eval "instance_variable_set('@establishment#{establishment.id}_address', @establishment#{establishment.id}.address)"
        eval "unless @establishment#{establishment.id}_address.update_attributes(params['establishment#{establishment.id}_address']); ok = false; end;"
      end
    end
    
    unless params[:new_establishment_number]["value"].nil?
      new_estbalishment_number = params[:new_establishment_number]["value"].to_i
      new_estbalishment_number.times do |i|
        eval "unless params['valid#{i+1}']['1'] == 'false'
                instance_variable_set('@new_establishment#{i+1}', Establishment.new(params[:new_establishment#{i+1}]))
                instance_variable_set('@new_establishment_address#{i+1}', Address.new(params[:new_establishment_address#{i+1}]))
                unless @new_establishment#{i+1}.address = @new_establishment_address#{i+1}
                      ok = false
                end
                unless @new_establishment#{i+1}.valid?
                  ok = false
                end
                unless @new_establishment_address#{i+1}.valid?
                  ok = false
                end
                end"
      end
#      puts params[:valid1]['1'] unless params[:valid1].nil?
#      puts params[:valid2]['1'] unless params[:valid2].nil?
      if ok
        new_estbalishment_number.times do |i|
          eval"unless params['valid#{i+1}']['1'] == 'false'
                unless @new_establishment_address#{i+1}.save
                    ok = false
                else
                  unless @customer.establishments << @new_establishment#{i+1}
                    ok = false
                  end
                end
                unless @new_establishment#{i+1}.save
                  ok = false
                end
                 end"
      end
    end
  end
  if ok
    redirect_to(customers_path)
  else
    @error = true
    @new_number_form = params[:new_establishment_number]["value"]
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