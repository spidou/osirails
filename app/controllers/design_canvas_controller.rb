class DesignCanvasController < ApplicationController
  layout "default_canvas"
  skip_before_filter :authenticate
  
  def index
  end
end
