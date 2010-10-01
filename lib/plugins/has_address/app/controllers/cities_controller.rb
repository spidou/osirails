class CitiesController < ApplicationController
  helper :address
  
  include AutoCompleteFor
  def auto_complete_for_city_zip_code
    auto_complete_for(:city, :zip_code)
  end
  
  def auto_complete_for_city_name
    auto_complete_for(:city, :name)
  end
end
