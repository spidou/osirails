class StockOutputsController < StockFlowsController
  private
    def define_stock_flow_class
      @stock_flow_class = StockOutput
    end
end
