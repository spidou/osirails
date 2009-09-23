class ContentsController < ApplicationController
  # GET /contents
  def index
    @contents = Content.find(:all).paginate(:page => params[:page], :per_page => Content::CONTENTS_PER_PAGE)
  end
  
  # GET /contents/1
  def show
    @content = Content.find(params[:id])
    @author = User.find(@content.author, :include => [:employee]) unless @content.author.blank?
    @contributors = User.find_all_by_id(@content.contributors, :include => [:employee])
    @content_versions = ContentVersion.paginate_by_content_id @content.id, :page => params[:page]
  end
  
  # GET /contents/new
  def new
    @content = Content.new
    @content.menu = Menu.new
    @menus = Menu.get_structured_menus
  end
  
  # POST /contents
  def create
    params[:content][:author_id] = current_user.id
    @content = Content.new(params[:content])
    if @content.save
      flash[:notice] = 'Votre page est crée avec succès'
      redirect_to :action => 'index'
    else
      @menus = Menu.get_structured_menus
      render :action => 'new'
    end
  end
  
  # GET /contents/1/edit
  def edit
    if @content.nil?
      @content = Content.find(params[:id])
      @menus = Menu.get_structured_menus
      $session_lock = @content.lock_version
    end
  end
  
  # PUT /contents/1
  def update
    @content = Content.find(params[:id])
    @lock_version = @content.lock_version

    # get_structured_menus permit to make a indent for menu's list
    # TODO Remove the menu item in the structure
    @menus = Menu.get_structured_menus

    # If content isn't in his last version
    if @content.lock_version != $session_lock
      raise ActiveRecord::StaleObjectError
    end

    # Add the current user as a contributor of the content
    # Duplicate entry are automatically deleted by the model
    content_attributes = params[:content]
    content_attributes[:contributors] = @content.contributors || []
    content_attributes[:contributors] << current_user.id

    if @content.update_attributes(content_attributes)
      ContentVersion.create_from_content(@content)
      
      flash[:notice] = "Contenu modifi&eacute; avec succ&egrave;s"
      redirect_to contents_path
    else
      flash[:error] = "Un probl&egrave;me est survenu lors de la modification du contenu"
      render :action => "edit"
    end

  # If @content.update_attributes() failed
  rescue ActiveRecord::StaleObjectError
    @affiche = true
    flash.now[:error] = "Impossible de modifier le contenu car vous travaillez sur une version antérieur"
    @content.attributes = params[:content]
    render :action => :edit
  end

  # DELETE /contents/1  
  def destroy
    @content = Content.find_by_id(params[:id])
    @content.destroy
    redirect_to contents_path
  end
  
  # uses_tiny_mce permit to configure text_area's options
  uses_tiny_mce "options" =>
    {
    :theme => 'advanced',
    :browsers => %w{msie gecko},
    :theme_advanced_toolbar_location => "top",
    :theme_advanced_toolbar_align => "left",
    :theme_advanced_resizing => true,
    :theme_advanced_resize_horizontal => true,
    :paste_auto_cleanup_on_paste => true,
    :theme_advanced_buttons1 => %w{ formatselect fontselect fontsizeselect bold
                                    italic underline strikethrough separator justifyleft
                                    justifycenter justifyright indent outdent separator
                                    bullist numlist forecolor backcolor separator link
                                    unlink image undo redo},
    :theme_advanced_buttons2 => [],
    :theme_advanced_buttons3 => [],
    :plugins => %w{contextmenu paste}
  }
end
