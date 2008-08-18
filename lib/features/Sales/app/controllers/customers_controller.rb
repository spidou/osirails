class CustomersController < ApplicationController
  
  # Put here the code for auto_complete :contact :name

  def index
    @customers = Customer.find(:all)
  end

  def new
    @customer = Customer.new
  end

  def create
    @customer = Customer.new(params[:customer])
    if @customer.save
      flash[:notice] = "Client ajouté avec succes"
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
    @contacts = @customer.contacts
  end

  def update
    @customer = Customer.find(params[:id])
    # @error is use to know if all form is valids
    @error = false
    
    unless @customer.update_attributes(params[:customer])
      @error = true
    end
    
    # If establishment_form is not null
    unless params[:new_establishment_number]["value"].nil?
      new_estbalishment_number = params[:new_establishment_number]["value"].to_i
      new_estbalishment_number.times do |i|
        # For all new_establishment and addresses,  an instance variable is create.
        # If his parameter is not valid, @error variable is set to true
        eval "unless params['valid_establishment_#{i+1}'].nil? 
                unless params['valid_establishment_#{i+1}']['value'] == 'false'
                instance_variable_set('@new_establishment#{i+1}', Establishment.new(params[:new_establishment#{i+1}]))
                params[:new_establishment_address#{i+1}].delete('zip_code')
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
                end
                end"
      end

      # If all new_establishment and addresses are valids, they are save 
      unless @error
        new_estbalishment_number.times do |i|
          eval"unless params['valid_establishment_#{i+1}'].nil?
                unless params['valid_establishment_#{i+1}']['value'] == 'false'
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
                 end
                end"
        end
      end
    end
    
    # If contact_form is not null
    
    unless params[:new_contact_number]["value"].nil?
      new_contact_number = params[:new_contact_number]["value"].to_i
      new_contact_number.times do |i|   
        # For all new_contact  an instance variable is create.
        # If his parameter is not valid, @error variable is set to true
        eval "unless params['valid_contact_#{i+1}'].nil?
                    unless params['valid_contact_#{i+1}']['value'] == 'false'
                      unless instance_variable_set('@new_contact#{i+1}', Contact.new(params[:new_contact#{i+1}]))
                          @error = true
                      end
                      unless @new_contact#{i+1}.valid?
                          @error = true
                      end
                    end
                  end"
      end
    end
    
    # If all new_contact are valids, they are save 
      unless @error
        new_contact_number.times do |i|
          eval"unless params['valid_contact_#{i+1}'].nil?
                     unless params['valid_contact_#{i+1}']['value'] == 'false'
                       if @new_contact#{i+1}
                         unless @new_contact#{i+1}.save
                          @error = true
                        else
                          @customer.contacts << Contact.last
                        end
                      end
                    end
                  end"
        end
      end
    unless @error
      redirect_to(customers_path)
    else
      @new_establishment_number = params[:new_establishment_number]["value"]
      @new_contact_number = params[:new_contact_number]["value"]
      @establishments = @customer.establishments
      @contacts = @customer.contacts
      render :action => 'edit'
    end
  end

  def destroy
    @customer = Customer.find(params[:id])
    @customer.destroy
    redirect_to(customers_path) 
  end
  
  def auto_complete_for_country_name
    index = params[:country].keys[0]
    auto_complete_responder_for_country_name(params[:country][index][:name])
  end
  
  def auto_complete_responder_for_country_name(value)
    @countries = Country.find(:all, 
      :conditions => [ 'LOWER(name) LIKE ?',
        '%' + value.downcase + '%'], 
      :order => 'name ASC',
      :limit => 8)
    render :partial => 'country_name'
  end
  
  #FIXME Change the code to take in consideration the fact that it can have many city with the same name
  def auto_complete_for_city_name
    index = params[:city].keys[0]
    auto_complete_responder_for_name(params[:city][index][:name],params[:country_id])
  end
  
  def auto_complete_responder_for_name(value,country_id = 1)
    @cities = City.find(:all, 
      :conditions => [ 'LOWER(name) LIKE ? AND country_id = ?',
        '%' + value.downcase + '%', country_id], 
      :order => 'name ASC',
      :limit => 8)
    render :partial => 'names'
  end
  
  def auto_complete_for_city_zip_code
    index = params[:city].keys[0]
    auto_complete_responder_for_zip_code(params[:city][index][:zip_code],params[:country_id])
  end
  
  def auto_complete_responder_for_zip_code(value,country_id = 1)
    @codes = City.find(:all, 
      :conditions => [ 'zip_code LIKE ? AND country_id = ?',
        '%' + value.to_s + '%', country_id], 
      :order => 'name ASC',
      :limit => 8)
    render :partial => 'zip_codes'
  end

end