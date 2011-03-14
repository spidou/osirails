module StockFlowsHelper
  def new_stock_flow_link(stock_flow_class, supply, message = nil)
    return unless stock_flow_class.can_add?(current_user)
    text = "Nouvelle #{stock_flow_class == StockInput ? 'entrée' : 'sortie'} de #{supply.is_a?(Commodity) ? 'matière première' : 'consommable'}"
    message ||= " #{text}"
    link_to( image_tag( 'add_16x16.png', :alt => text, :title => text ) + message, send("new_stock_#{stock_flow_class == StockInput ? 'input' : 'output'}_path", :supply_class => supply.class.name) )
  end
  
  def stock_flows_link(stock_flow_class, supply, message = nil)
    return unless stock_flow_class.can_view?(current_user)
    text = "Voir uniquement les #{stock_flow_class == StockInput ? 'entrée' : 'sortie'} de #{supply.is_a?(Commodity) ? 'matière première' : 'consommable'}"
    message ||= " #{text}"
    link_to( image_tag( 'view_16x16.png', :alt => text, :title => text ) + message, send("stock_#{stock_flow_class == StockInput ? 'inputs' : 'outputs'}_path", :supply_class => supply.class.name) )
  end
end
