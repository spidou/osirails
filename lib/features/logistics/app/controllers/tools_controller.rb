class ToolsController < ApplicationController
  
  # GET /tools
  def index
    @menus = Menu.find_by_name('tools').children
  end
  
end
