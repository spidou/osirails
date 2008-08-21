class AddressesController < ApplicationController
  
  def auto_complete_for_country_name
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
    auto_complete_responder_for_name(params[:city][:name], params[:country_id])
  end
  
  def auto_complete_responder_for_name(value,country_id = 1)
    @cities = City.find(:all, 
      :conditions => [ 'LOWER(name) LIKE ?',
        '%' + value.downcase + '%'], 
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
  
end
