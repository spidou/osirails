class PagesController < ApplicationController
  
  def index
    list
    render :action => 'list'
  end
  
  def list
    @pages = Page.get_pages_array("----")
  end

  def new
    @page = Page.new
    @pages = Page.get_pages_array("---")
  end
  
  def create
    @pages = Page.get_pages_array("----")
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
  def update
    @pages = Page.get_pages_array("----")
    @page = Page.find(params[:id])
    parent_id =params[:page].delete(:parent_id)
    if @page.can_has_this_parent?(parent_id)          
      if @page.update_attributes(params[:page])
        @page.change_parent(parent_id)
        redirect_to pages_path
      else
#        flash[:error] = "Erreur lors de la mise a jour de la page" 
        render :action => 'edit'
      end
    else
      flash[:error] = "Déplacement impossible"
      redirect_to :back
    end
    
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
