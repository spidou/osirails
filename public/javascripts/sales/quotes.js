function add_buttons_in_catalog () {
  var catalog = $('catalog');
  var div_elm = new Element('div')
  div_elm.appendChild( new Element('button', { 'style' : 'float: right', 'onclick' : 'osibox_close(); return false;' }).update("Fermer") )
  div_elm.appendChild( new Element('button', { 'style' : 'float: right', 'onclick' : 'add_reference(); return false;' }).update("Ajouter") )
  div_elm.appendChild( new Element('button', { 'style' : 'float: right', 'onclick' : 'add_reference(); osibox_close(); return false' }).update("Ajouter et fermer") )
  catalog.appendChild(div_elm);
}

function add_reference () {
  var all_ref = $('select_reference').childElements();
  if (all_ref.first().selected) { alert('Veuillez sélectionner une référence'); return false; };
  for (var i = 0; i < all_ref.length; i++) {
	  if (all_ref[i].selected) {
		  new Ajax.Request('/product_references/' + all_ref[i].value + '.json', {
			  method: 'get',
			  onSuccess: function(transport) {
				  var ref_obj = transport.responseText.evalJSON()["product_reference"];
				  append_reference(ref_obj);
			  }
		  });
		  return true;
	  };
  };
  return false;
}
  
function append_reference (json_object) {
  var table = $('list_product').childElements().last()
  
  var new_line = new Element('tr')
  new_line.appendChild( new Element('td').update( json_object['reference'] || json_object['product_reference']['reference'] ) )
  new_line.appendChild( new Element('td').update( new Element('textarea', { 'name' : 'product_references[][description]' }).update((json_object['name'] + "\n" || '') + json_object['description']) ) )
  new_line.appendChild( new Element('td').update( new Element('input', { 'type' : 'text', 'name' : 'product_references[][quantity]', 'class' : 'quantity', 'onkeyup' : 'calculate(this.ancestors()[1])', 'size' : '3', 'value' : '1' }) ) )
  new_line.appendChild( new Element('td').update( new Element('input', { 'type' : 'text', 'name' : 'product_references[][unit_price]', 'class' : 'unit_price', 'onkeyup' : 'calculate(this.ancestors()[1]', 'value' : json_object['production_cost_manpower'] }) ) )
  new_line.appendChild( new Element('td', { 'class' : 'total_price' }) )
  new_line.appendChild( new Element('td', { 'class' : 'total_price_taxes' }) )
  new_line.appendChild( new Element('td').update( new Element('img', { 'src' : '/images/cross_16x16.png', 'alt' : 'Supprimer', 'title' : 'Supprimer', 'onclick' : 'remove_reference(this)' }) ) )
  
  table.appendChild(new_line)
  
  //var last_tr = $('list_product').childElements().last()
  calculate(new_line)
  
  var input_ref = new Element('input', { 'type' : 'hidden', 'name' : 'product_references[][product_reference_id]' })

  if (json_object['unit_price']) {
	  var input = new Element('input', { 'type' : 'hidden', 'value' : json_object['id'], 'name' : 'product_references[][id]' })
	  new_line.appendChild(input);
	  input_ref.setAttribute('value', json_object['product_reference_id']);
  } else {
	  input_ref.setAttribute('value', json_object['id']);
  };
  
  new_line.appendChild(input_ref);
  
  return true;
}

function remove_reference (obj) {
  var div_input = $('input_references');
  var input_id = obj.parentNode.parentNode.nextSibling;
  input_id.setAttribute('name', 'delete_product_reference[]');
  div_input.appendChild(input_id);
  obj.ancestors()[1].remove();
}

function calculate (element) {
  //var row = element.ancestors()[1];
  var quantity = element.select('[class="quantity"]').first()
  var unit_price = element.select('[class="unit_price"]').first()
  var total_price = element.select('[class="total_price"]').first()
  var total_price_taxes = element.select('[class="total_price_taxes"]').first()
  total_price.innerHTML = parseFloat(unit_price.value) * parseInt(quantity.value);
  total_price_taxes.innerHTML = parseFloat(total_price.innerHTML) + parseFloat(total_price.innerHTML) / 100 * taxes_vat;
}
