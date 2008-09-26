class DesignCanvasController < ApplicationController
  layout "default_canvas"
  skip_before_filter :authenticate
  
  def index
    @stylesheet = params[:stylesheet] || "default"
  end
end
