class InformationsController < ApplicationController
  acts_as_step_controller :sham => true
  
  def index
    render :action => :show
  end
  
  def show

  end
end
