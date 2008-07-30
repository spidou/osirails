class ContentVersionsController < ApplicationController
  def index
    @contents = Content.find(:all)
  end
  
  def show
    @content_version = ContentVersion.find(params[:id])
    # Static_page content the original static_page
    @content = Content.find(@content_version.content.id)
    @author = User.find(@content.author, :include => [:employee])
    # TODO : mettre ce code dans le model
    @contributor = User.find(@content_version.contributors, :include => [:employee]) unless @content_version.contributors.nil?
  end
end