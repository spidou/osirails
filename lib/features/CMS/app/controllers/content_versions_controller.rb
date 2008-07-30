class ContentVersionsController < ApplicationController
  def index
    @contents = Content.find(:all)
  end
  
  def show
    @content_version = ContentVersion.find(params[:id])
    # Static_page content the original static_page
    @content = Content.find(@content_version.content.id)
    @author = User.find(@content_version.author, :include => [:employee])
    # TODO : mettre ce code dans le model
    @contributors = User.find_all_by_id(@content_version.contributors, :include => [:employee])
    @contributors_full_names = []
    @contributors.each {|contributor| @contributors_full_names << contributor.employee.fullname}
  end
end