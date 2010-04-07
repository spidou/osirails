function add_product_reference_to_quote() {
  var product_reference_id = $('add_this_product_reference_id').value
  
  var quote_items = $('quote_items').select('tbody > tr.quote_item')
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
  
//  if (reference_already_chosen && line_reference != null && line_reference.getStyle('display') != 'none') {
//    old_quantity = parseInt(line_reference.down('.input_quantity').value)
//    if ( isNaN(old_quantity) ) { old_quantity = 0 }
//    line_reference.down('.input_quantity').value = old_quantity + 1
//    calculate(line_reference)
//    new Effect.Highlight(line_reference)
//  } else {
//    if (parseInt(product_reference_id) > 0) {
//      new Ajax.Request('/product_references/' + product_reference_id + '.json', {
//	      method: 'get',
//	      onSuccess: function(transport) {
//		      var ref_obj = transport.responseText.evalJSON()["product_reference"];
//		      append_reference(ref_obj);
//	      }
//      });
//    }
//  }
  if ( parseInt(product_reference_id) > 0 && ( !reference_already_chosen || ( reference_already_chosen && confirm("Cette référence existe déjà pour ce devis. Êtes-vous sûr de vouloir ajouter une nouvelle ligne avec cette référence ?") ) ) ) {
    new Ajax.Request('/product_references/' + product_reference_id + '.json', {
      method: 'get',
      onSuccess: function(transport) {
	      var ref_obj = transport.responseText.evalJSON()["product_reference"];
	      append_reference(ref_obj);
	      
	      update_up_down_links($('quote_items_body'));  // method defined into sales.js
      }
    });
  }
}

//function add_buttons_in_catalog () {
//  var catalog = $('catalog');
//  var div_elm = new Element('div')
//  div_elm.appendChild( new Element('button', { 'style' : 'float: right', 'onclick' : 'osibox_close(); return false;' }).update("Fermer") )
//  div_elm.appendChild( new Element('button', { 'style' : 'float: right', 'onclick' : 'add_reference(); return false;' }).update("Ajouter") )
//  div_elm.appendChild( new Element('button', { 'style' : 'float: right', 'onclick' : 'add_reference(); osibox_close(); return false' }).update("Ajouter et fermer") )
//  catalog.appendChild(div_elm);
//}

//function add_reference () {
//  var all_ref = $('select_reference').childElements();
//  if (all_ref.first().selected) { alert('Veuillez sélectionner une référence'); return false; };
//  for (var i = 0; i < all_ref.length; i++) {
//	  if (all_ref[i].selected) {
//		  new Ajax.Request('/product_references/' + all_ref[i].value + '.json', {
//			  method: 'get',
//			  onSuccess: function(transport) {
//				  var ref_obj = transport.responseText.evalJSON()["product_reference"];
//				  append_reference(ref_obj);
//			  }
//		  });
//		  return true;
//	  };
//  };
//  return false;
//}
  
function append_reference(json_object) {
  var reference             = json_object['reference'].toString() || json_object['product_reference']['reference'].toString()
  var designation           = json_object['designation']
  var description           = json_object['description']
  var quantity              = 1
  var vat                   = parseFloat(json_object['vat']); if (vat == 0) { vat = "0.0" };
  var product_reference_id  = parseInt(json_object['id'])
  var quote_body            = $('quote_items').down('tbody')
  var quote_items           = $('quote_items').select('tbody > tr.quote_item')
  var model                 = $('quote_items').down('tfoot > tr.quote_item')
  var line_reference        = null
  
  line_reference = model.cloneNode(true);
  quote_body.insert( {bottom : line_reference});
  
  line_reference.down('.reference').update( reference )
  line_reference.down('.input_name').value = designation
  line_reference.down('.input_original_name').value = designation
  line_reference.down('.input_description').value = description
  line_reference.down('.input_original_description').value = description
  line_reference.down('.input_quantity').value = quantity
  line_reference.down('.input_vat').value = vat
  line_reference.down('.input_original_vat').value = vat
  line_reference.select('td').last().down('.product_reference_id').value = product_reference_id
  
  line_reference.setStyle({display:'table-row'})
  new Effect.Highlight(line_reference, {afterFinish: function(){ line_reference.setStyle({backgroundColor: ''}) }})
  
  calculate(line_reference)
  return true;
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
  update_up_down_links($('quote_items_body'));  // method defined into sales.js
}

function calculate(tr) {
  var quantity = parseFloat(tr.down('.input_quantity').value)
  var unit_price = parseFloat(tr.down('.input_unit_price').value)
  var prizegiving = parseFloat(tr.down('.input_prizegiving').value)
  var vat = parseFloat(tr.down('.input_vat').value)
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
    aggregate_without_taxes += parseFloat(item.innerHTML.toString().trim())
  });
  td_aggregate_without_taxes.update( roundNumber(aggregate_without_taxes, 2) )
  
  // aggregate net
  var aggregate_net = aggregate_without_taxes*(1-(parseFloat(td_prizegiving.value)/100));
  td_aggregate_net.update( roundNumber(aggregate_net, 2) + "&#160;&euro;" )
  
  // aggregate with taxes
  var aggregate_with_taxes = parseFloat(0)
  totals_with_taxes.each(function(item){
    aggregate_with_taxes += parseFloat(item.innerHTML.toString().trim())
  });
  
  // aggregate net to paid
  var aggregate_net_to_paid = aggregate_net + parseFloat(td_carriage_costs.value) + aggregate_with_taxes + -(aggregate_without_taxes) - parseFloat(td_prizegiving.value);
  td_aggregate_net_to_paid.update( roundNumber(aggregate_net_to_paid, 2) + "&#160;&euro;" )
  
  // aggregate all taxes
  td_aggregate_all_taxes.update( roundNumber(aggregate_with_taxes - aggregate_without_taxes, 2) )
}

function update_account(tax){
  var account = $('quote_account')
  var account_with_taxes = $('quote_account_with_taxes')
  
  account_with_taxes.update(roundNumber(account.value *(1+tax/100), 2))
}

function restore_original_value(element, value) {
  if (value.length > 0) {
    input = element.down('.input_' + value)
    original = element.down('.input_original_' + value)
    if (input != null && original != null && original.value.length > 0) {
      input.value = original.value
    }
  }
}

function remove_free_quote_item(element) {
  item = element.up('tr.free_quote_item')
  
  if (parseInt(item.down('.quote_item_id').value) > 0) {
    item.down('.should_destroy').value = 1;
    item.hide();
  } else {
    item.remove();
  }
  
  update_up_down_links($('quote_items_body'));  // method defined into sales.js
}
