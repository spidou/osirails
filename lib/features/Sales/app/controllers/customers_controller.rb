class CustomersController < ApplicationController
#    auto_complete_for :city, :name
#  auto_complete_for :country, :name

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
  
  def auto_complete_for_city_name
    city_id = 7
    auto_complete_responder_for_name params[:city][:name]
  end
  
  def auto_complete_responder_for_name(value)
#    country = params['establishment7_address']['country_name']
    @cities = City.find(:all, 
    :conditions => [ 'LOWER(name) LIKE ?',
    '%' + value.downcase + '%' ], 
    :order => 'name ASC',
    :limit => 8)
    render :partial => 'names'
  end



  def update
    puts params['establishment7_address']['country_name<']
    @customer = Customer.find(params[:id])
    # @error is use to know if all form is valids
    @error = false
    
    unless @customer.update_attributes(params[:customer])
      @error = true
    end
    
    # For all customers's etablishment, an instance variable is create
    @customer.establishments.each do |establishment|
      unless establishment.activated == false
        puts params["establishment#{establishment.id}_address"]['city_id']
        choix_countries  = params["establishment#{establishment.id}"]["establishment_type_id"]
        @liste_cities = City.find_all_by_country_id(choix_countries, :order => "name asc")
        instance_variable_set("@establishment#{establishment.id}",Establishment.find(establishment.id))
        
        # If hidden_field to_delete is present for an establishment, his value activated is set to false  
        if params["establishment#{establishment.id}"]["to_delete"].nil?
          eval "unless @establishment#{establishment.id}.update_attributes(params['establishment#{establishment.id}']); @error = true; end;"
        else
          eval "@establishment#{establishment.id}.activated = false; @establishment#{establishment.id}.save"
        end
        
        eval "instance_variable_set('@establishment#{establishment.id}_address', @establishment#{establishment.id}.address)"
        eval "unless @establishment#{establishment.id}_address.update_attributes(params['establishment#{establishment.id}_address']); @error = true; end;"
      end
    end
    
    # If establishment_form is not null
    unless params[:new_establishment_number]["value"].nil?
      new_estbalishment_number = params[:new_establishment_number]["value"].to_i
      new_estbalishment_number.times do |i|
        # For all new_establishment and addresses,  an instance variable is create.
        # If his parameter is not valid, @error variable is set to true
        eval "unless params['valid#{i+1}']['value'] == 'false'
                instance_variable_set('@new_establishment#{i+1}', Establishment.new(params[:new_establishment#{i+1}]))
                instance_variable_set('@new_establishment_address#{i+1}', Address.new(params[:new_establishment_address#{i+1}]))
                unless @new_establishment#{i+1}.address = @new_establishment_address#{i+1}
                  @error = true
                end
                unless @new_establishment#{i+1}.valid?
                  @error = true
                end
                unless @new_establishment_address#{i+1}.valid?
                  @error = true
                end
                end"
      end
      # If all new_establishment and addresses are valids, they are save 
      unless @error
        new_estbalishment_number.times do |i|
          eval"unless params['valid#{i+1}']['value'] == 'false'
                unless @new_establishment_address#{i+1}.save
                    @error = true
                else
                  unless @customer.establishments << @new_establishment#{i+1}
                    @error = true
                  end
                end
                unless @new_establishment#{i+1}.save
                  @error = true
                end
                 end"
        end
      end
    end
    unless @error
      redirect_to(customers_path)
    else
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