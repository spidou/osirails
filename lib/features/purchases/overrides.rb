require 'application'
require_dependency 'suppliers_controller'
require_dependency 'supplier'

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

class Supplier
  def get_all_purchase_request_supplies
    purchase_request_supplies = PurchaseRequestSupply.get_all_pending_purchase_request_supplies
    kept_purchase_request_supplies = []
    for purchase_request_supply in purchase_request_supplies
      for purchase_request_supply_supplier in purchase_request_supply.supply.suppliers
        if purchase_request_supply_supplier == self
          kept_purchase_request_supplies << purchase_request_supply
        end
      end
    end
    return kept_purchase_request_supplies
  end
  
  def merge_purchase_request_supplies
    kept_purchase_request_supplies = get_all_purchase_request_supplies.group_by(&:supply_id)
    list_of_merged_purchase_request_supply = []
    kept_purchase_request_supplies.each { |key, value|
      quantities_sum = value.collect{ |purchase_request_supply| purchase_request_supply[:expected_quantity] }.sum
      list_of_merged_purchase_request_supply << PurchaseRequestSupply.new(:purchase_request_id => nil, :supply_id => key, :expected_quantity => quantities_sum, :expected_delivery_date => value.first.expected_delivery_date )
    }
    list_of_merged_purchase_request_supply
  end
end
