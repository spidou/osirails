function selectedValue(select) {
  return select.options[select.selectedIndex].value;
}

function refreshCategories(select, max_level) {

 position = select.id.lastIndexOf("_");
 select_id = select.id.substr(position + 1);
 next_select = parseInt(select_id) + 1

id = selectedValue(select);

new Ajax.Request('/product_reference_categories/'+id+'/product_reference_categories',
 {
  method: 'get',
  onSuccess: function(transport){
    response = transport.responseText
    document.getElementById('select_'+next_select).innerHTML = response;
    }
 }
 )
 
 new Ajax.Request('/product_reference_categories/'+id+'/product_references',
 {
  method: 'get',
  onSuccess: function(transport){
  response = transport.responseText
  document.getElementById('select_reference').innerHTML = response;
  }
 }
)

}
