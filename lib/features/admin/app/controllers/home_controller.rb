class HomeController < ApplicationController
  
  def index
    @menus = Menu.mains.activated.select{|m|m.can_access?(current_user)}
  end
  
end
