module QuotationSuppliesHelper
  def display_add_free_quotation_supply_for(quotation)
    button_to_function "Ajouter une fourniture qui n'existe pas dans la base"  do |page|
      page.insert_html :bottom, :quotation_supplies_body, :partial => 'quotation_supplies/quotation_supply', :object  => quotation.quotation_supplies.build, :locals => {:quotation => quotation}
      last_item = page["quotation_supplies_body"].select('.free_quotation_supply').last.show.visual_effect "highlight" # :quotation_supplies_body  symbol replaced by "quotation_supplies_body" string and :highlight symbol replaced by "highlight" string to relieve to the "undefined method `ascii_only?' for {}:Hash" error
      
      page << "update_up_down_links($('quotation_supplies_body'))"
    end
  end
end
