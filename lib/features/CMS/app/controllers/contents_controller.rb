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
  
  def preview
     #TODO Make preview method.
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
    if params[:content].nil?
    @content = Content.find(params[:id])
    
    @menu = Menu.find(@content.menu_id)
    @menus = Menu.get_structured_menus("---")
    $session_lock = @content.lock_version
    end
  end
  
  def update
    @content = Content.find(params[:id])
    content = @content
    @lock_version = @content.lock_version
    
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
    if @content.lock_version != $session_lock
      raise ActiveRecord::StaleObjectError
    end
    # TODO Add contributor's name into the contributor_array
#      @menu.update_attributes(params[:menu])
      if @content.update_attributes(params[:content])
        $actual_content = nil
        redirect_to contents_path
      else
#        render :action => :show 
      end
      
      @old_content_id = 1
      rescue ActiveRecord::StaleObjectError     
#      flash[:error] = "Quelqu'un est actuellement entrain de modifier cette page. Essayer dans un instant."
      flash[:notice] = "Impossible de modifier"
      redirect_to :edit, :content => @content
#      flash[:notive] = 'Votre page est mise à jour.'
#      redirect_to contents_path
#
#    rescue Exception
#      flash[:error] = 'Impossible de sauvegarder....'
#      redirect_to edit_content_path(@content)
  end
  
  def destroy
    content = Content.find_by_id(params[:id])
    content.destroy
    redirect_to contents_path
  end
  
  def show
    @content = Content.find(params[:id])
    @author = User.find(@content.author, :include => [:employee]) unless @content.author.nil? or @content.author == ""
    @contributors = User.find_all_by_id(@content.contributors, :include => [:employee])
    @contributors_full_names = []
    @contributors.each {|contributor| @contributors_full_names << contributor.employee.fullname}
    @content_versions = ContentVersion.paginate_by_content_id @content.id, :page => params[:page]
  end
  
end
