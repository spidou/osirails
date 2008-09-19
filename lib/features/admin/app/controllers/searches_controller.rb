class SearchesController < ApplicationController
  
  def index
    @searches = {}
    Feature.find(:all).each do |feature|
      unless feature.search.nil?
          @searches = @searches.merge({feature.name => feature.search.keys})
      end  
    end
  end

end