function move_up(link)
{
  move_tr(true, link);
}

function move_down(link)
{
  move_tr(false, link);
}

function move_tr(to_up, link)
{
  var element   = $(link).up("TR");
  var neighbour = (to_up ? element.previous() : element.next());
  
  if (neighbour == null) return;
  
  (to_up ? neighbour.insert({before: element}) : neighbour.insert({after: element}) );
  element.highlight();
  
  update_up_down_links(element.up("tbody").childElements());
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
  for(var i=0; i<elements.length; i++){
    reset_up_down_links(elements[i]);
    update_position(elements[i], i + 1);
  }
  if(elements.length > 0){
    disable_first_link(elements.first());
    disable_last_link(elements.last());
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
