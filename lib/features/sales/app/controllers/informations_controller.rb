class InformationsController < ApplicationController
  acts_as_step_controller :sham => true
  
  before_filter :load_collections
  
  def index
    render :action => :show
  end
  
  def show
  end
  
  def edit
  end
  
  private
    def load_collections
      @commercials = Employee.find(:all)
      @order_types = OrderType.find(:all)
      @contacts = @order.customer.contacts_all
    end
end
