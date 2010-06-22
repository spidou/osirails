function can_add_supply()
{
  var supply_id = $('add_this_supply_reference_id').value
  
  if (!supply_id)
    return false;
    
  var purchase_order_items = $('purchase_order_supply_form').select('tr.resource')
  var id_already_chosen = false
  
  purchase_order_items.each(function(item) {
    item_id = item.down().value
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


function update_total(id)
{
  $('sum_'.concat(id)).innerHTML = $('total_'.concat(id)).value;
}

function update_unit_price_TTC(id)
{
  $('PU_TTC_'.concat(id)).innerHTML = $('HPU_TTC_'.concat(id)).value;
}

function refresh_lign(id)
{
  var pu_ttc = (parseInt($('taxes_'.concat(id)).value) + 100.0);
  pu_ttc = (pu_ttc / 100.0);
  
  $('HPU_TTC_'.concat(id)).value = (pu_ttc  * parseInt($('fob_unit_price_'.concat(id)).value)).toFixed(2); 
  $('total_'.concat(id)).value = ($('quantity_'.concat(id)).value * $('HPU_TTC_'.concat(id)).value).toFixed(2);
  
  update_unit_price_TTC(id)
  update_total(id);
}

