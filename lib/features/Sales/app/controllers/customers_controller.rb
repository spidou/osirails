  class CustomersController < ApplicationController

  def index
    @customers = Customer.find(:all)
  end

  def new
    @customer = Customer.new
  end

  def create
    if ActivitySector.find_by_name(params[:new_activity_sector1][:name]).nil?
      @new_activity_sector1 = ActivitySector.new(:name => params[:new_activity_sector1][:name])
      @new_activity_sector1.save
    end
    activity_sector = ActivitySector.find_by_name(params[:new_activity_sector1][:name])    
    @customer = Customer.new(params[:customer])
    @customer.activity_sector = activity_sector
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
    @activity_sector = @customer.activity_sector.name unless @customer.activity_sector.nil?
  end

  def update
    @customer = Customer.find(params[:id])
    @address = @customer.address
    
    # @error is use to know if all form are valids
    @error = false
    
    if ActivitySector.find_by_name(params[:new_activity_sector1][:name].capitalize).nil?
      activity_sector = ActivitySector.new(:name => params[:new_activity_sector1][:name])
      if activity_sector.valid?
        activity_sector.save
      end
    end
    activity_sector = ActivitySector.find_by_name(params[:new_activity_sector1][:name])
    params[:customer][:activity_sector_id] = activity_sector.id
    unless @customer.update_attributes(params[:customer])
      @error = true
    end
    
    # If establishment_form is not null
    unless params[:new_establishment_number]["value"] == 0
      puts params[:new_establishment_number]["value"]
      new_estbalishment_number = params[:new_establishment_number]["value"].to_i
      new_estbalishment_number.times do |i|
   
        # For all new_establishment and addresses,  an instance variable is create.
        # If his parameter is not valid, @error variable is set to true
        eval "
                unless params['valid_establishment_#{i+1}'].nil?
                
                  params['new_establishment_address#{i+1}'][:country_name] = params['new_country#{i+1}'][:name]
                  params['new_establishment_address#{i+1}'][:city_name] = params['new_city#{i+1}'][:name]
                  params['new_establishment_address#{i+1}'][:zip_code] = params['new_city#{i+1}'][:zip_code]

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
          eval"
                unless params['valid_establishment_#{i+1}'].nil?
                  unless params['valid_establishment_#{i+1}']['value'] == 'false'
                    unless @new_establishment_address#{i+1}.save
                        @error = true
                    else
                      unless @customer.establishments << @new_establishment#{i+1}
                        @error = true
                       else

                      country = Country.find_by_name(params['new_country#{i+1}'][:name])
                        unless country.nil?
                          new_country = Country.create(:name => params['new_country#{i+1}'][:name])
                          city = City.new(
                            :name => params['new_city#{i+1}'][:name], 
                            :zip_code => params['new_city#{i+1}'][:zip_code], 
                            :country_id => new_country.id)
                          if country.valid? and city.valid?
                            country.save
                            city.save
                          end
                        end
                        unless City.find_by_name_and_country_id(params['new_country#{i+1}'][:name], country.id).nil? and country.nil?
                          city = City.new(
                            :name => params['new_city#{i+1}'][:name], 
                            :zip_code => params['new_city#{i+1}'][:zip_code], 
                            :country_id => country.id)
                          if city.valid?
                            city.save
                          else 
                            @error = false
                          end
                        end

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
                     if @new_contact#{i+1} and params['new_contact#{i+1}']['id'] == ''
                       unless @customer.contacts << @new_contact#{i+1}
                       @error = true
                       end
                       unless @new_contact#{i+1}.save
                         @error = true
                       end
                     elsif params['new_contact#{i+1}_id'] != ''                        
                       if @customer.contacts.include?(Contact.find(params['new_contact#{i+1}']['id'])) == false                    
                         @customer.contacts << Contact.find(params['new_contact#{i+1}']['id'])
                       end
                     else
                       @error = true
                     end
                  end
                end"
      end
    end
        
    unless @error
      redirect_to(customers_path)
    else
      @activity_sector = params[:activity_sector][:name]
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
  
  def auto_complete_for_activity_sector_name
    puts params.keys
    auto_complete_responder_for_name(params[:value])
  end
  
  def auto_complete_responder_for_name(value)
    @activity_sectors = ActivitySector.find(:all, 
      :conditions => [ 'LOWER(name) LIKE ?',
        '%' + value.downcase + '%'], 
      :order => 'name ASC',
      :limit => 8)
    render :partial => 'thirds/activity_sectors'
  end
end