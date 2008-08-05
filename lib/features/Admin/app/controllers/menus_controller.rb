class MenusController < ApplicationController
  # Add permissions for methods
  method_permission(:edit => ['move_up', 'move_down'])
  
  # GET /menus
  def index
    # get_structured_menus permit to make a indent for menu's list
    #FIXME Manage CSS for indent
    @menus = Menu.get_structured_menus("__")#("<span class='admin_menus_indent'/>")
  end
  
  # GET /menus/new
  def new
    @menu = Menu.new
    # get_structured_menus permit to make a indent for menu's list
    @menus = Menu.get_structured_menus("---")
  end
  
  # POST /menus
  def create
    @menu = Menu.new(params[:menu])
    # get_structured_menus permit to make a indent for menu's list
    @menus = Menu.get_structured_menus("----")
    if @menu.save
      flash[:notice] = 'Le menu a &eacute;t&eacute; cr&eacute;&eacute; avec succ&egrave;s'
      redirect_to :action => 'index'
    else
      render :action => 'new'
    end
  end
  
  # GET /menu/1/edit
  def edit
    @menu = Menu.find(params[:id])
    # get_structured_menus permit to make a indent for menu's list
    @menus = Menu.get_structured_menus("---")
  end
  
  # can_has_this_parent? => Permit to check if the new parent can has this parent
  # change_parent => method to change parent
  # 
  # PUT /menus/1
  def update
    @menu = Menu.find(params[:id])
    @menu.old_parent_id, @menu.update_parent = @menu.parent_id, true
    if @menu.update_attributes(params[:menu])
      redirect_to menus_path
    else
      flash[:error] = "Une erreur est survenue lors de la modification du menu"
      redirect_to :action => 'edit'
    end
  end
  
  # This method permit to move up a menu.
  def move_up
    menu = Menu.find_by_id(params[:id])
    menu.move_higher
    redirect_to menus_path
  end
  
  # This method permit to move down a menu.
  def move_down
    menu = Menu.find_by_id(params[:id])
    menu.move_lower
    redirect_to menus_path
  end
  
  # DELETE /menus/1
  def destroy
    menu = Menu.find_by_id(params[:id])
    if menu.can_delete_menu?
      if menu.destroy
        flash[:notice] = "Le menu a &eacute;t&eacute; supprim&eacute; avec succ&egrave;s"
      else 
        flash[:error] = "La suppression du menu a &eacute;chou&eacute;"
      end
    else 
      flash[:error] = "Impossible de supprimer ce menu"
    end
    redirect_to menus_path
  end 
end
