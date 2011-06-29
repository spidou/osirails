function check_quantity(tr) {
  if (parseInt(tr.down('.input_quantity').value) == 0) {
    tr.addClassName("empty_line")
  } else {
    tr.removeClassName("empty_line")
  }
}

//function calculate(tr) {
//  var quantity = parseFloat(tr.down('.input_quantity').value)
//  var unit_price_with_discount = parseFloat(tr.down('.unit_price_with_discount').innerHTML.toString().trim())
//  var vat = parseFloat(tr.down('.vat').innerHTML.toString().trim())
//  //var unit_price = parseFloat(tr.down('.input_unit_price').value)
//  //var discount = parseFloat(tr.down('.input_discount').value)
//  //var vat = parseFloat(tr.down('.input_vat').value)
//  var td_total_for_delivery = tr.down('.total_for_delivery')
//  var td_total_with_taxes_for_delivery = tr.down('.total_with_taxes_for_delivery')
//  
//  if (isNaN(quantity)) { quantity = 0 }
//  if (isNaN(unit_price_with_discount)) { unit_price_with_discount = 0 }
//  if (isNaN(vat)) { vat = 0 }
//  
//  // total for delivery
//  var total_for_delivery = ( unit_price_with_discount * quantity )
//  td_total_for_delivery.update( roundNumber(total_for_delivery, 2) )
//  
//  // total with taxes for delivery
//  var total_with_taxes_for_delivery = ( total_for_delivery + ( total_for_delivery * ( vat / 100 ) ) )
//  td_total_with_taxes_for_delivery.update( roundNumber(total_with_taxes_for_delivery, 2) )
//  
//  update_aggregates()
//}

//function update_aggregates() {
//  var delivery_note_items_container = $('delivery_note_items')
//  
//  var td_aggregate_without_taxes = delivery_note_items_container.down('.aggregate_without_taxes')
//  var td_aggregate_all_taxes = delivery_note_items_container.down('.aggregate_all_taxes')
//  var td_aggregate_with_taxes = delivery_note_items_container.down('.aggregate_with_taxes')
//  
//  // aggregates
//  var delivery_note_items = delivery_note_items_container.select('tr.delivery_note_item')
//  var totals_without_taxes = new Array()
//  var totals_with_taxes = new Array()
//  
//  delivery_note_items.each(function(item){
//    totals_without_taxes.push(item.down('.total_for_delivery'))
//    totals_with_taxes.push(item.down('.total_with_taxes_for_delivery'))
//  });
//  
//  // aggregate without taxes
//  var aggregate_without_taxes = parseFloat(0)
//  totals_without_taxes.each(function(item){
//    aggregate_without_taxes += parseFloat(item.innerHTML.toString().trim())
//  });
//  td_aggregate_without_taxes.update( roundNumber(aggregate_without_taxes, 2) )
//  
//  // aggregate with taxes
//  var aggregate_with_taxes = parseFloat(0)
//  totals_with_taxes.each(function(item){
//    aggregate_with_taxes += parseFloat(item.innerHTML.toString().trim())
//  });
//  td_aggregate_with_taxes.update( roundNumber(aggregate_with_taxes, 2) )
//  
//  // aggregate all taxes
//  td_aggregate_all_taxes.update( roundNumber(aggregate_with_taxes - aggregate_without_taxes, 2) )
//}
