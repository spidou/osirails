class PagesController < ApplicationController
  
  def index
    @pages = Page.get_pages_array("----")
    render :action => 'list'
  end
  
  def show
    render :action => 'list'
  end

  def new
    @page = Page.new
    @pages = Page.get_pages_array("---")
  end
  
  def create
    @page = Page.new(params[:page])
    if @page.save
      flash[:notice] = 'Your page is create.'
      redirect_to :action => 'index'
    else
      render :action => 'new'
    end
  end
  
  def edit
    @page = Page.find(params[:id])
    @pages = Page.get_pages_array("---")
  end

  # This method permit to edit page
  # unless params => Permit to utilize a nil field
  # can_has_this_parent? => Permit to check if the new parent can has this parent
  # change_parent => method to change parent  
  def confirm_edit #FIXME Can't use update....  
    @page = Page.find(params[:id])
    parent_id =params[:page].delete(:parent_id)
    if @page.can_has_this_parent?(parent_id)          
      if @page.update_attributes(params[:page])
        @page.change_parent(parent_id)
      else
        flash[:error] = "Erreur lors de la mise a jour de la page" 
      end
    end
    redirect_to pages_path
  end
  
  def move_up
    page = Page.find_by_id(params[:id])
    page.move_higher
    redirect_to pages_path
  end
  
  def move_down
    page = Page.find_by_id(params[:id])
    page.move_lower
    redirect_to pages_path
  end
  
  def destroy
    page = Page.find_by_id(params[:id])
    if page.can_delete?
      if page.destroy
        flash[:notice] = "Page supprimer avec succes"
      else 
        flash[:error] = "La suppression de la page a échouée"
      end
    else 
      flash[:error] = "Cette page n'est pas supprimable"
    end
    redirect_to pages_path
  end 
end
