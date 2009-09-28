class Inventory < ActiveRecord::Base
  has_permissions :as_business_object
  
  # For will_paginate
  DATES_PER_PAGE = 15
  
  # This method returns the result of a SQL instruction
  # which role is to retrieve all distinct inventories dates
  def self.dates
    dates = []
    sql = ActiveRecord::Base.connection();
    result = sql.execute "SELECT DISTINCT DATE_FORMAT(created_at,'%d-%m-%Y') FROM stock_flows WHERE adjustment IS NOT NULL ORDER BY created_at DESC"
    for date in result
      dates << date
    end
    dates
  end
  
  # This method permit to generate automatically stock flows
  # with adjustment for inventories from params of views
  def self.create_stock_flows(params)
    changes = 0
      for supply in params[:type].constantize.was_enabled_at
        for ss in supply.supplier_supplies
          param_quantity = params[("real_stock_quantity_for_supplier_supply_"+(ss.id.to_s)).to_sym]
          param_fob = params[("fob_for_supplier_supply_"+(ss.id.to_s)).to_sym]
          param_tax_coefficient = params[("tax_coefficient_for_supplier_supply_"+(ss.id.to_s)).to_sym]
          new_quantity = param_quantity.to_f
          if ((/\A[+-]?\d+?(\.\d+)?\Z/ !~ param_quantity or param_quantity.to_f < 0) or (((/\A[+-]?\d+?(\.\d+)?\Z/ !~ param_fob or param_fob.to_f < 0) or (/\A[+-]?\d+?(\.\d+)?\Z/ !~ param_tax_coefficient or param_tax_coefficient.to_f < 0)) and new_quantity-ss.stock_quantity > 0))
            return false
          end
        end
      end
      for supply in params[:type].constantize.was_enabled_at
      
        for ss in supply.supplier_supplies
          param_quantity = params[("real_stock_quantity_for_supplier_supply_"+(ss.id.to_s)).to_sym]
          param_fob = params[("fob_for_supplier_supply_"+(ss.id.to_s)).to_sym]
          param_tax_coefficient = params[("tax_coefficient_for_supplier_supply_"+(ss.id.to_s)).to_sym]
          new_quantity = param_quantity.to_f
          new_fob = param_fob.to_f
          new_tax_coefficient = param_tax_coefficient.to_f
          if new_quantity-ss.stock_quantity > 0
            StockInput.create({:adjustment => true, :quantity => new_quantity-ss.stock_quantity, :supply_id => ss.supply_id, :supplier_id => ss.supplier_id, :fob_unit_price => new_fob, :tax_coefficient => new_tax_coefficient})     
            changes += 1   
          elsif new_quantity-ss.stock_quantity < 0
            StockOutput.create({:adjustment => true, :quantity => ss.stock_quantity-new_quantity, :supply_id => ss.supply_id, :supplier_id => ss.supplier_id, :fob_unit_price => new_fob, :tax_coefficient => new_tax_coefficient})
            changes += 1
          end
        end
        
      end
    changes
  end  
end
