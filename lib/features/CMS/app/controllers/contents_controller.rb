class ContentsController < ApplicationController
uses_tiny_mce "options" => { :theme => 'advanced',
                               :browsers => %w{msie gecko},
                               :theme_advanced_toolbar_location => "top",
                               :theme_advanced_toolbar_align => "left",
                               :theme_advanced_resizing => true,
                               :theme_advanced_resize_horizontal => true,
                               :paste_auto_cleanup_on_paste => true,
                               :theme_advanced_buttons1 => %w{formatselect fontselect fontsizeselect bold 
                                                              italic underline strikethrough separator justifyleft 
                                                              justifycenter justifyright indent outdent separator 
                                                              bullist numlist forecolor backcolor separator link 
                                                              unlink image undo redo},
                               :theme_advanced_buttons2 => [],
                               :theme_advanced_buttons3 => [],
                               :plugins => %w{contextmenu paste}}

  def index
    @contents = Content.find(:all)
  end
  
  def new
    @content = Content.new
    @menu = Menu.new
    @menus = Menu.get_structured_menus("---")
  end
  
  def create
    @menu = Menu.new(params[:menu])
    @content = Content.new(params[:content]) # TODO Add author name with his session_id
    if @menu.save
      @content.menu_id = @menu.id
      if @content.save
        flash[:notice] = 'Votre page est créée avec succes'
        redirect_to :action => 'index'
      else
        @menu.destroy
        render :action => 'new'
      end
    else 
      render :action => 'new'
    end
    
  end
  
  def edit
    @content = Content.find(params[:id])    
    @menu = Menu.find(@content.menu_id)
    @menus = Menu.get_structured_menus("---")
  end
  
  def update
    @content = Content.find(params[:id])
    @menus = Menu.get_structured_menus("---")
    
    # This variable permit to make a save of content
    content_attributes  = @content.attributes
    content_attributes[:content_id] = params[:id]
    ContentVersion.create(content_attributes)
    
    # Update content's menu
    @menu = Menu.find(@content.menu_id)
    @menu.old_parent_id, @menu.update_parent = @menu.parent_id, true
    
    # TODO Add contributor's name into the contributor_array
    if @content.update_attributes(params[:content]) and @menu.update_attributes(params[:menu])
      flash[:notive] = 'Votre page est mise à jour.'
      redirect_to contents_path
    else
      flash[:error] = 'Impossible de sauvegarder....'
      redirect_to edit_content_path(@content)      
    end
  end
  
  def destroy
    content = Content.find_by_id(params[:id])
    content.destroy
    redirect_to contents_path
  end
  
  def show
    @content = Content.find(params[:id])
    @author = User.find(@content.author, :include => [:employee])
    @contributors = User.find_all_by_id(@content.contributors, :include => [:employee])
    @contributors_full_names = []
    @contributors.each {|contributor| @contributors_full_names << contributor.employee.fullname}
  end
  
end
