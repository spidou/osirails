class ContentsController < ApplicationController

  # uses_tiny_mce permit to configure text_area's options
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

  # Get/contents
  def index
    @contents = Content.find(:all)
  end
  
  # GET /contents/1
  def show
    @content = Content.find(params[:id])
    @author = User.find(@content.author, :include => [:employee]) unless @content.author.nil? or @content.author == ""
    @contributors = User.find_all_by_id(@content.contributors, :include => [:employee])
    @contributors_full_names = []
    @contributors.each {|contributor| @contributors_full_names << contributor.employee.fullname}
    @content_versions = ContentVersion.paginate_by_content_id @content.id, :page => params[:page]
  end
  
  # Get/contents/new
  def new
    @content = Content.new
    @menu = Menu.new
    # get_structured_menus permit to make a indent for menu's list
    @menus = Menu.get_structured_menus("---")
  end
  
  def preview
    #TODO Make preview method.
  end
  
  # POST /contents
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
  
  # GET /contents/1/edit
  def edit
    if @content.nil?
      @content = Content.find(params[:id])    
      @menu = Menu.find(@content.menu_id)
      @menus = Menu.get_structured_menus("---")
      $session_lock = @content.lock_version
    end
  end
  
  # PUT /contents/1
  def update
    @content = Content.find(params[:id])
    @lock_version = @content.lock_version
    
    # get_structured_menus permit to make a indent for menu's list    
    @menus = Menu.get_structured_menus("---")
    
    # This variable permit to make a save of content
    content_attributes  = @content.attributes
    content_attributes.delete("contributors")
    content_attributes[:content_id] = params[:id]
    ContentVersion.create(content_attributes)
    # TODO Add contributor name into conten_versions contributor column
    
    # Update content's menu
    @menu = Menu.find(@content.menu_id)
    @menu.old_parent_id, @menu.update_parent = @menu.parent_id, true
    
    # If content isn't in his last version
    if @content.lock_version != $session_lock
      raise ActiveRecord::StaleObjectError
    end
    # TODO Add contributor's name into the contributor_array
    @content.update_attributes(params[:content])
    unless @menu.update_attributes(params[:menu])
      flash[:error] = "Impossible de déplacer le menu"
      redirect_to edit_content_path
    else
      redirect_to contents_path
    end
    flash[:notice] = 'Votre page est mise à jour.'
    
    
  rescue ActiveRecord::StaleObjectError     
    @affiche = true
    flash.now[:error] = "Impossible de modifiez le contenu car vous travaillez sur une version antérieur"
    @content.attributes  = params[:content]
    render :action => :edit 
  end

  # DELETE /contents/1  
  def destroy
    content = Content.find_by_id(params[:id])
    content.destroy
    redirect_to contents_path
  end

end
