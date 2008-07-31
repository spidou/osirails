class ContentVersionsController < ApplicationController
  def index
    @contents = Content.find(:all)
  end
  
  def show
    @content = Content.find(params[:content_id])
    @content_versions = ContentVersion.paginate_by_content_id @content.id, :page => params[:version],:per_page => 1
    @author = User.find(@content.author, :include => [:employee]) unless @content.author.nil? or @content.author == ""

  end
end