class StockInputsController < StockFlowsController
  
  #POST /stock_inputs/update_supply_stock_infos?supply_id:supply_id
  def update_supply_stock_infos
    @supply = Supply.find_by_id(params[:supply_id])
  end
  
  private
    def define_stock_flow_class
      @stock_flow_class = StockInput
    end
end
