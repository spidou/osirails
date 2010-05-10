class StockOutputsController < StockFlowsController
  private
    def define_stock_flow_type
      @stock_flow_type = StockOutput
    end
end
