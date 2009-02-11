class ContentVersionsController < ApplicationController
  # GET /content_versions/show?content_id=&version=
  def show
    @content = Content.find(params[:content_id])
    @content_versions = ContentVersion.paginate_by_content_id @content.id, :page => params[:version],:per_page => 1
    @author = User.find(@content.author, :include => [:employee]) unless @content.author.blank?
  end
end