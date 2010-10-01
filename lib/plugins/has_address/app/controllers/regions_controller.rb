class RegionsController < ApplicationController
  helper :address
  
  include AutoCompleteFor
  def auto_complete_for_region_name
    auto_complete_for(:region, :name)
  end
end
