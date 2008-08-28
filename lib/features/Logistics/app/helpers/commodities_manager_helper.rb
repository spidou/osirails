module CommoditiesManagerHelper
  
  # This method permit to add a button for add a sub category
  def add_category_or_commodity(commodity_category)
    commodity_category.commodity_category_id.nil? ? link_to("Ajouter une sous cat&eacute;gorie", new_commodity_category_path(:id => commodity_category.id, :type => "child")) : link_to("Ajouter une mati&egrave;re premi&egrave;re", new_commodity_path(:id => commodity_category.id))
  end
  
  # This method pemit to show or hide delete button
  def show_delete_button(commodity_category)
    link_to(image_tag("url", :alt => "Supprimer"), commodity_category, { :method => :delete, :confirm => 'Etes vous sûr  ?'}) if commodity_category.can_destroy?
  end
  
  # This method permit to make in table editor
  def in_place_editor(object,attribute)
    editable_content_tag(:span, object, "#{attribute}", true, nil, {}, {:okText => 'Modifier'})
  end
  
  # This method permit to have a table's structur
  def get_structured(show)
    commodity_categories = CommodityCategory.root
    table = []
    # Get structur for parents commodities categories
    commodity_categories.each do |commodity_category|
      
      add_button = add_category_or_commodity(commodity_category)
      delete_button = show_delete_button(commodity_category)
      
      table << "<tr id='commodity_category_#{commodity_category.id}' class='#{commodity_category.name}'>"
      table << "<td>"+in_place_editor(commodity_category,'name')+"</td>"
      table << "<td colspan='8'></td>"
      table << "<td>#{add_button} #{delete_button}</td>"
      table << "</tr>"
      # Get Structur for children commodities categories
      unless commodity_category.children.size == 0
        commodity_category.children.each do |category_child|
          unless category_child.enable == show
                              puts "___________________________________________________"
                  puts show
            add_button = add_category_or_commodity(category_child)
            delete_button = show_delete_button(category_child)
          
            table << "<tr id='commodity_category_#{category_child.id}' class='#{category_child.name} #{commodity_category.name}'>"
            table << "<td></td>"
            table << "<td>"+in_place_editor(category_child,'name')+"(#{category_child.commodities_count})</td>"
            table << "<td colspan='7'></td>"
            table << "<td>#{add_button} #{delete_button}</td>"
            table << "</tr>"

            # Get structur for commodities
            unless category_child.commodities.empty?
              category_child.commodities.each do |commodity|
                unless commodity.enable == show
                  puts "___________________________________________________"
                  puts show
                  supplier = Supplier.find(commodity.supplier_id)
                  unit_measure = UnitMeasure.find(category_child.unit_measure_id)
                  delete_button = show_delete_button(commodity)
                  table << "<tr id='commodity_#{commodity.id}' class='#{commodity.name} #{category_child.name} #{commodity_category.name}'>"
                  table << "<td colspan='2'></td>"
                  table << "<td>#{supplier.name}</td>" #FIXME Add Cities
                  table << "<td>"+in_place_editor(commodity,'name')+"</td>"
                  table << "<td>"+in_place_editor(commodity,'measure')+" (#{unit_measure.symbol})</td>"
                  table << "<td>"+in_place_editor(commodity,'unit_mass')+"kg</td>"
                  table << "<td  >"+in_place_editor(commodity,'fob_unit_price')+" € / #{unit_measure.symbol}</td>"
                  table << "<td  >"+in_place_editor(commodity,'taxe_coefficient')+" % </td>"
                  table << "<td><span id='commodity_#{commodity.id}_price'>#{commodity.fob_unit_price + (commodity.fob_unit_price * commodity.taxe_coefficient)/100}</span> € / #{unit_measure.symbol}</td>"
                  table << "<td>"+link_to(image_tag("url", :alt => "Supprimer"), commodity, { :controller => 'commodities', :action => 'destroy', :method => :delete, :confirm => 'Etes vous sûr  ?'})+"</td>"
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