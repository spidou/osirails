class StaticPageVersionsController < ApplicationController
  def index
    
  end
  
  def show
    @static_page_version = StaticPageVersion.find(params[:id])
    # Static_page content the original static_page
    @static_page = StaticPage.find(@static_page_version.static_page.id)
    @author = User.find(@static_page_version.author, :include => [:employee])
    # TODO : mettre ce code dans le model
    @contributors = User.find_all_by_id(@static_page_version.contributors, :include => [:employee])
    @contributors_full_names = []
    @contributors.each {|contributor| @contributors_full_names << contributor.employee.fullname}
  end
end