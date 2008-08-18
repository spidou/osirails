class EstablishmentsController < ApplicationController
  def edit
    @establishment = Establishment.find(params[:id])
    @customer = Customer.find(params[:customer_id])
#    City.find_by_name(@establishment.address.city_name).nil? ? @zip_code = "" : 
#    @zip_code = City.find_by_name(@establishment.address.city_name, :conditions => ["country_id = ?", Country.find_by_name(@establishment.address.country_name)]).zip_code 
  end
  
  def update
    @establishment = Establishment.find(params[:id])
    @address = @establishment.address
    @customer = Customer.find(params[:customer_id])
      
    params[:address][:country_name] = params[:country][:name]
    params[:address][:city_name] = params[:city][:name]
    params[:address][:zip_code] = params[:city][:zip_code]
    
    # A revoir si la ville ,n'esxiste pas ainsi que le pays
    if Country.find_by_name(params[:country][:name]).nil?
      Country.create(:name => params[:country][:name])
    end
    
    if City.find_by_name(params[:city][:name]).nil?
        City.create(:name => params[:city][:name], 
          :zip_code => params[:city][:zip_code], 
          :country_id => Country.find_by_name(params[:country][:name]).id)
    end
    
#    if City.find_by_name(params[:city][:name]).nil? or
#      City.find_by_name(params[:city][:name]).country_id != Country.find_by_name(params[:country][:name]).id      
#        City.create(:name => params[:city][:name], 
#          :zip_code => params[:city][:zip_code], 
#          :country_id => Country.find_by_name(params[:country][:name]).id)
#    end
    
    @establishment.update_attributes(params[:establishment])
    @address.update_attributes(params[:address])
    
    #FIXME Change this redirect_to by render
    redirect_to(edit_customer_establishment_path(@customer,@establishment))
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
  
  #FIXME Change the code to take in consideration the fact that it can have many city with the same name
  def auto_complete_for_city_name
    puts params.keys
    auto_complete_responder_for_name(params[:city][:name], params[:country_id])
  end
  
  def auto_complete_responder_for_name(value,country_id = 1)
    @cities = City.find(:all, 
      :conditions => [ 'LOWER(name) LIKE ? AND country_id = ?',
        '%' + value.downcase + '%', country_id], 
      :order => 'name ASC',
      :limit => 8)
    render :partial => 'addresses/cities'
  end
  
  def auto_complete_for_city_zip_code
    auto_complete_responder_for_zip_code(params[:city][:zip_code],params[:country_id])
  end
  
  def auto_complete_responder_for_zip_code(value,country_id = 1)
    @cities = City.find(:all, 
      :conditions => [ 'zip_code LIKE ? AND country_id = ?',
        '%' + value.to_s + '%', country_id], 
      :order => 'name ASC',
      :limit => 8)
    render :partial => 'addresses/zip_codes'
  end
  
  def destroy
    @establishment = Establishment.find(params[:id])
    @customer = @establishment.customer
    @establishment.destroy
    redirect_to(edit_customer_establishment_path(@customer,@establishment)) 
  end
end