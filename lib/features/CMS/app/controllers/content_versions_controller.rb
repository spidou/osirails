class ContentVersionsController < ApplicationController
  # GET /contentversions
  def index
    @contents = Content.find(:all)
  end
  
  # GET /contentversions/1
  def show
    @content = Content.find(params[:content_id])
    @content_versions = ContentVersion.paginate_by_content_id @content.id, :page => params[:version], :per_page => 1
    @author = User.find(@content.author, :include => [:employee]) unless @content.author.nil? or @content.author == ""
  end
  
end