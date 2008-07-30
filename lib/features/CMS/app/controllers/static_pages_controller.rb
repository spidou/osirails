class StaticPagesController < ApplicationController
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
    @static_pages = StaticPage.find(:all)
  end
  
  def edit
    @static_page = StaticPage.find(params[:id])
    @pages = Page.get_structured_pages("---")
  end
  
  def update
    @pages = Page.get_structured_pages("----")
    @static_page = StaticPage.find(params[:id])
    @static_page.update_attributes(params[:static_page])
    StaticPageVersion.new(:static_page_id => @static_page.id, :title_link => @static_page.title_link, :description_link => @static_page.description_link,
:url => @static_page.url, :title => @static_page.title, :description => @static_page.description, :author => @static_page.author, :contributors => @static_page.contributors,
:text => @static_page.text, :tags => @static_page.tags, :position => @static_page.position, :parent_id => @static_page.parent_id, :versioned_at => @static_page.updated_at).save
    redirect_to static_pages_path
  end
  
  def destroy
    static_page = StaticPage.find_by_id(params[:id])
    static_page.destroy
    redirect_to static_pages_path
  end
  
  def new
    @static_page = StaticPage.new
    @pages = Page.get_structured_pages("---")
  end
  
  def create
    @pages = Page.get_structured_pages("----")
    @static_page = StaticPage.new(params[:static_page])
    if @static_page.save
      flash[:notice] = 'Votre static_page est créée avec succes'
      redirect_to :action => 'index'
    else
      render :action => 'new'
    end
  end
  
  def show
    @static_page = StaticPage.find(params[:id])
    @author = User.find(@static_page.author, :include => [:employee])
    @contributors = User.find_all_by_id(@static_page.contributors, :include => [:employee])
    @contributors_full_names = []
    @contributors.each {|contributor| @contributors_full_names << contributor.employee.fullname}
    @static_page_version = []
    @static_page_versions = @static_page.versions
  end
  
end
