function move_up(link)
{
  move_tr(true, link);
}

function move_down(link)
{
  move_tr(false, link);
}

// Method the parse next or previous siblings until the first visible, and return it
//
function nearly_visible(to_up, element)
{
  do { element = (to_up ? element.previous() : element.next()) }
  while(element != null && !element.visible())
  return element;
}

function move_tr(to_up, link)
{
  var element   = $(link).up("TR");
  var neighbour = $(nearly_visible(to_up, element));
  
  if (neighbour == null) return;
  
  (to_up ? neighbour.insert({before: element}) : neighbour.insert({after: element}) );
  new Effect.Highlight(element, {afterFinish: function(){ element.setStyle({backgroundColor: ''}) }})
  
  update_up_down_links(element.up("tbody"));
}

var move_up_image   = "arrow_up_16x16.png";
var move_down_image = "arrow_down_16x16.png";
var move_up_image_disabled   = "arrow_up_disable_16x16.png";
var move_down_image_disabled = "arrow_down_disable_16x16.png";

function update_up_down_links(element)
{
  elements = element.childElements().reject(function(item) { return parseInt(item.down('.should_destroy').value) == 1 })
  elements = element.childElements().select(function(item) { return item.down('.position') != undefined })
  
  for (var i = 0; i < elements.length; i++) {
    reset_up_down_links(elements[i]);
    update_position(elements[i], i + 1);
  }
  
  if (elements.length > 0) {
    disable_first_link(elements.first());
    disable_last_link(elements.last());
  }
}

function reset_up_down_links(element)
{
  var image = element.down('img');
  
  if (image)
    var image_prefix = image.getAttribute('src').substring(0, image.getAttribute('src').lastIndexOf('/') + 1);
  
  if (element.down(".arrow_up") && image_prefix)
    element.down(".arrow_up").setAttribute('src', image_prefix + move_up_image);
  
  if (element.down(".arrow_down") && image_prefix)
    element.down(".arrow_down").setAttribute('src', image_prefix + move_down_image);
}

function update_position(element, position)
{
  if (element.down(".position"))
    element.down(".position").value = position;
}

// Method to mark the previous link as disabled.
//
function disable_first_link(element)
{
  move_up_img = element.down('.arrow_up');
  if (move_up_img) {
    image_prefix = move_up_img.getAttribute('src').substring(0, move_up_img.getAttribute('src').lastIndexOf('/') + 1);
    move_up_img.setAttribute('src', image_prefix + move_up_image_disabled);
  }
}

// Method to mark the next link as disabled.
//
function disable_last_link(element)
{
  move_down_img = $(element.down('.arrow_down'));
  if (move_down_img) {
    image_prefix  = move_down_img.getAttribute('src').substring(0, move_down_img.getAttribute('src').lastIndexOf('/') + 1);
    move_down_img.setAttribute('src', image_prefix + move_down_image_disabled);
  }
}

function restore_original_value(element, value) {
  if (value.length > 0) {
    input = element.down('.input_' + value)
    original = element.down('.input_original_' + value)
    if (input != null && original != null && original.value.length > 0) {
      input.value = original.value
    }
  }
}

function update_building_quantity_select(element){
    var quantity = element.down('.quantity').innerHTML;
    var building_quantity = element.down('.building_quantity');
    var selected_value = parseInt(element.down('.building_quantity').value)
    var limit = parseInt(quantity) - parseInt(element.down('.built_quantity').value);
    var i;
    var options = ""
    for (i = 0; i <= limit; i++){
        options += "<option value='"+ i +"'>" + i + "</option>";
    }
    building_quantity.innerHTML = options;
    if(selected_value <= limit){
        building_quantity.options[selected_value].selected = true;
    }
    update_available_quantity_select(element);
}

function update_built_quantity_select(element){
    var quantity = element.down('.quantity').innerHTML;
    var built_quantity = element.down('.built_quantity');
    var selected_value = parseInt(element.down('.built_quantity').value)
    var limit = parseInt(quantity) - parseInt(element.down('.building_quantity').value);
    var i;
    var options = ""
    for (i = 0; i <= limit; i++){
        options += "<option value='"+ i +"'>" + i + "</option>";
    }
    built_quantity.innerHTML = options; 
    if(selected_value <= limit){
        built_quantity.options[selected_value].selected = true;
    } 
}

function update_available_quantity_select(element){
    var available_quantity = element.down('.available_to_deliver_quantity');
    var selected_value = parseInt(element.down('.available_to_deliver_quantity').value)
    var limit = parseInt(element.down('.built_quantity').value);
    var i;
    var options = ""
    for (i = 0; i <= limit; i++){
        options += "<option value='"+ i +"'>" + i + "</option>";
    }
    available_quantity.innerHTML = options;
    if(selected_value <= limit){
        available_quantity.options[selected_value].selected = true;
    }
    else{
        new Effect.Highlight(available_quantity.up("td"));
    }
}



