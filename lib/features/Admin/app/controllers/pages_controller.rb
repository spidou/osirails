class PagesController < ApplicationController
  def index
    @pages = Osirails::Page.find_all_by_parent_id(nil,:order => :position)
    @conteur_list = 0
    render :action => 'list'
  end
  
  def change_position
    page = params[params[:list_name]] #FIXME Mettre ce code dans le model
    Osirails::Page.move(page)
  end

  # This method permit to access to form of create a new page
  def new
    @page = Osirails::Page.new
    @pages = Osirails::Page.get_pages_array("---")
  end
  
  # This method permit to create the new page
  def create
    @page = Osirails::Page.new(params[:page])
    if @page.save
        flash [:notice] => "Votre page est créée."
      redirect_to :action => 'index'
    else
      render :action => 'new'
    end
  end
  
  # This method permit to access to form of edit a page
  def edit
    @page = Osirails::Page.find(params[:id])
    @pages = Osirails::Page.get_pages_array("---")
  end
  
  def confirm_edit #FIXME Can't use update....    
    @page = Osirails::Page.find(params[:id])    
    unless params[:page][:parent_id] == ""
      if @page.can_has_this_parent?(Osirails::Page.find(params[:page][:parent_id]))
        @page.title_link = params[:page][:title_link]
        @page.description_link = params[:page][:description_link]
        @page.save
        if @page.change_parent(@parent)
          flash[:notice] = 'Votre page est éditée.'
        end
      else
        flash[:error] = 'Déplacement impossible. Vérifiez le champs parents'
      end
    else
      @page.title_link = params[:page][:title_link]
      @page.description_link = params[:page][:description_link]
      @page.change_parent(nil)
      @page.save
      flash[:notice] = 'Your page is edit'
    end    
    redirect_to :action => 'index'
  end
  
  #  def move_up
  #    page = Osirails::Page.find_by_id(params[:id])
  #    page.move_higher
  #    redirect_to pages_path
  #  end
  #  
  #  def move_down
  #    page = Osirails::Page.find_by_id(params[:id])
  #    page.move_lower
  #    redirect_to pages_path
  #  end

# This method permit to move down page  
 # This metohd permit to delete page 
  def delete
    page = Osirails::Page.find_by_id(params[:id])
    page.delete
    redirect_to pages_path
  end 
end
