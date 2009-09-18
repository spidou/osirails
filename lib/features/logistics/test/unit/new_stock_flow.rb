module NewStockFlow
  private
    def new_stock_flow(supply,supplier,input,quantity,adjustment = false,date=Date.today,fob=1,tax=0)
      general_attributes = {:supply_id => supply.id,
                            :supplier_id => supplier.id,
                            :quantity => quantity,
                            :adjustment => adjustment}
      if input
        @sf = StockInput.new(general_attributes)
        @sf.fob_unit_price = fob
        @sf.tax_coefficient = tax
        unless adjustment          
          @sf.purchase_number = "FC456448"
        end
      else
        @sf = StockOutput.new(general_attributes)
        @sf.file_number = "F2009055620" unless adjustment
      end
      @sf.created_at = date.to_datetime unless date == Date.today
      @sf.save
    end
end

