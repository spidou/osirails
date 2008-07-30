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

    content_attributes  = @content.attributes
    content_attributes.delete("created_at")
    content_attributes.delete("updated_at")
    content_attributes.delete("author")
    content_attributes[:content_id] = params[:id]
    content_attributes[:versioned_at] = @content.updated_at
    ContentVersion.create(content_attributes)
    
    # TODO Add contributor's name into the contributor_array
    @content.update_attributes(params[:content])
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
