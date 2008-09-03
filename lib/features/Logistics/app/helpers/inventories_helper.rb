module InventoriesHelper
  
  # This method permit to check last_update for inventory
  def show_last_update(inventory)
    update = inventory.updated_at
    commodities = CommoditiesInventory.find(:all, :conditions => {:inventory_id => inventory.id})
    commodities.each do |commodity|
      update = commodity.updated_at if update < commodity.updated_at
    end
    update
  end
  
  # This method permit to show closed button
  # , :confirm => 'Attention cette action est irr&eacute;versible'
  def show_closed_button(inventory)
    inventory.inventory_closed? ? "" : link_to(image_tag("/images/closed16x16.png", :alt => 'Cl&ocirc;tur&eacute;s l\'inventaire'), :action => 'closed', :id => inventory.id)
  end
  
  #  This method permit to add value of quantity
    def in_place_editor(inventory,commodity)
      inventory.inventory_closed? ? "<span>#{commodity.quantity}</span>" : editable_content_tag(:span, commodity, "quantity", true, nil, {:class => 'in_line_editor_span'}, {:clickToEditText => 'Cliquer pour modifier...', :savingText => 'Mise &agrave; jour', :submitOnBlur => true})
    end
  
  # This method permit to get structur for commodities
  def show_structured_commodities(inventory)
    structured_commodities = []
    commodities = inventory.commodities_inventories.find(:all, :conditions => {:inventory_id => inventory.id})
    parent_group = commodities.group_by(&:parent_commodity_category_name).sort
    parent_group.each do |parent|
      
      structured_commodities << "<tr>"
      structured_commodities << "<td>#{parent.first}</td>"
      structured_commodities << "<td colspan='12'></td>"
      structured_commodities << "</tr>"
      parent.last.group_by(&:commodity_category_name).sort.each do |group|
        
        structured_commodities << "<tr>"
        structured_commodities << "<td></td>"
        structured_commodities << "<td>#{group.first}</td>"
        structured_commodities << "<td colspan='11'></td>"
        structured_commodities << "</tr>"
        group.last.each do |commodity|

          unit_measure = UnitMeasure.find(commodity.unit_measure_id)
          supplier = Supplier.find(commodity.supplier_id)
      
          structured_commodities << "<tr id='commodities_inventory_#{commodity.id}'>"
          structured_commodities << "<td colspan='2'></td>"
          structured_commodities << "<td>#{supplier.name}</td>" #FIXME  Add cities
          structured_commodities << "<td>#{commodity.name}</td>"
          structured_commodities << "<td><span id='commodities_inventory_#{commodity.id}_measure'>#{commodity.measure}</span> #{unit_measure.symbol}</td>"
          structured_commodities << "<td><span id='commodities_inventory_#{commodity.id}_unit_mass'>#{commodity.unit_mass}</span> kg</td>"
          structured_commodities << "<td>#{commodity.fob_unit_price} &euro;/#{unit_measure.symbol}</td>"
          structured_commodities << "<td>#{commodity.taxe_coefficient} %</td>"
          structured_commodities << "<td><span id='commodities_inventory_#{commodity.id}_price'>#{commodity.fob_unit_price + ((commodity.fob_unit_price * commodity.taxe_coefficient)/100)}</span> &euro;/#{unit_measure.symbol}</td>"
          structured_commodities << "<td onkeydown ='refresh(this,event)'>"+in_place_editor(inventory,commodity)+"</td>"
          structured_commodities << "<td><span id='commodities_inventory_#{commodity.id}_measure_total'>#{commodity.quantity * commodity.measure}</span> #{unit_measure.symbol}</td>"
          structured_commodities << "<td><span id='commodities_inventory_#{commodity.id}_unit_mass_total'>#{commodity.quantity * commodity.unit_mass}</span> kg</td>"
          structured_commodities << "<td><span id='commodities_inventory_#{commodity.id}_total'>#{(commodity.quantity * commodity.measure) * (commodity.fob_unit_price + ((commodity.fob_unit_price * commodity.taxe_coefficient)/100))}</span> &euro;</td>"
          structured_commodities << "</tr>"
        end
      end
    end  
    structured_commodities
  end
  
end