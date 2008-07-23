class PagesController < ApplicationController
  def index
    list
   render :action => 'list'
  end
  
  def list
    @parent_page = Osirails::Page.find_all_by_parent_id(nil)
    Osirails::Page.get_structure(@parent_page)
    
    @pa = Osirails::Page.parent_array
    
  end
  
end
