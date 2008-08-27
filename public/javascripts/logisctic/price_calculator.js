// This method permit to calculate commodity price

function price_calculator(element) {
 position = element.id.lastIndexOf("_");
 id = element.id.substr(position + 1);
var fob_unit_price = document.getElementById('commodity_'+id+'_fob_unit_price').innerHTML;
var taxe_coefficient = document.getElementById('commodity_'+id+'_taxe_coefficient').innerHTML;
price = (parseFloat(fob_unit_price) + (parseFloat(fob_unit_price) * parseFloat(taxe_coefficient))/100);
document.getElementById('commodity_'+id+'_price').innerHTML = price;
}