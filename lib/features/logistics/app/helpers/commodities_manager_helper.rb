module CommoditiesManagerHelper
  
  # This method permit to add a button for add a sub category
  def add_category_or_commodity(commodity_category)
    if controller.can_add?(current_user) and CommodityCategory.can_add?(current_user)
      commodity_category.commodity_category_id.nil? ? link_to("Ajouter une sous cat&eacute;gorie", new_commodity_category_path(:id => commodity_category.id, :type => "child")) : link_to("Ajouter une mati&egrave;re premi&egrave;re", new_commodity_path(:id => commodity_category.id))
    end
  end
  
  # This method permit to show or hide delete button for categories
  def show_delete_category_button(commodity_category)
    if controller.can_delete?(current_user) and CommodityCategory.can_delete?(current_user)
      link_to(image_tag("url", :alt => "Supprimer"), commodity_category, { :method => :delete, :confirm => 'Etes vous sûr  ?'}) if commodity_category.can_be_destroyed?
    end
  end
  
  # This method permit to show or hide delete button for commodities
  def show_delete_commodity_button(commodity,show)
    if controller.can_delete?(current_user) and Commodity.can_delete?(current_user)
      link_to(image_tag("url", :alt => "Supprimer"), commodity,  { :controller => 'commodities', :action => 'destroy', :method => :delete, :confirm => 'Etes vous sûr  ?'}) unless show == nil and commodity.enable == false
    end
  end
  
  # This method permit to format link that should be display into secondary menu
  # we can't use the dynamic helper method 'generator' because of an unexpected argument passed to new_commodity_path => ':id =>-1'
  def show_commodity_add_button(txt = "New Commodity")
    if Commodity.can_add?(current_user)
      link_to(image_tag( "/images/add_16x16.png", :alt => "New", :title => "New" )+" #{txt}", new_commodity_path(:id => -1) )    
    end  
  end
  
  # This method permit to display the good link if the commodities categories or commodities, are enabled or not
  def show_commodities_view_button(type)
    if ( CommodityCategory.find(:all).size != CommodityCategory.find_all_by_enable(true).size ) or ( Commodity.find(:all).size != Commodity.find_all_by_enable(true).size )
      if type != "show_all" 
        html_opt = { :alt => "View all commodities", :title => "View all commodities including destroyed"}
        hash = { :action => "index", :type => "show_all"}
      else
        html_opt = { :alt => "View commodities", :title => "View all commodities without destroyed"}
        hash = { :action => "index"}
      end
        link_to(image_tag("/images/view_16x16.png")+" #{html_opt[:alt]}",hash,html_opt)
    end
  end
  
  # This method permit to make in table editor
  def in_place_editor(object,attribute,value = 0)
    if value == 1 and (controller.can_edit?(current_user) and CommodityCategory.can_edit?(current_user))
      return editable_content_tag(:span, object, "#{attribute}", true, nil, {:class => 'in_line_editor_span'}, {:clickToEditText => 'Cliquer pour modifier...', :savingText => 'Mise &agrave; jour', :submitOnBlur => true, :cancelControl => false, :okControl => false})
    end
    if value == 0 and (controller.can_edit?(current_user) and Commodity.can_edit?(current_user))
      return editable_content_tag(:span, object, "#{attribute}", true, nil, {:class => 'in_line_editor_span'}, {:clickToEditText => 'Cliquer pour modifier...', :savingText => 'Mise &agrave; jour', :submitOnBlur => true, :cancelControl => false, :okControl => false})
    end
    "<span>#{object.send(attribute)}</span>"
  end
  
  # This method permit to generate a counter for  categories
  def show_counter_category(commodity_category,show)
    counter = 0
    
    return commodity_category.commodities.count if show == nil and !commodity_category.commodity_category_id.nil?
    return commodity_category.commodities_count if show == false and !commodity_category.commodity_category_id.nil?
    
    commodities_categories = CommodityCategory.find_all_by_commodity_category_id(commodity_category.id)
    commodities_categories.each do |category_child|
      counter += category_child.commodities.count if show == nil
      counter += category_child.commodities_count if show == false
    end
    counter
  end
  
  # This method permit to show categories totals
  def show_categories_totals(category,show, value = 0)
    totals = 0
    if value > 0
      commodities_categories = CommodityCategory.find(:all, :conditions => {:commodity_category_id => category.id})
      commodities_categories = CommodityCategory.find(:all, :conditions => {:commodity_category_id => category.id, :enable => true}) if show == false
      commodities_categories.each do |commodity_category|
        totals += show_categories_totals(commodity_category, show)
      end
      return totals
    end
    commodities = Commodity.find(:all, :conditions => {:commodity_category_id => category.id})
    commodities = Commodity.find(:all, :conditions => {:commodity_category_id => category.id, :enable => true}) if show == false
    commodities.each do |commodity|
      totals += (commodity.fob_unit_price + (commodity.fob_unit_price * commodity.taxe_coefficient)/100)
    end
    totals
  end
  
  # This method permit to have a table's structur
  def get_structured(show = false)
    commodity_categories = CommodityCategory.find_all_by_commodity_category_id(nil)
    commodity_categories = CommodityCategory.root if show == false
    table = []
    # Get structur for parents commodities categories
    commodity_categories.each do |commodity_category|
      
      add_button = add_category_or_commodity(commodity_category) 
      delete_button = show_delete_category_button(commodity_category)
      status = commodity_category.enable ? "enable" : "disable"
      
      table << "<tr id='commodity_category_#{commodity_category.id}' class='#{status}'>"
      table << "<td><img id='commodity_category_#{commodity_category.id}_develop' src='/images/add_10x10.png' alt='D&eacute;rouler' title='D&eacute;rouler' onclick='develop(this.ancestors()[1])' style='display: none;'/> "
      table << "<img id='commodity_category_#{commodity_category.id}_reduce' src='/images/reduce_button_10x10.png' alt='Enrouler' title='Enrouler' onclick='reduce(this.ancestors()[1])'/> " unless commodity_category.children.size == 0
      table << in_place_editor(commodity_category,'name',1)+" (#{show_counter_category(commodity_category,show)})</td>"
      table << "<td colspan='5'></td>"
      table << "<td colspan='3' class='commodity_category'><span class='commodity_category_#{commodity_category.id}_total'>#{show_categories_totals(commodity_category, show, 1)}</span> €</td>"
      table << "<td>#{add_button} #{delete_button}</td>" unless show == nil and commodity_category.enable == false
      table << "</tr>"
      # Get Structur for children commodities categories
      unless commodity_category.children.size == 0
        commodity_category.children.each do |category_child|
          unless category_child.enable == show
            add_button = add_category_or_commodity(category_child)
            delete_button = show_delete_category_button(category_child)
            status = category_child.enable ? "enable" : "disable" if show == nil
             
            table << "<tr id='commodity_category_#{category_child.id}' class='commodity_category_#{commodity_category.id} #{status}'>"
            table << "<td></td>"
            table << "<td>"
            table << "<img id='commodity_category_#{category_child.id}_develop' src='/images/add_10x10.png' alt='D&eacute;rouler' onclick='develop(this.ancestors()[1])' style='display: none;' /> " unless show_counter_category(category_child, show) == 0
            table << "<img id='commodity_category_#{category_child.id}_reduce' src='/images/reduce_button_10x10.png' alt='Enrouler' title='Enrouler' title='D&eacute;rouler' onclick='reduce(this.ancestors()[1])' /> "
            table << in_place_editor(category_child,'name',1)+"(#{show_counter_category(category_child,show)})</td>"
            table << "<td colspan='4'></td>"
            table << "<td colspan='3' class='sub_commodity_category'><span class='sub_commodity_category_#{category_child.id}_total'>#{show_categories_totals(category_child, show)}</span> &euro;</td>"
            table << "<td>#{add_button} #{delete_button}</td>" unless show == nil and category_child.enable == false
            table << "</tr>"

            # Get structur for commodities
            unless category_child.commodities.nil?
              category_child.commodities.each do |commodity|
                unless commodity.enable == show
                  supplier = Supplier.find(commodity.supplier_id)
                  unit_measure = UnitMeasure.find(category_child.unit_measure_id)
                  
                  delete_button = show_delete_commodity_button(commodity,show)
                  
                  status = commodity.enable ? "enable" : "disable" if show == nil
                  table << "<tr id='commodity_#{commodity.id}' class='commodity_category_#{category_child.id} commodity_category_#{commodity_category.id} #{status}'>"
                  table << "<td colspan='2'></td>"
                  table << "<td>#{supplier.name}</td>" #FIXME Add Cities
                  table << "<td>#{in_place_editor(commodity,'name')}</td>"
                  table << "<td>#{in_place_editor(commodity,'measure')} (#{unit_measure.symbol})</td>"
                  table << "<td>#{in_place_editor(commodity,'unit_mass')} kg</td>"
                  table << "<td>#{in_place_editor(commodity,'fob_unit_price')} €/#{unit_measure.symbol}</td>"
                  table << "<td>#{in_place_editor(commodity,'taxe_coefficient')} %</td>"
                  table << "<td><span id='commodity_#{commodity.id}_price' class='total commodity_category_#{commodity_category.id}_total sub_commodity_category_#{category_child.id}_total'>#{commodity.fob_unit_price + (commodity.fob_unit_price * commodity.taxe_coefficient)/100}</span> €/#{unit_measure.symbol}</td>"
                  table << "<td>#{delete_button}</td>"
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
