class MenusController < ApplicationController
  # Add permissions for methods
  method_permission :edit => ['move_up', 'move_down']
  
  # GET /menus
  def index
   @menus = Menu.mains.activated
  end
  
  # GET /menus/new
  def new
    @menu = Menu.new(:parent_id => params[:parent_menu_id])
    @menus = Menu.get_structured_menus
  end
  
  # POST /menus
  def create
    @menu = Menu.new(params[:menu])
    if @menu.save
      flash[:notice] = 'Le menu a été créé avec succès'
      redirect_to @menu
    else
      @menus = Menu.get_structured_menus
      render :action => 'new'
    end
  end
  
  # GET /menu/:id/edit
  def edit
    @menu = Menu.find(params[:id])
    @menus = Menu.get_structured_menus(@menu.id)
  end
  
  # PUT /menus/:id
  def update
    @menu = Menu.find(params[:id])
    @menu.old_parent_id, @menu.update_parent = @menu.parent_id, true
    if @menu.update_attributes(params[:menu])
      redirect_to @menu
    else
      @menus = Menu.get_structured_menus(@menu.id)
      render :action => 'edit'
    end
  end
  
  # GET /menus/:id/move_up
  def move_up
    menu = Menu.find_by_id(params[:id])
    unless menu.move_up
      flash[:error] = "Impossible de déplacer ce menu"
    end
    redirect_to menus_path
  end
  
  # GET /menus/:id/move_down
  def move_down
    menu = Menu.find_by_id(params[:id])
    unless menu.move_down
      flash[:error] = "Impossible de déplacer ce menu"
    end
    redirect_to menus_path
  end
  
  # DELETE /menus/:id
  def destroy
    menu = Menu.find_by_id(params[:id])
    if menu.can_delete_menu?
      if menu.destroy
        flash[:notice] = "Le menu a été supprimé avec succès"
      else 
        flash[:error] = "La suppression du menu a échoué"
      end
    else 
      flash[:error] = "Impossible de supprimer ce menu"
    end
    redirect_to menus_path
  end 
end
