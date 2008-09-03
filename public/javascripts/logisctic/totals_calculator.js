// This method permit to calculate measure total

function totals_calculator(element) {
 
 position = element.id.lastIndexOf("_");
 id = element.id.substr(position + 1);
 
 // Variable
var measure = document.getElementById('commodities_inventory_'+id+'_measure').innerHTML;
var unit_mass = document.getElementById('commodities_inventory_'+id+'_unit_mass').innerHTML;
var price = document.getElementById('commodities_inventory_'+id+'_price').innerHTML;
var quantity = document.getElementById('commodities_inventory_'+id+'_quantity').innerHTML;

// Calcul
measure_total = Math.round((parseFloat(quantity) * parseFloat(measure)));
unit_mass_total = Math.round((parseFloat(quantity) * parseFloat(unit_mass)));
price_total = Math.round((measure_total * parseFloat(price)));

// Insert Value
document.getElementById('commodities_inventory_'+id+'_measure_total').innerHTML = measure_total;
document.getElementById('commodities_inventory_'+id+'_unit_mass_total').innerHTML = unit_mass_total;
document.getElementById('commodities_inventory_'+id+'_total').innerHTML = price_total;
}