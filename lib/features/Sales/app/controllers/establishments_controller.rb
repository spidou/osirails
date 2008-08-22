class EstablishmentsController < ApplicationController
  
  protect_from_forgery :except => [:auto_complete_for_city_name]
  
  def edit
    @establishment = Establishment.find(params[:id])
    @customer = Customer.find(params[:customer_id])
    @contacts = @establishment.contacts

  end
  
  def update
    @error = false
    
    @establishment = Establishment.find(params[:id])
    @address = @establishment.address
    @customer = Customer.find(params[:customer_id])
    @contacts = @establishment.contacts
      
    params[:address][:country_name] = params[:new_country1][:name]
    params[:address][:city_name] = params[:new_city1][:name]
    params[:address][:zip_code] = params[:new_city1][:zip_code]
    
    country = Country.find_by_name(params[:country][:name])
    if country.nil?
      new_country = Country.new(:name => params[:country][:name])
      city = City.new(
          :name => params[:city][:name], 
          :zip_code => params[:city][:zip_code], 
          :country_id => new_country.id)
        if country.valid? and city.valid?
          country.save
          city.save
        end
    elsif City.find_by_name_and_country_id(params[:country][:name], country.id).nil?
      city = City.new(
          :name => params[:city][:name], 
          :zip_code => params[:city][:zip_code], 
          :country_id => country.id)
        if city.valid?
          city.save
        end   
    end
    
    @establishment.update_attributes(params[:establishment])
    @address.update_attributes(params[:address])
    
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
                         unless @new_contact#{i+1}.save and @customer.contacts << @new_contact#{i+1}
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
    
    if @error
      @new_contact_number = params[:new_contact_number]["value"]
      render :action => "edit"
    else
      redirect_to(edit_customer_establishment_path(@customer,@establishment))
    end
  end
  
  def auto_complete_for_country_name
    puts params.keys
    auto_complete_responder_for_country_name(params[:country][:name])
  end
  
  def auto_complete_responder_for_country_name(value)
    @countries = Country.find(:all, 
      :conditions => [ 'LOWER(name) LIKE ?',
        '%' + value.downcase + '%'], 
      :order => 'name ASC',
      :limit => 8)
    render :partial => 'addresses/countries'
  end
  
  def auto_complete_for_city_name
    country_id = Country.find_by_name("#{params[:country_name]}")
    auto_complete_responder_for_name(params[:city_name], country_id)
  end
  
  def auto_complete_responder_for_name(value,country_id = 1)
    @cities = City.find(:all, 
      :conditions => [ 'LOWER(name) LIKE ? AND country_id = ?',
        '%' + value.downcase + '%', country_id], 
      :order => 'name ASC',
      :limit => 8)
    render :partial => 'addresses/cities_name'
  end
  
  def auto_complete_for_city_zip_code
    country_id = Country.find_by_name("#{params[:country_name]}")
    auto_complete_responder_for_zip_code(params[:city_zip_code], country_id)
  end
  
  def auto_complete_responder_for_zip_code(value,country_id = 1)
    @cities = City.find(:all, 
      :conditions => [ 'zip_code LIKE ? AND country_id = ?',
        '%' + value.to_s + '%', country_id], 
      :order => 'name ASC',
      :limit => 8)
    render :partial => 'addresses/cities_zip_code'
  end
  
  def destroy
    @establishment = Establishment.find(params[:id])
    @customer = @establishment.customer
    @establishment.destroy
    redirect_to(edit_customer_path(@customer)) 
  end
end