function add_product_reference_to_quote(remote_path, authenticity_token) {
  var product_reference_id = $('add_this_product_reference_id').value
  
  var quote_items = $('quote_items').select('tbody > tr.quote_item').reject(function(tr){
    return parseInt(tr.down('input.should_destroy').value) > 0
  })
  var reference_already_chosen = false
  var line_reference = null
  
  quote_items.each(function(item) {
    item_id = item.down('.product_reference_id').value
    if (product_reference_id == item_id) {
      reference_already_chosen = true
      line_reference = item
      throw $break;
    }
  })
  
  if ( parseInt(product_reference_id) > 0 && ( !reference_already_chosen || ( reference_already_chosen && confirm("Cette référence existe déjà pour ce devis. Êtes-vous sûr de vouloir ajouter une nouvelle ligne avec cette référence ?") ) ) ) {
    new Ajax.Request(remote_path, {
      method: 'post',
      parameters: { 'product_reference_id':product_reference_id,
                    'authenticity_token':authenticity_token },
      onSuccess: function(transport) {
	      $('quote_items').down('tbody').insert({ bottom: transport.responseText })
	      
	      update_up_down_links_and_positions($('quote_items_body'));  // method defined into sales.js
	      initialize_autoresize_text_areas()
	      
	      last_element = $('quote_items').down('tbody').select('tr').last()
	      new Effect.Highlight(last_element, {afterFinish: function(){ last_element.setStyle({backgroundColor: ''}) }})
        //calculate(last_element)
      }
    });
  }
}

function remove_reference(obj) {
  var tr = obj.up('.quote_item')
  if ( parseInt(tr.down('.quote_item_id').value) > 0 ) {
    tr.down('.should_destroy').value = 1
    tr.hide();
  } else {
    tr.remove();
  }
  
  update_aggregates()
  update_up_down_links_and_positions($('quote_items_body'));  // method defined into sales.js
}

function calculate(tr) {
  var quantity = parseFloat(tr.down('.input_quantity').value) || 0
  var unit_price = parseFloat(tr.down('.input_unit_price').value) || 0
  var prizegiving = parseFloat(tr.down('.input_prizegiving').value) || 0
  var vat = parseFloat(tr.down('.input_vat').value) || 0
  var td_unit_price_with_prizegiving = tr.down('.unit_price_with_prizegiving')
  var td_total = tr.down('.total')
  var td_total_with_taxes = tr.down('.total_with_taxes')
  
  if (isNaN(quantity)) { quantity = 0 }
  if (isNaN(unit_price)) { unit_price = 0 }
  if (isNaN(prizegiving)) { prizegiving = 0 }
  if (isNaN(vat)) { vat = 0 }
  
  // unit price with prizegiving
  var unit_price_with_prizegiving = ( unit_price - ( unit_price * ( prizegiving / 100 ) ) )
  td_unit_price_with_prizegiving.update( roundNumber(unit_price_with_prizegiving, 2) )
  
  // total
  var total = ( unit_price_with_prizegiving * quantity )
  td_total.update( roundNumber(total, 2) )
  
  // total with taxes
  var total_with_taxes = ( total + ( total * ( vat / 100 ) ) )
  td_total_with_taxes.update( roundNumber(total_with_taxes, 2) )
  
  update_aggregates()
}

function update_aggregates() {
  var quote_items_container = $('quote_items')
  
  var td_aggregate_without_taxes = quote_items_container.down('.aggregate_without_taxes')
  var td_aggregate_net = quote_items_container.down('.aggregate_net')
  var td_aggregate_net_to_paid = quote_items_container.down('.aggregate_net_to_paid')
  var td_aggregate_all_taxes = quote_items_container.down('.aggregate_all_taxes')
  var td_prizegiving = $('quote_prizegiving')
  var td_carriage_costs = $('quote_carriage_costs')
  var td_prizegiving = $('quote_prizegiving')
  // aggregates
  var quote_items = quote_items_container.select('tr.quote_item')
  var totals_without_taxes = new Array()
  var totals_with_taxes = new Array()
  
  quote_items.each(function(item){
    if (item.getStyle('display') != 'none') {
      totals_without_taxes.push(item.down('.total'))
      totals_with_taxes.push(item.down('.total_with_taxes'))
    }
  });
  
  // aggregate without taxes
  var aggregate_without_taxes = parseFloat(0)
  totals_without_taxes.each(function(item){
    aggregate_without_taxes += parseFloat(item.innerHTML.toString().trim()) || 0
  });
  td_aggregate_without_taxes.update( roundNumber(aggregate_without_taxes, 2) )
  
  // aggregate net
  var prizegiving = parseFloat(td_prizegiving.value) || 0
  var aggregate_net = prizegiving > 0 ? aggregate_without_taxes*(1-(prizegiving/100)) : aggregate_without_taxes;
  td_aggregate_net.update( roundNumber(aggregate_net, 2) + "&#160;&euro;" )
  
  // aggregate with taxes
  var aggregate_with_taxes = parseFloat(0)
  totals_with_taxes.each(function(item){
    aggregate_with_taxes += parseFloat(item.innerHTML.toString().trim()) || 0
  });
  
  // aggregate net to paid
  carriage_costs = parseFloat(td_carriage_costs.value) || 0
  //var aggregate_net_to_paid = aggregate_net + carriage_costs + aggregate_with_taxes + -(aggregate_without_taxes) - prizegiving;
  var aggregate_net_to_paid = prizegiving > 0 ? aggregate_with_taxes*(1-(prizegiving/100)) : aggregate_with_taxes;
  aggregate_net_to_paid += carriage_costs
  td_aggregate_net_to_paid.update( roundNumber(aggregate_net_to_paid, 2) + "&#160;&euro;" )
  
  // aggregate all taxes
  td_aggregate_all_taxes.update( roundNumber(aggregate_with_taxes - aggregate_without_taxes, 2) )
}

function update_account(tax){
  var account = $('quote_account')
  var account_with_taxes = $('quote_account_with_taxes')
  
  account_with_taxes.update(roundNumber(account.value *(1+tax/100), 2))
}

function remove_free_quote_item(element) {
  item = element.up('tr.free_quote_item')
  
  if (parseInt(item.down('.quote_item_id').value) > 0) {
    item.down('.should_destroy').value = 1;
    item.hide();
  } else {
    item.remove();
  }
  
  update_up_down_links_and_positions($('quote_items_body'));  // method defined into sales.js
}
