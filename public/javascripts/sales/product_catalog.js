function update_product_reference_sub_categories(select) {
  ids = $F(select).toString()
  target_element = $('select_product_reference_sub_categories')
  
  if (ids != "0")
    params = 'product_reference_category_id=' + ids
  else
    params = ''
  
  new Ajax.Request("/product_reference_sub_categories",
    {
      method: 'get',
      parameters: params,
      onSuccess: function(transport){
        response = transport.responseText
        
        target_element.update(response)
        update_product_references(target_element)
      }
    }
  )
}

function update_product_references(select) {
  ids = $F(select).toString()
  target_element = $('select_product_references')
  
  if (ids != "0") {
    params = 'product_reference_sub_category_id=' + ids
  } else {
    ids = $F('select_product_reference_categories')
    if (ids != "0")
      params = 'product_reference_category_id=' + ids
    else
      params = ''
  }
  
  new Ajax.Request("/product_references",
    {
      method: 'get',
      parameters: params,
      onSuccess: function(transport){
        response = transport.responseText
        
        target_element.update(response)
        update_end_products(target_element)
      }
    }
  )
}

function update_end_products(select) {
  ids = $F(select).toString()
  target_element = $('end_products_list')
  
  if (ids != "0") {
    params = 'product_reference_id=' + ids
  } else {
    ids = $F('select_product_reference_sub_categories')
    if (ids != "0") {
      params = 'product_reference_sub_category_id=' + ids
    } else {
      ids = $F('select_product_reference_categories')
      if (ids != "0")
        params = 'product_reference_category_id=' + ids
      else
        params = ''
    }
  }
  
  new Ajax.Request("/end_products",
    {
      method: 'get',
      parameters: params,
      onSuccess: function(transport){
        response = transport.responseText
        
        target_element.update(response)
      }
    }
  )
}

///* This method permit to return selected option value for a select */
//function selectedValue(select) {
//  return select.options[select.selectedIndex].value;
//}
//
///* This method permit to refresh reference information and this dependence */
//function refreshReferenceInformation(select) {
//  id = selectedValue(select);
//  
//  if (id != 0) {
//    new Ajax.Request('/product_references/'+id,
//      {
//        method: 'get',
//        onSuccess: function(transport){
//          response = transport.responseText
//          
//          document.getElementById('product_informations').style.display = 'none';
//          document.getElementById('product_reference_informations').style.display = 'block';
//          document.getElementById('product_reference_informations').innerHTML = response;
//          refreshProductsList(select, id, 1);
//        }
//      }
//    )
//  }
//  else if (id == 0){
//    select_list = ""
//    refreshProductsList(select, id, 1);
//    document.getElementById('product_informations').style.display = 'none';
//    document.getElementById('product_reference_informations').style.display = 'none';
//  }
//  else {
//    document.getElementById('end_products_list').style.display = 'none';
//    document.getElementById('product_informations').style.display = 'none';
//    document.getElementById('product_reference_informations').style.display = 'none';
//  }
//}
//
///* This method permit to refresh product information */
//function refreshProduct(element){
//  position = element.id.lastIndexOf("_");
//  id = element.id.substr(position + 1);
//  
//  document.getElementById('product_informations').style.display = 'block';
//  
//  new Ajax.Request('/end_products/'+id,
//    {
//      method: 'get',
//      onSuccess: function(transport){
//        response = transport.responseText
//        document.getElementById('product_informations').innerHTML = response;
//      }
//    }
//  )
//}
