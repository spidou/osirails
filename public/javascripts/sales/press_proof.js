function select_product(select)
{ 
  if (no_actives_childs('droppable_div') || confirm("Êtes-vous sûr de vouloir changer la référence produit ?\nCela aura pour conséquence de vider la liste de maquettes que vous avez sélectionné dans l'onglet 'Maquettes'")) {
    reset_all_draggable(select.options[select.selectedIndex].value, true);
    selected_index = select.selectedIndex
  }
  else{
    select.selectedIndex = selected_index;
  }
}


// Method to determine if a mockup is or not active
//
function is_active(element)
{
  return (element.down('.should_destroy').value == '0' ? true : false);
}


// Method that permit to take in account the fact that the user select a mockup an then cancel his selection
// return true if the div is empty or contain only hidden divs
// return false if contain at least one visible div (that mean that the user has one active choice)
//
function no_actives_childs(div_id)
{
  if ($(div_id).innerHTML.strip() == "") return true;
  
  for(var i=0; i < $(div_id).childElements().length; i++){
    if (is_active($(div_id).childElements()[i])) return false
  }
  return true;
}
// Method to filter mockup by product and to show only those that correspond to the product selected
// selected => product_id permit to retrieve mockup associated to this product
// empty_dropable_div => boolean indiating if 'droppable_div' must or not be empty
//
function reset_all_draggable(selected, empty_droppable_div)
{
  var mockup_class = 'product_' + selected; 
  if(empty_droppable_div){
    $('droppable_div').innerHTML = '';
  }
  var all_draggable = document.getElementsByClassName("draggable minimal_mockup");
  for(var i=0;i<all_draggable.length;i++){
    all_draggable[i].hide();
  }
  
  var draggable = document.getElementsByClassName(mockup_class);
  for(var i=0;i<draggable.length;i++){
    draggable[i].setAttribute('style',"z-index: 1; left: 0px; top: 0px; position: relative;");
  }
}

// Method called to hide saved mockups contained in mockups list 
// collection => mockup_id Array
//
function hide_selected_mockups(collection)
{
  for(var i=0;i<collection.length;i++){
    if($("mockup_"+ collection[i]) != null){
      $("mockup_"+ collection[i]).hide();
    }
  }
}

// Method to show a mockup if the partial was already called
// dropped_element => html ELEMENT (a div) dropped into the droppable DIV
//
function show_selected_mockup(dropped_element)
{
  var selected_mockup = $("selected_"+ $(dropped_element).id)
  if(selected_mockup){                                                                   // the selected_mockup was already rendered
    update_position(selected_mockup, new_element_position());                            // update position before showing the element to not count it as an active
    
    selected_mockup.show();
    selected_mockup.down(".should_destroy").setAttribute('value','0');
    
    selected_mockup.parentNode.insertBefore(selected_mockup, null);                      // to move selected_mokcup at the end of the queue
    
    update_all_action_links();
    return true;
  }
  return false
}

// Method that mark a resource for destroy and hide it while showing the corresponding into the choices list
// element => the element from where the method was called
//
function remove_selected_mockup(element)
{
  var selected_mockup = $(element).parentNode;
  var mockup = selected_mockup.id.gsub("selected_","");
  
  selected_mockup.down(".should_destroy").setAttribute('value','1');
  selected_mockup.down(".position").setAttribute('value','');                            // nullify position of mockups that should be destroyed
  
  $(selected_mockup).fade();
  $(mockup).appear();
  
  update_all_positions();
  update_all_action_links();
}

// The same Method as remove_selected_mockup but used to warn an user
// when removing an out of date mockup from the selected mockups list
//
function remove_selected_mockup_with_warning(element)
{
  var text = "Attention vous allez annuler le choix d\'une ancienne version de la maquette.\n"
            + "Donc la maquette sera mis à jour dans la liste des choix.\n"
            + "Vous devrez modifier la version courante de la maquette,"
            + "pour pouvoir ajouter de nouveau cette version au BAT.";
            
  if(confirm(text)){
    remove_selected_mockup(element);
    
    var modified_id = $(element).parentNode.id.gsub('selected', 'deleted')  
    $(element).parentNode.setAttribute('id', modified_id); //mark element as a deleted out of date mockup; permit not show it aggain in place of the updated mockup
  }
}

//////////////////////////
// Methods to move elements
//////////////////////////

// Method that return that return the last active element's position + 1
//
function new_element_position()
{
  var elements = $('droppable_div').childElements();
  var position = 0;
  for(var i=0;i<elements.length;i++){
    if(is_active(elements[i])) position++;
  }
  return position + 1;
}

// Method to update position
//
function update_position(element, position)
{
  element.down('.position').value         = position;
  element.down('.number_label').innerHTML = position;
}

// Methods to update 'droppable_div' children's positions
// selected = element mean that element will not be updated
//
function update_all_positions(selected)
{
  var elements = $('droppable_div').childElements();
  var position = 0;
  for(var i=0;i<elements.length;i++){
    if(is_active(elements[i])){
      update_position(elements[i],++position);
    }
  }
}


function move_to_right(link)
{
  move_to(true, link);
}

function move_to_left(link)
{
  move_to(false, link);
}

// Method the parse next or previous siblings until the first visible, and return it
//
function nearly_visible(element, to_next)
{
  do { element = (to_next ? element.next() : element.previous()) }
  while(!element.visible())
  return element;
}

// Method to move a selected_mockup before the previous or after the next
// to_next
// - true move after the next
// - false move before the previous
//
function move_to(to_next, link)
{
  var element   = $(link).parentNode;
  var neighbour = $(nearly_visible(element, to_next));

  var element_position   = element.down('.position').value;
  var neighbour_position = neighbour.down('.position').value;
  
  // move the dom element
  (to_next ? neighbour.insert({after: element}) : neighbour.insert({before: element}));
  element.highlight();
  
  // update the positions
  update_position(neighbour, element_position);
  update_position(element, neighbour_position);
  
  // udpate the actions links
  update_all_action_links();
}

//////////////////////////////////
// Methods to update actions links
//////////////////////////////////


// Update all element's action links
// to filter only actives (visibles) elements
//
function update_all_action_links()
{
  var elements = $('droppable_div').childElements();
  var actives  = new Array;
  var index    = 0;
  for (var i=0; i<elements.length; i++) {
    var element = elements[i];
    if(is_active(element)){
      reset_actions_labels(element);
      actives[index++] = element;
    }
  }
  if(actives.length > 0) {
    mark_first_element(actives.first());
    mark_last_element(actives.last());
  }
}


move_to_left_image            = 'move_to_left_16x16.png'
move_to_right_image           = 'move_to_right_16x16.png'
disabled_move_to_left_image   = 'disabled_move_to_left_16x16.png'
disabled_move_to_right_image  = 'disabled_move_to_right_16x16.png'

// Method to reset action links that permit to change position
//
function reset_actions_labels(element)
{
  previous_image = element.down('.previous_link').down('img')
  next_image = element.down('.next_link').down('img')
  
  previous_image_prefix = previous_image.getAttribute('src').substring(0, previous_image.getAttribute('src').lastIndexOf('/') + 1)
  next_image_prefix     = next_image.getAttribute('src').substring(0, next_image.getAttribute('src').lastIndexOf('/') + 1)
  
  previous_image.setAttribute('src', previous_image_prefix + move_to_left_image)
  next_image.setAttribute('src', next_image_prefix + move_to_right_image)
}

// Method to mark the previous link as disabled.
//
function mark_first_element(element)
{
  previous_image        = element.down('.previous_link').down('img')
  previous_image_prefix = previous_image.getAttribute('src').substring(0, previous_image.getAttribute('src').lastIndexOf('/') + 1)
  
  previous_image.setAttribute('src', previous_image_prefix + disabled_move_to_left_image)
}

// Method to mark the next link as disabled.
//
function mark_last_element(element)
{
  next_image        = element.down('.next_link').down('img')
  next_image_prefix = next_image.getAttribute('src').substring(0, next_image.getAttribute('src').lastIndexOf('/') + 1)
  
  next_image.setAttribute('src', next_image_prefix + disabled_move_to_right_image)
}
