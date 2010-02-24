module SuppliesManagerHelper
  # This method permit to add a button for add a sub category
  def add_category_or_supply(supply_category)
    if supply_category.class.can_add?(current_user) and supply_category.enable
      if supply_category.send("#{supply_category.class.name.tableize.singularize}_id").nil?
        text = "Nouvelle sous-catégorie"
        link_to(image_tag("/images/arrow_up_16x16.png", :alt => text , :title => text), self.send("new_#{supply_category.class.name.tableize.singularize}_path",:id => supply_category.id, :type => "child"))
      else
        text = (supply_category.class.name.underscore.gsub("_category","") == 'consumable' ? 'Nouveau consommable' : 'Nouvelle matière première')
        #"Add a #{supply_category.class.name.underscore.gsub("_category","")}"
        link_to(image_tag("/images/add_16x16.png", :alt => text, :title => text), self.send("new_#{supply_category.class.name.tableize.singularize.gsub("_category","")}_path",:id => supply_category.id))
      end
    end
  end
  
  # This method permit to show or hide reactivate button for categories
  def reactivate_category_link(supply_category)
    if supply_category.class.can_reactivate?(current_user)
      link_to(image_tag("/images/tick_16x16.png", :alt => "Réactiver", :title => "Réactiver"), self.send("reactivate_#{supply_category.class.name.underscore}_path",supply_category)) if supply_category.can_be_reactivated?
    end
  end
  
  # This method permit to show or hide disable button for categories
  def disable_category_link(supply_category)
    if supply_category.class.can_disable?(current_user)
      link_to(image_tag("/images/delete_disable_16x16.png", :alt => "Désactiver", :title => "Désactiver"), self.send("disable_#{supply_category.class.name.underscore}_path",supply_category), :confirm => "Êtes-vous sûr ?") if supply_category.can_be_disabled?
    end
  end

  # This method permit to show or hide delete button for categories
  def delete_category_link(supply_category)
    if supply_category.class.can_delete?(current_user)
      link_to(image_tag("/images/delete_16x16.png", :alt => "Supprimer", :title => "Supprimer"), supply_category, { :method => :delete, :confirm => 'Êtes vous sûr  ?'}) if supply_category.can_be_destroyed?
    end
  end

  # This method permit to show a supply
  def supply_link(supply)
    if supply.class.can_view?(current_user)
      link_to(image_tag("/images/view_16x16.png", :alt => "Voir", :title => "Voir"), supply,  { :controller => "#{supply.class.name.tableize}", :action => 'show'})
    end
  end

  # This method permit to edit a supply
  def edit_supply_link(supply, button = false)
    if supply.class.can_edit?(current_user)
      text = "" unless button
      text ||= "Modifier " + (supply.class.name.tableize.singularize=='consumable' ? 'le consommable' : 'la matière première')
      #"Edit this #{supply.class.name.tableize.singularize}"
      link_to("#{image_tag("/images/edit_16x16.png", :alt => "Éditer", :title => "Éditer")} #{text}", send("edit_#{supply.class.name.tableize.singularize}_path",supply)) unless !supply.enable
    end
  end
  
  # This method permit to show or hide disable button for supplies
  def disable_supply_link(supply,button = false)
    if supply.class.can_disable?(current_user)
      text = "" unless button
      text ||= "Désactiver " + (supply.class.name.tableize.singularize=='consumable' ? 'le consommable' : 'la matière première')
      #"Disable this #{supply.class.name.tableize.singularize}"
      if supply.can_be_disabled?
        title = "Désactiver"
        link_to("#{image_tag("/images/delete_16x16.png")} #{text}", self.send("disable_#{supply.class.name.underscore}_path",supply), :confirm => "Êtes-vous sûr ?", :alt => title, :title => title)
      elsif supply.stock_quantity.to_i > 0
        title = "Impossible de désactiver tant que la quantité n'est pas à 0"
        "#{image_tag("/images/delete_disable_16x16.png", :alt => title, :title => title)} #{text}"
      end
    end
  end

  # This method permit to show or hide delete button for supplies
  def delete_supply_link(supply, button = false)
    if supply.class.can_delete?(current_user)
      text = "" unless button
      text ||= "Supprimer " + (supply.class.name.tableize.singularize=='consumable' ? 'le consommable' : 'la matière première')
      #"Delete this #{supply.class.name.tableize.singularize}"
      link_to("#{image_tag("/images/delete_16x16.png", :alt => "Supprimer", :title => "Supprimer")} #{text}", supply,  { :controller => "#{supply.class.name.tableize}", :action => 'destroy', :method => :delete, :confirm => 'Êtes-vous sûr  ?'}) if supply.can_be_destroyed?
    end
  end
  
  # This method permit to show or hide reactivate button for supplies
  def reactivate_supply_link(supply, button = false)
    if supply.class.can_reactivate?(current_user)
      text = "" unless button
      text ||= "Réactiver " + (supply.class.name.tableize.singularize=='consumable' ? 'le consommable' : 'la matière première')
      #"Reactivate this #{supply.class.name.tableize.singularize}"
      link_to("#{image_tag("/images/tick_16x16.png", :alt => "Réactiver", :title => "Réactiver")} #{text}", self.send("reactivate_#{supply.class.name.underscore}_path",supply)) if supply.can_be_reactivated?
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
  def supply_categories_link(supply_type)
    if supply_type.can_list?(current_user)
      text = "Voir toutes les catégories"
      #"List all #{supply_type.name.tableize.humanize.downcase}"
      link_to("#{image_tag( "/images/list_16x16.png", :alt => text, :title => text )} #{text}", "/#{supply_type.name.tableize.singularize.gsub("_category","").pluralize}_manager")
    end
  end
  
  def supply_categories_link_with_inactives(supply_type)
    if supply_type.can_list?(current_user)
      text = "Voir toutes les catégories annulées"
      #"List all #{supply_type.name.tableize.humanize.downcase} (including inactives)"
      link_to("#{image_tag( "/images/list_16x16.png", :alt => text, :title => text )} #{text}", "/#{supply_type.name.tableize.singularize.gsub("_category","").pluralize}_manager?inactives=true")
    end
  end

  # This method permit to make in table editor
  def in_place_editor(object, attribute, is_supply = false) 
    if object.class.can_edit?(current_user) and (!is_supply or (is_supply and !object.has_been_used?))
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
  def display_average_unit_price(supply, date = Date.today)
    supply.average_unit_price.nil? ? '//' : number_with_precision(supply.average_unit_price(date).round(2).to_s,2) + ' €'
  end
  
  # This method permit to display the total measure of a supply stock
  def display_total_measure(supply, date = Date.today)
    return "//" if supply.stock_quantity.nil? or supply.measure.nil?
    number_with_precision(supply.stock_quantity(date)*supply.measure,1) + " " + UnitMeasure.find(supply.supply_category.unit_measure_id).symbol
  end
  
  # This method permit to display the total measure of a supply_supplier stock
  def display_supply_supplier_total_measure(supply_supplier, date = Date.today)
    return "//" if supply_supplier.stock_quantity.nil? or supply_supplier.supply.measure.nil?
    number_with_precision(supply_supplier.stock_quantity(date)*supply_supplier.supply.measure,1) + " " + UnitMeasure.find(supply_supplier.supply.supply_category.unit_measure_id).symbol
  end
  
  # This method permit to display the total mass of a supply stock
  def display_total_mass(supply, date = Date.today)
    return "//" if supply.stock_quantity.nil? or supply.unit_mass.nil?
    number_with_precision(supply.stock_quantity(date)*supply.unit_mass,1) + " kg"
  end

  def display_category_stock_value(category, date = Date.today)
    number_with_precision(category.stock_value(date),2) + " €"
  end
end
