// This method permit to calculate the difference between actual and real stock quantity
function quantity_difference(supply_id) {
  // Variables
  var actual = document.getElementById('actual_stock_quantity_for_supplier_supply_'+supply_id).innerHTML;
  var real = document.getElementById('real_stock_quantity_for_supplier_supply_'+supply_id).value;

  // Calcul
  var difference = parseFloat(real) - parseFloat(actual);
  
  // Display variable    
  var text;
  
  if(real >= 0){
    if(difference > 0){
      text = "+"+difference.toFixed(1);
    }
    else{text = difference.toFixed(1);}   
  }
  else{text = "invalide";}
  
  if(text == "NaN"){
    text = "invalide";
  }  

  // Apply changes
  if(difference > 0){
    document.getElementById('fob_for_supplier_supply_'+supply_id).disabled = false
    document.getElementById('tax_coefficient_for_supplier_supply_'+supply_id).disabled = false
  }
  else
  {
    document.getElementById('fob_for_supplier_supply_'+supply_id).disabled = true
    document.getElementById('tax_coefficient_for_supplier_supply_'+supply_id).disabled = true
  }
  document.getElementById('difference_for_supplier_supply_'+supply_id).innerHTML = text;
}
