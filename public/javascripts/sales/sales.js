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
function nearly_visible(element, to_up)
{
  do { element = (to_up ? element.previous() : element.next()) }
  while(element != null && !element.visible())
  return element;
}

function move_tr(to_up, link)
{
  var element   = $(link).up("TR");
  var neighbour = $(nearly_visible(element, to_up));// (to_up ? element.previous() : element.next());
  
  if (neighbour == null) return;
  
  (to_up ? neighbour.insert({before: element}) : neighbour.insert({after: element}) );
  element.highlight();
  
  update_up_down_links(element.up("tbody").childElements());
}

// Method to determine if a mockup is or not active
//
function is_active(element)
{
  var value = element.down('.should_destroy').value
  return ( value == '0' || value == ''? true : false);
}

var move_up_image   = "arrow_up_16x16.png";
var move_down_image = "arrow_down_16x16.png";
var move_up_image_disabled   = "arrow_up_disable_16x16.png";
var move_down_image_disabled = "arrow_down_disable_16x16.png";

function reset_up_down_links(element)
{
  var image        = element.down('img');
  var image_prefix = image.getAttribute('src').substring(0, image.getAttribute('src').lastIndexOf('/') + 1);
  element.down(".arrow_up").setAttribute('src', image_prefix + move_up_image);
  element.down(".arrow_down").setAttribute('src', image_prefix + move_down_image);
}

function update_up_down_links(elements)
{
  var actives  = new Array;
  var index    = 0;
  for(var i=0; i<elements.length; i++){
    if(is_active(elements[i])){
      var element = elements[i];
      reset_up_down_links(element);
      update_position(element, index + 1);
      actives[index++] = element;
    }
  }
  if(actives.length > 0) {
    disable_first_link(actives.first());
    disable_last_link(actives.last());
  }
}

function update_position(element, position)
{
  element.down(".position").value = position;
}

// Method to mark the previous link as disabled.
//
function disable_first_link(element)
{
  move_up_img  = element.down('.arrow_up');
  image_prefix = move_up_img.getAttribute('src').substring(0, move_up_img.getAttribute('src').lastIndexOf('/') + 1);
  
  move_up_img.setAttribute('src', image_prefix + move_up_image_disabled);
}

// Method to mark the next link as disabled.
//
function disable_last_link(element)
{
  move_down_img = $(element.down('.arrow_down'));
  image_prefix  = move_down_img.getAttribute('src').substring(0, move_down_img.getAttribute('src').lastIndexOf('/') + 1);
  
  move_down_img.setAttribute('src', image_prefix + move_down_image_disabled);
}
