class CommoditiesManagerController < ApplicationController

  def index
    @type = params[:type]
  end

end