module CommoditiesManagerHelper
  
  # This method permit to add a button for add a sub category
  def add_category_or_commodity(commodity_category)
    commodity_category.commodity_category_id.nil? ? link_to("Ajouter une sous cat&eacute;gorie", new_commodity_category_path(:id => commodity_category.id, :type => "child")) : link_to("Ajouter une mati&egrave;re premi&egrave;re", new_commodity_path(:id => commodity_category.id))
  end
  
  # This method pemit to show or hide delete button
  def show_delete_button(commodity_category)
    link_to(image_tag("url", :alt => "Supprimer"), commodity_category, { :method => :delete, :confirm => 'Etes vous sûr  ?'}) if commodity_category.can_destroy?
  end
  
  # This method permit to have a table's structur
  def get_structured
    commodity_categories = CommodityCategory.root
    table = []
    # Get structur for parents commodities categories
    commodity_categories.each do |commodity_category|
      
      add_button = add_category_or_commodity(commodity_category)
      delete_button = show_delete_button(commodity_category)
      
      table << "<tr id='#{commodity_category.name}'>"
      table << "<td>#{commodity_category.name}</td>"
      table << "<td colspan='8'></td>"
      table << "<td>#{add_button} #{delete_button}</td>"
      table << "</tr>"
      
      # Get Structur for children commodities categories
      unless commodity_category.children.size == 0
        commodity_category.children.each do |category_child|
          unless category_child.enable == 0
            add_button = add_category_or_commodity(category_child)
            delete_button = show_delete_button(category_child)
          
            table << "<tr id='#{category_child.name} #{commodity_category.name}'>"
            table << "<td></td>"
            table << "<td>#{category_child.name} (#{category_child.commodities_count})</td>"
            table << "<td colspan='7'></td>"
            table << "<td>#{add_button} #{delete_button}</td>"
            table << "</tr>"

            # Get structur for commodities
            unless category_child.commodities.empty?
              category_child.commodities.each do |commodity|
                unless commodity.enable == 0
                  supplier = Supplier.find(commodity.supplier_id)
                  unit_measure = UnitMeasure.find(category_child.unit_measure_id)
                  table << "<tr id='#{commodity.name} #{category_child.name} #{commodity_category.name}'>"
                  table << "<td colspan='2'></td>"
                  table << "<td>#{supplier.name}</td>" #FIXME Add Cities
                  table << "<td>#{commodity.name}</td>"
                  table << "<td>#{commodity.measure} (#{unit_measure.symbol})</td>"
                  table << "<td>#{commodity.unit_mass} kg</td>"
                  table << "<td>#{commodity.FOB_unit_price} € / #{unit_measure.symbol}</td>"
                  table << "<td>#{commodity.taxe_coefficient} % </td>"
                  table << "<td></td>"                  
                  table << "<td></td>"
                  table << "</tr>"
                end
              end
            end
          end
        end
      end
    end
    table
  end

end