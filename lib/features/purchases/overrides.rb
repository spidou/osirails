require 'application'
require_dependency 'suppliers_controller'

class SuppliersController < ApplicationController
  after_filter :detect_request_for_purchase_order_creation, :only => :new
  after_filter :redirect_to_new_purchase_order, :only => :create
  
  private
    def detect_request_for_purchase_order_creation
      session[:request_for_purchase_order_creation] = params[:purchase_order] === "1" ? true : false
    end
    
    def redirect_to_new_purchase_order
      if @supplier.errors.empty? and session[:request_for_purchase_order_creation]
        session[:request_for_purchase_order_creation] = nil
        erase_redirect_results
        redirect_to( new_purchase_order_path(:supplier_id => @supplier.id) )
      end
    end
end

