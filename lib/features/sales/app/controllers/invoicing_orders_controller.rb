class InvoicingOrdersController < ApplicationController
  helper :orders

  def index
    @orders = StepInvoicing.find(:all, :conditions => "status <> 'unstarted' AND status <> 'terminated'").collect { |sc| sc.order }
  end
end
