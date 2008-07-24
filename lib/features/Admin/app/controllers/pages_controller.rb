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
        render :action => 'add'
      end
  end
  
  def edit
    @page = Osirails::Page.find(params[:id])
    @pages = Osirails::Page.get_pages_array("---")
  end
  
    def before_update
      unless @page.can_has_this_parent?(params[:page].parent_id)
        redirect_to :back
      end
    end

  def before_update
    unless @page.can_has_this_parent?(params[:page].parent_id)
      redirect_to :back
    end
  end
  
  def confirm_edit #FIXME Can't use update.... 
    @page = Osirails::Page.find(params[:id])
      if @page.update_attributes(params[:page])
      flash[:notice] = 'Your page is edit'
      redirect_to :action => 'index'
    else
      render :action => 'edit'
    end
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
    page.delete_item
    redirect_to pages_path
  end 
end
