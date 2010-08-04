function can_add_supply()
{
  var supply_id = $('add_this_supply_reference_id').value
  
  if (!supply_id)
    return false;
    
  var purchase_order_items = $('purchase_order_supply_form').select('tr.resource')
  var id_already_chosen = false
  var is_should_destroy = false
  
  purchase_order_items.each(function(item) {
    item_id = item.down('.hidden_supply_id').value;
    should_destroy = item.down('.should_destroy').value;
    if (supply_id == item_id) {
      if (parseInt(should_destroy) == 1){
        unmark_resource_for_destroy(item);
        is_should_destroy = true;
      }
      id_already_chosen = true;
      throw $break;
    }
  })

  if (id_already_chosen){
    if (!is_should_destroy){
      alert("Ce produit existe deja dans votre liste. Vous ne pouvez pas le rajouter une seconde fois."); 
    }
    return false;
  }
  return true; 
}

function can_add_request_supply()
{
  var supply_id = $('add_this_supply_reference_id').value
  
  if (!supply_id)
    return false;
  return true; 
}

function update_all_total()
{
  var res = 0.0;
  $('purchase_order_supply_form').select('.sum').each(function(item) {
      res += parseFloat(item.innerHTML || 0);    
  });
  $('all_total').innerHTML = res.toFixed(2);
  $('all_total').value = res.toFixed(2);
}


function refresh_lign(parent)
{
  var quantity = parseFloat(parent.down('.quantity').value) || 0.0;
  var taxes = parseFloat(parent.down('.taxes').value) || 0.0;
  var unit_price_HT = parseFloat(parent.down('.fob_unit_price').value) || 0.0;

  var taxes_in_purcent = (taxes + 100.0) / 100.0;
  var unit_price_TTC = unit_price_HT * taxes_in_purcent;
  
  var res = quantity * unit_price_TTC;
  parent.down('.PU_TTC').innerHTML = unit_price_TTC.toFixed(2);
  parent.down('.sum').innerHTML = res.toFixed(2);
  update_all_total();
}

function update_purchase_request_supplies_ids(element, parent)
{
  var quantity = element.readAttribute('data_quantity');
  var check = parseInt(element.readAttribute('idx'));
  var id = element.readAttribute('id');
  var purchase_request_supply_ids = parent.down('.purchase_request_supplies_ids');
  var purchase_request_supply_deselected_ids = parent.down('.purchase_request_supplies_deselected_ids');
  
  if (check == 0)
  {
    var tab_deselected_ids = purchase_request_supply_deselected_ids.value.split(';')
    var result = ""
    for (i = 0; i < tab_deselected_ids.length; i++){
      if (parseInt(tab_deselected_ids[i]) != parseInt(id) && tab_deselected_ids[i] != "")
          result += tab_deselected_ids[i]+";"
    }
    purchase_request_supply_deselected_ids.value = result;
    purchase_request_supply_deselected_ids.innerHTML = result;
    purchase_request_supply_ids.value = purchase_request_supply_ids.value.concat(id + ";");
    purchase_request_supply_ids.innerHTML =  purchase_request_supply_ids.value;
    element.setAttribute('idx','1');
  }
  else
  {
    var tab_ids = purchase_request_supply_ids.value.split(';')
    var result = ""
    for (i = 0; i < tab_ids.length; i++){
      if (parseInt(tab_ids[i]) != parseInt(id) && tab_ids[i] != "")
          result += tab_ids[i]+";"
    }
    element.setAttribute('idx','0');
    purchase_request_supply_ids.value = result;
    purchase_request_supply_ids.innerHTML = result;
    purchase_request_supply_deselected_ids.value = purchase_request_supply_deselected_ids.value.concat(id + ";");
    purchase_request_supply_deselected_ids.innerHTML =  purchase_request_supply_deselected_ids.value;
  }
}  

function disabled_or_enabled_quantity_text_field(element)
{  
  var id = element.down('.purchase_order_supply_id').value
  var quantity_field = "quantity_field_".concat(id);
  var span_quantity = "span_quantity_".concat(id);
  var selected = element.down('.selected')
  
  if (parseInt(selected.value) == 0)
    selected.value = 1
  else
    selected.value = 0
    
  Effect.toggle(quantity_field, 'appear', { duration: 0.0 });
  Effect.toggle(span_quantity, 'appear', { duration: 0.0 }); 
}

function mark_resource_for_destroy(element) {
  element.down('.should_destroy').value = 1;
  element.down('.sum').innerHTML = 0;
  element.hide();
  update_all_total()
}

function unmark_resource_for_destroy(element) {
  element.down('.should_destroy').value = "";
  element.down('.sum').innerHTML = 0;
  element.show();
  refresh_lign(element);
}
