class HomeController < ApplicationController
  
  def index
    @menus = Menu.mains.activated
  end
  
end
