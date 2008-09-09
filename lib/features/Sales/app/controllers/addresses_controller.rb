class AddressesController < ApplicationController
  
  #OPTIMIZE make possible to scroll in the ul div
  def auto_complete_for_country_name
    auto_complete_responder_for_country_name(params[:value])
  end
  
  def auto_complete_responder_for_country_name(value)
    @countries = Country.find(:all, 
      :conditions => [ 'LOWER(name) LIKE ?',
        '%' + value.downcase + '%'], 
      :order => 'name ASC',
      :limit => 10)
    render :partial => 'addresses/countries'
  end
  
  def auto_complete_for_city_name
    country = Country.find_by_name("#{params[:country_name]}")
    if country.nil?
      country_id = 0
    else
      country_id = country.id
    end
    auto_complete_responder_for_name(params[:value], country_id)
  end
  
  def auto_complete_responder_for_name(value,country_id)
    if country_id != 0
      @cities = City.find(:all, 
        :conditions => [ 'LOWER(name) LIKE ? AND country_id = ?',
          '%' + value.downcase + '%', country_id], 
        :order => 'name ASC',
        :limit => 10)
      puts @cities.size
      render :partial => 'addresses/cities_name'
    else 
      @cities = City.find(:all, 
        :conditions => [ 'LOWER(name) LIKE ?',
          '%' + value.downcase + '%'], 
        :order => 'name ASC',
        :limit => 10)     
      render :partial => 'addresses/cities_name'
    end
  end
  
  def auto_complete_for_city_zip_code
   country = Country.find_by_name("#{params[:country_name]}")
    if country.nil?
      country_id = 0
    else
      country_id = country.id
    end
    
      auto_complete_responder_for_zip_code(params[:value], country_id)
  end
  
  def auto_complete_responder_for_zip_code(value,country_id)
    if country_id != 0
      @cities = City.find(:all,
        :conditions => [ 'zip_code LIKE ? AND country_id = ?',
          '%' + value.to_s + '%', country_id], 
        :order => 'name ASC',
        :limit => 10)
      render :partial => 'addresses/cities_zip_code'
    else
      @cities = City.find(:all,
        :conditions => [ 'zip_code LIKE ?',
          '%' + value.to_s + '%'], 
        :order => 'name ASC',
        :limit => 10)
      render :partial => 'addresses/cities_zip_code'
    end    
  end
  
end
