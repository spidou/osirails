require_dependency 'orders_query'

module ProductionOrdersQuery
  include OrdersQuery
  
  def query_td_content_for_production_step_manufacturing_step_manufacturing_started_on_in_order
    if @query_object.production_step and @query_object.production_step.manufacturing_step and @query_object.production_step.manufacturing_step.manufacturing_started_on
      l(@query_object.production_step.manufacturing_step.manufacturing_started_on, :format => :short)
    end
  end
  
  def query_td_content_for_production_step_manufacturing_step_global_progression_in_order
    if @query_object.production_step && @query_object.production_step.manufacturing_step && @query_object.production_step.manufacturing_step.manufacturing_started_on
      "#{@query_object.production_step.manufacturing_step.global_progression}&nbsp;%"
    end
  end
  
  def query_td_content_for_production_step_manufacturing_step_number_of_built_pieces_in_order
    if @query_object.signed_quote and @query_object.production_step and @query_object.production_step.manufacturing_step
      number_of_built_pieces = @query_object.production_step.manufacturing_step.number_of_built_pieces
      number_of_pieces = @query_object.signed_quote.number_of_pieces.to_i
      "#{number_of_built_pieces}/#{number_of_pieces}"
    end
  end
  
  def query_td_content_for_ready_to_deliver_pieces_in_order
    if @query_object.production_step && @query_object.production_step.manufacturing_step && @query_object.production_step.manufacturing_step.manufacturing_started_on
      @query_object.ready_to_deliver_pieces
    end
  end
  
  def query_td_content_for_delivered_pieces_in_order
    if @query_object.production_step && @query_object.production_step.manufacturing_step && @query_object.production_step.manufacturing_step.manufacturing_started_on
      @query_object.delivered_pieces
    end
  end
end
