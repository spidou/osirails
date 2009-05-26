function add_product_reference_to_quote() {
  var product_reference_id = $('add_this_product_reference_id').value
  
  var product_references = $('quotes_product_references').select('tr.quotes_product_reference')
  var reference_already_chosen = false
  var line_reference = null
  
  product_references.each(function(item) {
    item_id = item.down('.product_reference_id').value
    if (product_reference_id == item_id) {
      reference_already_chosen = true
      line_reference = item
      throw $break;
    }
  })
  
  if (reference_already_chosen && line_reference != null && line_reference.getStyle('display') != 'none') {
    old_quantity = parseInt(line_reference.down('.input_quantity').value)
    if ( isNaN(old_quantity) ) { old_quantity = 0 }
    line_reference.down('.input_quantity').value = old_quantity + 1
    calculate(line_reference)
    new Effect.Highlight(line_reference)
  } else {
    if (parseInt(product_reference_id) > 0) {
      new Ajax.Request('/product_references/' + product_reference_id + '.json', {
	      method: 'get',
	      onSuccess: function(transport) {
		      var ref_obj = transport.responseText.evalJSON()["product_reference"];
		      append_reference(ref_obj);
	      }
      });
    }
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
  var reference = json_object['reference'].toString() || json_object['product_reference']['reference'].toString()
  var name = json_object['name']
  var description = json_object['description']
  var quantity = 1
  var unit_price = roundNumber(json_object['unit_price'], 2)
  var discount = roundNumber(0, 2)
  var vat = parseFloat(json_object['vat']); if (vat == 0.0) { vat = 0 };
  var product_reference_id = parseInt(json_object['id'])
  
  var product_references = $('quotes_product_references').select('tr.quotes_product_reference')
  var line_reference = null
  
  line_reference = product_references.last().cloneNode(true);
  
  line_reference.setStyle({display:'table-row'})
  line_reference.select('[class="reference"]').first().update( reference )
  line_reference.select('[class="input_name"]').first().value = name
  line_reference.select('[class="input_original_name"]').first().value = name
  line_reference.select('[class="input_description"]').first().value = description
  line_reference.select('[class="input_original_description"]').first().value = description
  line_reference.select('[class="input_quantity"]').first().value = quantity
  line_reference.select('[class="input_unit_price"]').first().value = unit_price
  line_reference.select('[class="input_original_unit_price"]').first().value = unit_price
  line_reference.select('[class="input_discount"]').first().value = discount
  line_reference.select('[class="input_vat"]').first().value = vat
  
  line_reference.select('td').last().select('input.product_reference_id').first().value = product_reference_id
  
  product_references.last().insert({before: line_reference}); 
  new Effect.Highlight(line_reference)
  
  calculate(line_reference)
  return true;
}

function remove_reference(obj) {
  var tr = obj.up('.quotes_product_reference')
  if ( parseInt(tr.down('.product_reference_id').value) > 0 ) {
    tr.down('.should_destroy').value = 1
    tr.hide();
  } else {
    tr.remove();
  }
  
  update_aggregates()
}

function calculate(tr) {
  var quantity = parseInt(tr.down('.input_quantity').value)
  var unit_price = parseFloat(tr.down('.input_unit_price').value)
  var discount = parseFloat(tr.down('.input_discount').value)
  var vat = parseFloat(tr.down('.input_vat').value)
  var td_unit_price_with_discount = tr.down('.unit_price_with_discount')
  var td_total = tr.down('.total')
  var td_total_with_taxes = tr.down('.total_with_taxes')
  
  if (isNaN(quantity)) { quantity = 0 }
  if (isNaN(unit_price)) { unit_price = 0 }
  if (isNaN(discount)) { discount = 0 }
  if (isNaN(vat)) { vat = 0 }
  
  // unit price with discount
  var unit_price_with_discount = ( unit_price - ( unit_price * ( discount / 100 ) ) )
  td_unit_price_with_discount.update( roundNumber(unit_price_with_discount, 2) )
  
  // total
  var total = ( unit_price_with_discount * quantity )
  td_total.update( roundNumber(total, 2) )
  
  // total with taxes
  var total_with_taxes = ( total + ( total * ( vat / 100 ) ) )
  td_total_with_taxes.update( roundNumber(total_with_taxes, 2) )
  
  update_aggregates()
}

function update_aggregates() {
  var td_aggregate_without_taxes = $('quotes_product_references').down('.aggregate_without_taxes')
  var td_aggregate_with_taxes = $('quotes_product_references').down('.aggregate_with_taxes')
  var td_aggregate_all_taxes = $('quotes_product_references').down('.aggregate_all_taxes')
  
  // aggregates
  var product_references = $('quotes_product_references').select('tr.quotes_product_reference')
  var totals_without_taxes = new Array()
  var totals_with_taxes = new Array()
  
  product_references.each(function(item){
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
  
  // aggregate with taxes
  var aggregate_with_taxes = parseFloat(0)
  totals_with_taxes.each(function(item){
    aggregate_with_taxes += parseFloat(item.innerHTML.toString().trim())
  });
  td_aggregate_with_taxes.update( roundNumber(aggregate_with_taxes, 2) + "&#160;&euro;" )
  
  // aggregate all taxes
  td_aggregate_all_taxes.update( roundNumber(aggregate_with_taxes - aggregate_without_taxes, 2) )
}

// return the string of the float rounded with the specified precision, keeping zeros according to the precision
// x = 109.4687
// roundNumber(x, 1) => 109.5
//
// x = 109.6
// roundNumber(x, 3) => 109.600
function roundNumber(number, precision) {
  precision = parseInt(precision)
	var result = Math.round(parseFloat(number) * Math.pow(10, precision)) / Math.pow(10, precision)
	var str_result = result.toString()
	delimiter = str_result.indexOf(".")
	if (delimiter > 0) {
	  var integer = str_result.substring(0, delimiter)
	  var decimals = str_result.substring(delimiter + 1, str_result.length)
	  if (decimals.length < precision) {
	    for (i = decimals.length; i < precision; i++) {
	      decimals += "0"
	    }
	  }
	  str_result = integer + "." + decimals
	} else {
	  str_result += ".00"
	}
	return str_result
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
