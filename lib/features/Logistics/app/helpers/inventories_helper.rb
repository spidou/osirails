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
    inventory.inventory_closed? ? "" : link_to("Cl&ocirc;turer l'inventaire", {:action => 'update', :method => 'put',  :confirm => "Attention, une fois clôtur&eacute, vous ne pourrez plus modifier l'inventaire", :id => inventory.id}, {:class => 'link_to_closed'})
  end
  
  #  This method permit to add value of quantity
  def in_place_editor(inventory,commodity)
    inventory.inventory_closed? ? "<span>#{commodity.quantity}</span>" : editable_content_tag(:span, commodity, "quantity", true, nil, {:class => 'in_line_editor_span'}, {:clickToEditText => 'Cliquer pour modifier...', :savingText => 'Mise &agrave; jour', :submitOnBlur => true})
  end
  
  # This method permit to show category's total
  def show_total(inventory, commodity_category = nil, value = 0)
    total = 0
    commodities = CommoditiesInventory.find_all_by_commodity_category_id_and_inventory_id(commodity_category.commodity_category_id, inventory.id) if value == 0
    commodities = CommoditiesInventory.find_all_by_parent_commodity_category_id_and_inventory_id(commodity_category.parent_commodity_category_id, inventory.id) if value == 1
    commodities = CommoditiesInventory.find_all_by_inventory_id(inventory.id) if value == 2
    commodities.each do |commodity|
      total += (commodity.quantity * commodity.measure) * (commodity.fob_unit_price + ((commodity.fob_unit_price * commodity.taxe_coefficient)/100))
    end
    total
  end
  
  # This method permit to get structur for commodities
  def show_structured_commodities(inventory)
    structured_commodities = []
    commodities = inventory.commodities_inventories.find(:all, :conditions => {:inventory_id => inventory.id})
    parent_group = commodities.group_by(&:parent_commodity_category_id).sort
    parent_group.each do |parent|
      commodity_category = inventory.commodities_inventories.find(:first, :conditions => {:inventory_id => inventory.id, :parent_commodity_category_id => parent.first})
    
      structured_commodities << "<tr id='commodity_category_#{commodity_category.parent_commodity_category_id}' >"
      structured_commodities << "<td><img id='commodity_category_#{commodity_category.parent_commodity_category_id}_develop' src='/images/develop_button_16x16.png' alt='R&eacute;' onclick='develop(this.ancestors()[1])' style='display: none;'/>"
      structured_commodities << "<img id='commodity_category_#{commodity_category.parent_commodity_category_id}_reduce' src='/images/reduce_button_16x16.png' alt='R&eacute;' onclick='reduce(this.ancestors()[1])'/>"
      structured_commodities << "#{commodity_category.parent_commodity_category_name}</td>"
      structured_commodities << "<td colspan='11'></td>"
      structured_commodities << "<td class='commodity_category'><span class='commodity_category_#{commodity_category.parent_commodity_category_id}_total'>#{show_total(inventory,commodity_category,1)}</span> &euro;</td>"
      structured_commodities << "</tr>"
      parent.last.group_by(&:commodity_category_id).sort.each do |group|
        sub_commodity_category = inventory.commodities_inventories.find(:first, :conditions => {:inventory_id => inventory.id, :commodity_category_id => group.first})
        
        structured_commodities << "<tr id='commodity_category_#{sub_commodity_category.commodity_category_id}' class='commodity_category_#{commodity_category.parent_commodity_category_id}' >"
        structured_commodities << "<td></td>"
        structured_commodities << "<td><img id='commodity_category_#{sub_commodity_category.commodity_category_id}_develop' src='/images/develop_button_16x16.png' alt='R&eacute;' onclick='develop(this.ancestors()[1])' />"
        structured_commodities << "<img id='commodity_category_#{sub_commodity_category.commodity_category_id}_reduce' src='/images/reduce_button_16x16.png' alt='R&eacute;' onclick='reduce(this.ancestors()[1])' style='display: none;' />"
        structured_commodities << "#{sub_commodity_category.commodity_category_name}</td>"
        structured_commodities << "<td colspan='10'></td>"
        structured_commodities << "<td class='sub_commodity_category'><span class='sub_commodity_category_#{sub_commodity_category.commodity_category_id}_total' >#{show_total(inventory,sub_commodity_category)}</span> &euro;</td>"
        structured_commodities << "</tr>"
        group.last.each do |commodity|

          unit_measure = UnitMeasure.find(commodity.unit_measure_id)
          supplier = Supplier.find(commodity.supplier_id)
      
          structured_commodities << "<tr id='commodities_inventory_#{commodity.id}' class='commodity_category_#{sub_commodity_category.commodity_category_id} commodity_category_#{commodity_category.parent_commodity_category_id}' style='display: none;'>"
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
          structured_commodities << "<td><span id='commodities_inventory_#{commodity.id}_total' class='commodity_category_#{commodity_category.parent_commodity_category_id}_total sub_commodity_category_#{sub_commodity_category.commodity_category_id}_total'>#{(commodity.quantity * commodity.measure) * (commodity.fob_unit_price + ((commodity.fob_unit_price * commodity.taxe_coefficient)/100))}</span> &euro;</td>"
          structured_commodities << "</tr>"
        end
      end
    end  
    structured_commodities
  end
  
end