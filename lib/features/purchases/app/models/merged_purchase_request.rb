class PurchaseRequestSupply < ActiveRecord::Base

  attr_accessor :reference, :designation, :stock_quantity, :fob_unit_price, :total_expected_quantity, :measure, :unit_mass, :lead_time
  
end
