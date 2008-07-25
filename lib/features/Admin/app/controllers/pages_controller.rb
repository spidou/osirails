class PagesController < ApplicationController
  def index
   @pages = Osirails::Page.get_pages_array("----")
   render :action => 'list'
  end

  def new
   @page = Osirails::Page.new
   @pages = Osirails::Page.get_pages_array("---")
  end
  
  def create
    @page = Osirails::Page.new(params[:page])
      if @page.save
      flash[:notice] = 'Your page is create.'
        redirect_to :action => 'index'
      else
        render :action => 'new'
      end
  end
  
  def edit
    @page = Osirails::Page.find(params[:id])
    @pages = Osirails::Page.get_pages_array("---")
  end
  
  def confirm_edit #FIXME Can't use update....
    
    @page = Osirails::Page.find(params[:id])
    
    unless params[:page][:parent_id] == ""
      @parent = Osirails::Page.find(params[:page][:parent_id])   
      if @page.can_has_this_parent?(Osirails::Page.find(params[:page][:parent_id]))
        if @page.change_parent(@parent)
          flash[:notice] = 'Your page is edit'
        end
      else
        flash[:error] = "Deplacement impossible"
      end
    else
      @page.change_parent(nil)
    end
    
    redirect_to :action => 'index'

  end
  
  def move_up
    page = Osirails::Page.find_by_id(params[:id])
    page.move_higher
    redirect_to pages_path
  end
  
  def move_down
    page = Osirails::Page.find_by_id(params[:id])
    page.move_lower
    redirect_to pages_path
  end
  
  def delete
    page = Osirails::Page.find_by_id(params[:id])
    page.delete
    redirect_to pages_path
  end 
end