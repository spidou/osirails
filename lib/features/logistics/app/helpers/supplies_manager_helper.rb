module SuppliesManagerHelper

  # This method permit to add a button for add a sub category
  def add_category_or_supply(supply_category)
    if supply_category.class.can_add?(current_user)
      if supply_category.send("#{supply_category.class.name.tableize.singularize}_id").nil?
        link_to("Add a sub category", self.send("new_#{supply_category.class.name.tableize.singularize}_path",:id => supply_category.id, :type => "child"))
      else
        link_to("Add a #{supply_category.class.name.tableize.singularize.gsub("_category","")}", self.send("new_#{supply_category.class.name.tableize.singularize.gsub("_category","")}_path",:id => supply_category.id))
      end
    end
  end

  # This method permit to show or hide delete button for categories
  def delete_category_link(supply_category)
    if supply_category.class.can_delete?(current_user)
      link_to(image_tag("url", :alt => "Supprimer"), supply_category, { :method => :delete, :confirm => 'Etes vous sûr  ?'}) if supply_category.can_be_destroyed?
    end
  end

  # This method permit to show a supply
  def supply_link(supply)
    if supply.class.can_view?(current_user)
      link_to(image_tag("/images/view_16x16.png", :alt => "Voir", :title => "Voir"), supply,  { :controller => "#{supply.class.name.tableize}", :action => 'show'})
    end
  end

  # This method permit to edit a supply
  def edit_supply_link(supply,button=false)
    if supply.class.can_edit?(current_user)
      text = ""
      text = " Edit this #{supply.class.name.tableize.singularize}" if button
      link_to(image_tag("/images/edit_16x16.png", :alt => "Éditer", :title => "Éditer")+text, send("edit_#{supply.class.name.tableize.singularize}_path",supply))
    end
  end

  # This method permit to show or hide delete button forsupplies
  def delete_supply_link(supply,button=false)
    if supply.class.can_delete?(current_user)
      text = ""
      text = " Delete this #{supply.class.name.tableize.singularize}" if button
      link_to(image_tag("/images/delete_16x16.png", :alt => "Supprimer", :title => "Supprimer")+text, supply,  { :controller => "#{supply.class.name.tableize}", :action => 'destroy', :method => :delete, :confirm => 'Etes vous sûr  ?'}) unless supply.enable == false
    end
  end

  # This method permit to format link that should be display into secondary menu
  # we can't use the dynamic helper method 'generator' because of an unexpected argument passed to new_'supply'_path => ':id =>-1'
  def new_supply_link(supply)
    if supply.class.can_add?(current_user)
      link_to(image_tag( "/images/add_16x16.png", :alt => "New", :title => "New" )+" New #{supply.class.name.tableize.singularize}", self.send("new_#{supply.class.name.tableize.singularize}_path",:id => -1) )
    end
  end

  # method that permit to access to commodities categories list using /supplies_manager route
  def supply_categories_link(supply_category)
    if supply_category.class.can_list?(current_user)
      link_to(image_tag( "/images/list_16x16.png", :alt => "List", :title => "List" )+" List all #{supply_category.class.name.tableize.humanize.downcase}", "/#{supply_category.class.name.tableize.singularize.gsub("_category","").pluralize}_manager")
    end
  end

  # This method permit to make in table editor
  def in_place_editor(object,attribute)
    if object.class.can_edit?(current_user)
      return editable_content_tag(:span, object, "#{attribute}", true, nil, {:class => 'in_line_editor_span'}, {:clickToEditText => 'Cliquer pour modifier...', :savingText => 'Mise &agrave; jour', :submitOnBlur => true, :cancelControl => false, :okControl => false})
    end
    "<span>#{object.send(attribute)}</span>"
  end

  # This method permit to generate a counter for categories
  def show_counter_category(supply_category)
    counter = 0

    return supply_category.send("#{supply_category.class.name.tableize.singularize.gsub("_category","").pluralize}_count") if !supply_category.send("#{supply_category.class.name.tableize.singularize}_id").nil?

    supply_categories = supply_category.class.send("find_all_by_#{supply_category.class.name.tableize.singularize}_id",supply_category.id)
    supply_categories.each do |category_child|
      counter += category_child.send("#{supply_category.class.name.tableize.singularize.gsub("_category","").pluralize}_count")
    end
    counter
  end

  # This method permit to display the 1st supplier in the supplies index
  # and a link to all suppliers if necessary
  def display_suppliers(supply)
    html = ""
    html << supply.suppliers.first.name
    if supply.suppliers.size > 1
      html <<  "<br/>"+link_to("voir tous", "/#{supply.class.name.tableize}/#{supply.id}#supplier_supplies")
    end
    html
  end

  # This method permit to display the average unit price according to
  # all supplier_supplies price
  def display_average_unit_price(supply,date=Date.today)
    supply.average_unit_price.nil? ? '//' : number_with_precision(supply.average_unit_price(date).round(2).to_s,2) + ' €'
  end
  
  # This method permit to display the total measure of a supply stock
  def display_total_measure(supply,date=Date.today)
    supply.stock_quantity.nil? ? '//' : number_with_precision(supply.stock_quantity(date)*supply.measure,1) + " " + UnitMeasure.find(supply.send("#{supply.class.name.underscore}_category").unit_measure_id).symbol
  end
  
  # This method permit to display the total measure of a supply_supplier stock
  def display_supply_supplier_total_measure(supply_supplier,date=Date.today)
    supply_supplier.stock_quantity.nil? ? '//' : number_with_precision(supply_supplier.stock_quantity(date)*supply_supplier.supply.measure,1) + " " + UnitMeasure.find(supply_supplier.supply.send("#{supply_supplier.supply.class.name.underscore}_category").unit_measure_id).symbol
  end
  
  # This method permit to display the total mass of a supply stock
  def display_total_mass(supply,date=Date.today)
    supply.stock_quantity.nil? ? '//' : number_with_precision(supply.stock_quantity(date)*supply.unit_mass,1) + " kg"
  end

  def display_category_stock_value(category,date=Date.today)
    number_with_precision(category.stock_value(date),2) + " €"
  end
end

