function select_product(select)
{
  if (confirm("Voulez-vous changer la référence produit,\ncela aura pour conséquence d'annuler\nvotre sélection de maquettes?")) { // Click sur OK
    var selected = select.options[select.selectedIndex].value;
    reset_all_draggable(selected, true);
  }
}

// function to filter mockup by product and to show only those that correspond to the product selected
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

// method called to hide mockups that come from database into choices list 
// collection => mockup_id Array
//
function hide_selected_mockups(collection)
{
  for(var i=0;i<collection.length;i++){
    $("mockup_"+ collection[i]).hide();
  }
}

// method to show a mockup if the partial was already called
// dropped_element => html ELEMENT (a div) dropped into the droppable DIV
//
function show_selected_mockup(dropped_element)
{
  var selected_mockup = $("selected_"+ $(dropped_element).id)
  if(selected_mockup){                                                                      //the selected_mockup was already rendered
    selected_mockup.show();
    selected_mockup.down(".should_destroy").setAttribute('value','0');
    return true;
  }
  return false
}

// function that mark a resource for destroy and hide it while showing the corresponding into the choices list
// element => the element from where the method was called
//
function remove_selected_mockup(element)
{
  var selected_mockup = $(element).parentNode;
  var mockup = selected_mockup.id.gsub("selected_","");
  
  selected_mockup.down(".should_destroy").setAttribute('value','1');
  
  $(selected_mockup).hide();  
  
  $(mockup).setAttribute('style', "z-index: 1; left: 0px; top: 0px; position: relative;");
}

// The same function as remove_selected_mockup but used to warn an user
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
