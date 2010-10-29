module PurchaseOrderSuppliesHelper
  
  def generate_purchase_order_supply_contextual_menu(purchase_order_supply)
    render :partial => 'purchase_order_supplies/contextual_menu', :object => purchase_order_supply
  end
  
  def display_purchase_order_supply_buttons(purchase_order_supply)
    html = []
    html << display_purchase_order_supply_cancel_button(purchase_order_supply, '') unless params[:action] == "cancel_form" or params[:action] == "cancel"
    html.compact.join("&nbsp;")
  end
  
  def display_supply_show_button(supply, message = nil)
    return "" unless supply
    text = "Voir les détails de cette fourniture"
    message ||= " #{text}"
    url = send("#{supply.class.name.underscore}_path", supply)
    link_to( image_tag( "view_16x16.png",
                        :alt => text,
                        :title => text ) + message,
             url, :popup => true )
  end
  
  def display_purchase_order_supply_cancel_button(purchase_order_supply, message = nil)
    return unless PurchaseOrderSupply.can_cancel?(current_user) and purchase_order_supply.can_be_cancelled?
    text = "Annuler cette fourniture"
    message ||= " #{text}"
    link_to( image_tag( "cancel_16x16.png",
                        :alt    => text,
                        :title  => text ) + message,
             purchase_order_purchase_order_supply_cancel_form_path(purchase_order_supply.purchase_order_id, purchase_order_supply.id),
             :confirm => "Êtes-vous sûr ?" )
  end
  
  def display_supply_reference(supply)
    return "-" unless supply 
    supply.type == "Consumable" ? url = consumable_path(supply) : url = commodity_path(supply)
    link_to( supply.reference, url, :popup => true )
  end
  
  def display_purchase_order_supply_unit_price_including_tax(purchase_order_supply)
    unit_price = purchase_order_supply.unit_price_including_tax
    unit_price.to_f.to_s(2)
  end
  
  def display_purchase_order_supply_total(purchase_order_supply, supplier_id = 0, supply_id = 0)
    return "0" if supplier_id == 0 or supply_id == 0
    if purchase_order_supply.new_record?
      if supplier_supply = purchase_order_supply.supplier_supply(supplier_id, supply_id)
        (purchase_order_supply.quantity.to_f * (supplier_supply.fob_unit_price.to_f * ((100 + supplier_supply.taxes.to_f)/100))).to_f.to_s(2)
      else
        return "0"
      end
    else
      return "0" unless purchase_order_supply
       purchase_order_supply.purchase_order_supply_total.to_f.to_s(2)
    end
  end
  
  def display_purchase_order_supply_status(purchase_order_supply)
    if purchase_order_supply.untreated?
      "Non traité"
    elsif purchase_order_supply.processing_by_supplier?
      "En traitement"
    elsif purchase_order_supply.treated?
      "Traité"
    elsif purchase_order_supply.cancelled?
      "Annulé"
    end
  end
  
  def display_purchase_order_supply_current_status_date(purchase_order_supply)
    if purchase_order_supply.untreated?
      purchase_order_supply.created_at ? purchase_order_supply.created_at.humanize : "Aucune date de création"
    elsif purchase_order_supply.processing_by_supplier?
      purchase_order_supply.purchase_delivery_items.first.created_at ? purchase_order_supply.purchase_delivery_items.first.created_at.humanize : "Aucune date de début de traitement"
    elsif purchase_order_supply.treated?
      purchase_order_supply.purchase_delivery_items.last.created_at ? purchase_order_supply.purchase_delivery_items.last.created_at.humanize : ""
    elsif purchase_order_supply.was_cancelled?
      purchase_order_supply.cancelled_at ? purchase_order_supply.cancelled_at.humanize : "Aucune date d'annulation"
    end
  end
  
  def display_purchase_order_supply_associated_purchase_requests(purchase_order_supply)
    html = []
    associated_purchase_requests_supplies = purchase_order_supply.purchase_request_supplies
    return if associated_purchase_requests_supplies.empty?
    for purchase_request_supply in associated_purchase_requests_supplies
      html << link_to(purchase_request_supply.purchase_request.reference, purchase_request_path(purchase_request_supply.purchase_request))
    end
    html.compact.join("<br />")
  end
  
    
  def display_purchase_order_supply_associated_purchase_deliveries(purchase_order_supply)
    return unless purchase_order_supply.purchase_deliveries.any?
    html = []
    for purchase_delivery in purchase_order_supply.purchase_deliveries
      html << "<tr><td>" + link_to( purchase_delivery.reference, purchase_order_purchase_delivery_path(purchase_order_supply.purchase_order, purchase_delivery)) + "</td></tr>"
    end
    html << "<tr><td></td></tr>" if html.empty?
    html.compact.join()
  end
  
  def display_purchase_order_supply_supplier_designation(purchase_order_supply)
    return purchase_order_supply.supplier_designation if purchase_order_supply.supplier_designation
    purchase_order_supply.supplier_supply.supplier_designation
  end
  
  def display_purchase_order_supply_supplier_reference(purchase_order_supply)
    return unless purchase_order_supply.supplier_reference or purchase_order_supply.supplier_supply.supplier_reference
    purchase_order_supply.supplier_reference or purchase_order_supply.supplier_supply.supplier_reference
  end
  
  def display_purchase_order_lead_time(purchase_order_supply)
    lead_time = purchase_order_supply.supplier_supply.lead_time
    if !lead_time
      "Non renseigné"
    elsif lead_time == 0
      "Immédiat"
    else
      lead_time.to_s + "&nbsp;jour(s)"
    end
  end
  
  def display_purchase_order_supply_reshipped_from_purchase_delivery(purchase_order_supply)
    return unless purchase_order_supply.issued_purchase_delivery_item
    link_to purchase_order_supply.issued_purchase_delivery_item.purchase_delivery.reference, purchase_order_purchase_delivery_path(purchase_order_supply.purchase_order, purchase_order_supply.issued_purchase_delivery_item.purchase_delivery)
  end
  
  def display_type_for(supply)
    return "Matière première" if supply.type == "Commodity"
    return "Consomable" if supply.type == "Consumable" 
  end
  
  def display_add_unreferenced_supply_for_(purchase_order)
    button_to_function "Ajouter un article non referenc&eacute;" do |page|
      page.insert_html :bottom, :purchase_order_supply_form, :partial => 'purchase_order_supplies/purchase_order_supply_in_one_line',
                                                   :object  => purchase_order.purchase_order_supplies.build, :locals => { :purchase_order => purchase_order, :supplier => purchase_order.supplier }
      
      last_item = page["purchase_order_supply_form"].select('.unreferenced_supply').last.show.visual_effect "highlight" # :highlight symbol replaced by "highlight" string to relieve to the "undefined method `ascii_only?' for {}:Hash" error, in views
      page << "initialize_autoresize_text_areas();update_up_down_links($('purchase_order_supply_form'));"
    end
  end
  
  def display_add_comment_line_for_(purchase_order)
    purchase_order_supply = purchase_order.purchase_order_supplies.build
    purchase_order_supply.comment_line = true
    button_to_function "Ajouter une ligne de commentaire" do |page|
      page.insert_html :bottom, :purchase_order_supply_form, :partial => 'purchase_order_supplies/purchase_order_comment_line_in_one_line',
                                                   :object  => purchase_order_supply, :locals => { :purchase_order => purchase_order, :supplier => purchase_order.supplier }
      
      last_item = page["purchase_order_supply_form"].select('.comment_line').last.show.visual_effect "highlight" # :highlight symbol replaced by "highlight" string to relieve to the "undefined method `ascii_only?' for {}:Hash" error, in views
      page << "initialize_autoresize_text_areas();update_up_down_links($('purchase_order_supply_form'));"
      page << ""
    end
  end
  
end
