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
  end
  
  def update
    @static_page = StaticPage.find(params[:id])
    @static_page.update_attributes(params[:static_page])
    redirect_to static_pages_path
  end
  
  def destroy
    
  end
  
end
