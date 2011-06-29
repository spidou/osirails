function update_building_quantity_select(element) {
  var built_quantity = parseInt(element.value)
  var parent = element.up('tr')
  
  var quantity = parseInt(parent.down('.end_product_quantity').innerHTML)
  var building_quantity_select = parent.down('.building_quantity select')
  var building_quantity = parseInt(building_quantity_select.value)
  
  var limit = quantity - built_quantity
  
  var options = ""
  for (var i = 0; i <= limit; i++) {
    options += "<option value='"+ i +"'>" + i + "</option>";
  }
  
  building_quantity_select.innerHTML = options
  
  if (building_quantity <= limit) {
    building_quantity_select.options[building_quantity].selected = true
  }
  
  update_available_to_deliver_quantity_select(element)
  update_progression(element)
}

function update_built_quantity_select(element) {
  var building_quantity = parseInt(element.value)
  var parent = element.up('tr')
  
  var quantity = parseInt(parent.down('.end_product_quantity').innerHTML)
  var built_quantity_select = parent.down('.built_quantity select')
  var built_quantity = parseInt(built_quantity_select.value)
  
  var limit = quantity - building_quantity
  
  var options = ""
  for (var i = 0; i <= limit; i++) {
    options += "<option value='"+ i +"'>" + i + "</option>"
  }
  
  built_quantity_select.innerHTML = options;
  
  if (built_quantity <= limit) {
    built_quantity_select.options[built_quantity].selected = true
  }
}

function update_available_to_deliver_quantity_select(element) {
  var built_quantity = parseInt(element.value)
  var parent = element.up('tr')
  
  var available_to_delivey_quantity_select = parent.down('.available_to_deliver_quantity select')
  var available_to_delivey_quantity = parseInt(available_to_delivey_quantity_select.value)
  
  var options = ""
  for (var i = 0; i <= built_quantity; i++) {
    options += "<option value='"+ i +"'>" + i + "</option>"
  }
  
  available_to_delivey_quantity_select.innerHTML = options
  
  if (available_to_delivey_quantity <= built_quantity) {
    available_to_delivey_quantity_select.options[available_to_delivey_quantity].selected = true
  } else {
    new Effect.Highlight(available_to_delivey_quantity_select.up("td"))
  }
}

function update_progression(element) {
  var built_quantity = parseInt(element.value)
  var parent = element.up('tr')
  
  var quantity = parseInt(parent.down('.end_product_quantity').innerHTML)
  var progression_select = parent.down('.progression select')
  
  if (built_quantity == quantity) {
    progression_select.options[progression_select.options.length-1].selected = true
    new Effect.Highlight(progression_select.up('td'))
  } else if (built_quantity == 0) {
    progression_select.options[0].selected = true
    new Effect.Highlight(progression_select.up('td'))
  }
}

function update_built_quantity(element) {
  var progression = parseInt(element.value)
  var parent = element.up('tr')
  
  var built_quantity_select = parent.down('.built_quantity select')
  
  if (progression == 100) {
    reset_building_quantity_select(parent)
    
    built_quantity_select.options[built_quantity_select.options.length-1].selected = true
    new Effect.Highlight(built_quantity_select.up('td'))
  } else if (progression == 0) {
    built_quantity_select.options[0].selected = true
    new Effect.Highlight(built_quantity_select.up('td'))
  }
  
  if (progression == 100 || progression == 0) {
    update_building_quantity_select(built_quantity_select)
    update_available_to_deliver_quantity_select(built_quantity_select)
  }
}

function reset_building_quantity_select(parent) {
  var building_quantity_select = parent.down('.building_quantity select')
  
  building_quantity_select.options[0].selected = true
  new Effect.Highlight(building_quantity_select.up('td'))
  
  update_built_quantity_select(building_quantity_select)
}
