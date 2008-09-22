class SearchesController < ApplicationController
  
  def index
    @searches = {}
    Feature.find(:all).each do |feature|
      unless feature.search.nil?
          @searches = @searches.merge({feature.name => feature.search.keys})
      end  
    end
  end
  
  def update
    
    flash.now[:notice]= params.inspect
    @searches = {}
    respond_to do |format|
      format.js {render :action => "result", :layout => false}
    end
  end
  
end
