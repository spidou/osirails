class CountriesController < ApplicationController
  helper :address
  
  include AutoCompleteFor
  def auto_complete_for_country_name
    auto_complete_for(:country, :name)
  end
end
