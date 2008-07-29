class StaticPagesController < ApplicationController

  def index
    @static_pages = StaticPage.find(:all)
  end
  
  def edit
    @static_page = StaticPage.find(params[:id])
  end
end
