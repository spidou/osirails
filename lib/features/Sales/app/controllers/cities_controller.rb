class CitiesController < ApplicationController
  def index
  @cities = City.find(:all, :conditions => ['name LIKE ?', "%#{params[:search]}%"])
end
end