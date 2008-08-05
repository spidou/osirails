class ThirdsController < ApplicationController
  def index
    @thirds = Third.find(:all)
  end
  
  def new
    @third = Third.new
  end
  
  def create
    @third = Third.new(params[:third])
    if @third.save
      flash[:notice] = 'Tiers ajouté avec succes'
        redirect_to :action => 'index'
    end
  end
end