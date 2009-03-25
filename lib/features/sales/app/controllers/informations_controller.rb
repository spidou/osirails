class InformationsController < ApplicationController
  acts_as_step_controller :sham => true
  before_filter :select_menu

  def show

  end

  private

  def select_menu
    @@current_order_step = @order.current_step.first_parent.path
  end
end
