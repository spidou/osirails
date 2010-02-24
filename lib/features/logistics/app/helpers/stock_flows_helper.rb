module StockFlowsHelper
  def new_stock_flow_link(input,supply,class_name)
    if "Stock#{input ? 'Input' : 'Output'}".constantize.can_add?(current_user)
      text = "Nouvelle #{input ? 'entrée' : 'sortie'} de #{class_name}"
      #"New #{supply.class.name.tableize.singularize} stock #{input ? 'input' : 'output'}"
      link_to(image_tag( "/images/add_16x16.png", :alt => text, :title => text ) + " " + text, "/stock_#{input ? 'inputs' : 'outputs'}/new?type=#{supply.class.name}")
    end
  end

  def stock_flows_link(input,supply,class_name)
    if "Stock#{input ? 'Input' : 'Output'}".constantize.can_list?(current_user)
      text = "Voir toutes  les #{input ? 'entrées' : 'sorties'} de #{class_name}"
      #"List only #{supply.class.name.tableize.singularize} stock #{input ? 'inputs' : 'outputs'}"
      link_to(image_tag( "/images/view_16x16.png", :alt => text, :title => text )+ " " + text, "/stock_#{input ? 'inputs' : 'outputs'}?type=#{supply.class.name}")
    end
  end
end

