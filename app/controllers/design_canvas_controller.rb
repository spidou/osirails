class DesignCanvasController < ApplicationController
  layout "default_canvas"
  skip_before_filter :authenticate
  
  def index
    @stylesheet = "/themes/#{params[:stylesheet]}/stylesheets/default.css" if params[:stylesheet]
    @stylesheet ||= "/stylesheets/default.css"
  end
end
