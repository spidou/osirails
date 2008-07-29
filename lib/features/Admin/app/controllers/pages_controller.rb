class PagesController < ApplicationController
 
 # This method permit to list all pages
 # get_structured_pages permit to make a indent for page's list
  def index
    @pages = Page.get_structured_pages("<span class='admin_pages_indent'/>") #FIXME Manage CSS for indent
  end

  # This method permit to make a new page
  # get_structured_pages permit to make a indent for page's list
  def new
    @page = Page.new
    @pages = Page.get_structured_pages("---")
  end
  
    # This method permit to validate new page
    # get_structured_pages permit to make a indent for page's list
  def create
    @pages = Page.get_structured_pages("----")
    @page = Page.new(params[:page])
    if @page.save
      flash[:notice] = 'Votre page est créée avec succes'
      redirect_to :action => 'index'
    else
      render :action => 'new'
    end
  end
  
  # This method permit to edit a page
  # get_structured_pages permit to make a indent for page's list
  def edit
    @page = Page.find(params[:id])
    @pages = Page.get_structured_pages("---")
  end

  # This method permit to validate a page edition
  # can_has_this_parent? => Permit to check if the new parent can has this parent
  # change_parent => method to change parent
  # get_structured_pages permit to make a indent for page's list  
  def update
    @pages = Page.get_structured_pages("----")
    @page = Page.find(params[:id])
    parent_id =params[:page].delete(:parent_id)
    if @page.can_has_this_parent?(parent_id)          
      if @page.update_attributes(params[:page])
        @page.change_parent(parent_id)
        redirect_to pages_path
      else
        flash[:error] = "Erreur lors de la mise à jour de la page" 
        render :action => 'edit'
      end
    else
      flash[:error] = "Déplacement impossible"
      redirect_to :back
    end
  end
  
  # This method permit to move up a page.
  def move_up
    page = Page.find_by_id(params[:id])
    page.move_higher
    redirect_to pages_path
  end
  
  # This method permit to move down a page.
  def move_down
    page = Page.find_by_id(params[:id])
    page.move_lower
    redirect_to pages_path
  end
  
  # This method permit to destroy a page
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
