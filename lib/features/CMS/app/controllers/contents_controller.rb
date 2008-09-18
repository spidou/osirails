class ContentsController < ApplicationController
  # GET /contents
  def index
    if Content.can_list?(current_user)
      @contents = Content.find(:all)
    else
      error_access_page(403)
    end
  end
  
  # GET /contents/1
  def show
    if Content.can_view?(current_user)
      @content = Content.find(params[:id])
      @author = User.find(@content.author, :include => [:employee]) unless @content.author.nil? or @content.author == ""
      @contributors = User.find_all_by_id(@content.contributors, :include => [:employee])
      @contributors_full_names = []
      @contributors.each {|contributor| @contributors_full_names << (contributor.employee.nil? ? contributor.username : contributor.employee.fullname)}
      @content_versions = ContentVersion.paginate_by_content_id @content.id, :page => params[:page]
    else
      error_access_page(403)
    end
  end
  
  # GET /contents/new
  def new
    if Content.can_add?(current_user)
      @content = Content.new
      @menu = Menu.new
      @menus = Menu.get_structured_menus
    else
      error_access_page(403)
    end
  end
  
  # POST /contents
  def create
    if Content.can_add?(current_user)
      @menu = Menu.new(params[:menu])
      params[:content][:author_id] = current_user.id
      @content = Content.new(params[:content])
      if @menu.save
        @content.menu_id = @menu.id
        if @content.save
          flash[:notice] = 'Votre page est créée avec succès'
          redirect_to :action => 'index'
        else
          @menu.destroy
          @menus = Menu.get_structured_menus
          render :action => 'new'
        end
      else
        @menus = Menu.get_structured_menus
        render :action => 'new'
      end
    else
      error_access_page(403)
    end
  end
  
  # GET /contents/1/edit
  def edit
    if Content.can_edit?(current_user)
      if @content.nil?
        @content = Content.find(params[:id])    
        @menu = Menu.find(@content.menu_id)
        @menus = Menu.get_structured_menus
        $session_lock = @content.lock_version
      end
    end
  end
  
  # PUT /contents/1
  def update
    if Content.can_edit?(current_user)
      @error = false
      @content = Content.find(params[:id])
      @lock_version = @content.lock_version
    
      # get_structured_menus permit to make a indent for menu's list
      # TODO Remove the menu item in the structure
      @menus = Menu.get_structured_menus
    
      #    # Update content's menu
      @menu = Menu.find(@content.menu.id)
      #    @menu.old_parent_id = @menu.parent_menu.id
      #    @menu.update_parent = true
    
      # If content isn't in his last version
      if @content.lock_version != $session_lock
        raise ActiveRecord::StaleObjectError
      end
      # TODO Add contributor's id into the contributor_array  
    
      @content.contributors ||= []
      @content.contributors.delete(current_user.id)
      params[:content][:contributors] = @content.contributors
      params[:content][:contributors] << current_user.id
    
      puts params[:menu].keys
      unless @menu.update_attributes(params[:menu])
        @error = true
        flash[:error] = "Un probl&egrave;me est survenu lors de la modification du menu du contenu"
        @content.title = params[:content][:title]
        @content.description = params[:content][:description]
        @content.text = params[:content][:text]
      else
        unless @content.update_attributes(params[:content])
          @error = true
          flash[:error] = "Un probl&egrave;me est survenu lors de la modification du contenu"
        else
          # This variable permit to make a save of content
          content_attributes  = @content.attributes
          content_attributes.delete("contributors")
          content_attributes.delete("author_id")
          content_attributes[:content_id] = params[:id]
          # size - 2 is use to get before next to last
          content_attributes[:contributor_id] = (@content.contributors.empty? ? @content.author : @content.contributors[@content.contributors.size - 2])
          ContentVersion.create(content_attributes)
        end
      end
    
      unless @error
        flash[:notice] = "Contenu modifi&eacute; avec succ&egrave;s"
        redirect_to contents_path
      else 
        render :action => "edit"
      end 
    end
    # If @content.update_attributes() failed
  rescue ActiveRecord::StaleObjectError     
    @affiche = true
    flash.now[:error] = "Impossible de modifier le contenu car vous travaillez sur une version antérieur"
    @content.attributes  = params[:content]
    render :action => :edit
  end

  # DELETE /contents/1  
  def destroy
    if Content.can_delete?(current_user)
      content = Content.find_by_id(params[:id])
      content.destroy
      redirect_to contents_path
    end
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
