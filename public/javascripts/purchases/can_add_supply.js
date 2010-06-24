function can_add_supply()
{
  var supply_id = $('add_this_supply_reference_id').value
  
  if (!supply_id)
    return false;
    
  var purchase_order_items = $('purchase_order_supply_form').select('tr.resource')
  var id_already_chosen = false
  
  purchase_order_items.each(function(item) {
    item_id = item.down('.hidden_supply_id').value
    if (supply_id == item_id) {
      id_already_chosen = true
      throw $break;
    }
  })
  
  if (id_already_chosen){
    alert("Ce produit existe deja dans votre liste. Vous ne pouvez pas le rajouter une seconde fois."); 
    return false;
  }
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

