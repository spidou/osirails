// # TODO remove that file

// Method to get the attribute html link between <li></li>
//
function get_attribute_link(parent_div_id, pair)
{
  return "<li onmouseover='show_menu(this);'><a href='#"+ parent_div_id +"_attribute_chooser' onclick=\"save_path(this, '"+ parent_div_id +"','"+ pair.value +"');\">"+ pair.key +"</a></li>";
}

// Recursive method to get the attribute chooser structure according to sub models hierarchy
// relationships -> hash of relationships from which the method will parse deeply the relationships hiearachy
// current_relationship -> permit to go deeply into the relationships hierarhy, looping onto a simple hash (the hash refer to it self)
//
function get_models_hierarchy(relationships, parent_div_id, current_relationship) 
{
  var result = ""

  for(var i = 0; i < relationships.get(current_relationship).length; i++){
    var attributes = MODELS.get(relationships.get(current_relationship)[i][1]).get('attributes');
    var relationship = relationships.get(current_relationship)[i][0];
    result += "<li class='sub_menu' onmouseover='show_menu(this);'><ul class='hidden_menu'>"; 
    
    attributes.each(function(pair){
      result += get_attribute_link(parent_div_id, pair);
    })
    
    if(relationships.keys().indexOf(relationship)!=-1){
      result += get_models_hierarchy(relationships, parent_div_id, relationship);
    }
    result += "</ul><a href='#"+ parent_div_id +"_attribute_chooser' >"+ relationship.split(".")[1] +"</a></li>";
  }

  
  return result;
}

// method to generate the attribute chooser
// add -> boolean value :
//  true = call from the add attribute link, the new attribute chooser must be add to the currents attrbutes.
//  false = call from the model select (search into a new model). that mean we need to clear up the attributes area to add a new one.
//
function get_attributes_select(add)
{
  var select = $('model_select');
  var model = select.options[select.selectedIndex].value;
  var model_attributes = MODELS.get(model).get('attributes');
  var model_relationships = MODELS.get(model).get('relationships');
  var criterion = "";
  var tab = new Array;
  
  if( add == false ) { 
    $('criteria_div').innerHTML ='';
    $('submit_tag').disabled = false;
  }
    
  // I use appendChild to perform a clean element add to avoid the reinterpretation of the html code into the current node when using innerHTML
  var parent_div = document.createElement('div');
  parent_div.setAttribute('id','criterion_'+ ID);
  $('criteria_div').appendChild(parent_div);
  
  // ###############  attribute chooser ###################
  
  criterion  = "<label onclick=\"this.next('UL').down('UL').className='visible_menu'; startObserveToHideOnClick(this.next('UL').down('UL'))\" id='criterion_"+ ID +"_label' class='criterion_label test'>Veuillez choisir un critère</label>"
  criterion += "<span class='criterion' id=\"criterion_"+ID+"_action\" >&nbsp;</span>"
  criterion += "<ul name='criterion_"+ ID +"_attribute_chooser' class='attr_chooser'>"
  criterion += "<li id='clicked' ><ul>"
  
  //direct attributes
  model_attributes.each(function(pair){
    criterion += get_attribute_link(parent_div.id, pair);
  })
  
  //attributes comming from sub models
  if( model_relationships.keys().length > 0){
    criterion += get_models_hierarchy(model_relationships, parent_div.id, model);
  }
  
  criterion += "</ul></li></ul>";
  // #######################################################
  
  criterion += "<br/></div>";// use 3 dot to avoid the floating content to go with non floating content
  parent_div.innerHTML += criterion ; // add the criterion to the parent div
  
//  $('clicked').observe('click', function(window_event) {    //same as onclick clause
//    $('clicked').className = 'clicked';
//  });

  select.options[0].disabled = true;
  ID++;
}

// method called by the delete link it destroy the parent div of a criterion
// element -> represent the delete link
//
function criterion_destroy(element)
{
  var id = element.id.substring(element.id.indexOf("_") + 1);
  element.up('#' + id).remove();
}

// method to check the attribute data type and to give the good action select
// type -> attribute data type
//
function get_action_select(type, parent_div_id)
{
  var actions = new Hash(ACTIONS);
  var data_types = new Hash(DATA_TYPES);  
  var delete_img = "<img alt='Supprimer ce critère' title='Supprimer ce critère' src='/images/delete_16x16.png'/>"
  var delete_link = " <a href='#"+ parent_div_id +"_attribute_chooser' onclick='criterion_destroy(this);' id='delete_"+parent_div_id+"'>"+ delete_img +"</a>";
  
  var criterion = "<select name='criteria["+ parent_div_id +"][action]'>";
  for(var i=0;i<data_types.get(type).length;i++){
    criterion += "<option value= '"+ type +","+ data_types.get(type)[i] +"'>"+ actions.get( data_types.get(type)[i] ) +"</option>" ;
  }
  criterion += "</select>";
  $(parent_div_id+"_action").innerHTML += criterion + input_type(type, parent_div_id) + delete_link;
}

// Add here all new data types not defined yet
function input_type(type, parent_div_id)
{
  var result="";
  var today = new Date();
  var date_array = getDateArray([1,31],[1930,today.getFullYear()]);
  switch(type)
  {
    case "string" :
    case "binary" :
    case "text" :
      result = "<input type='text' name='criteria["+ parent_div_id +"][value]' />";                                             
      break;
    case "boolean" :
      result = "<select name='criteria["+ parent_div_id +"][value]'>" 
             + "<option value='1'>True</option>"
             + "<option value='0'>False</option>"
             + "</select>";                                            
      break;                                                  
    case "integer":
    case "decimal":
    case "float" :
      result = "<input type='text' name='criteria["+ parent_div_id +"][value]' id='number_input' onkeyup='isNumber(this);' />";
      break;
    case "datetime" :
      result = "<select name='criteria["+ parent_div_id +"][date(3i)]'>"+ date_array[3] +"</select> : "
             + "<select name='criteria["+ parent_div_id +"][date(4i)]'>"+ date_array[4] +"</select>";
    case "date" :

      result = "<select name='criteria["+ parent_div_id +"][date(0i)]'>"+ date_array[0] +"</select>"
             + "<select name='criteria["+ parent_div_id +"][date(1i)]'>"+ date_array[1] +"</select>" 
             + "<select name='criteria["+ parent_div_id +"][date(2i)]'>"+ date_array[2] +"</select>"
             + result ;
      break;
  } 
  return result;
}

// method that take arrays has arguments:
//days : contain the first an the last day's month number ex: [1,31]
//months : contains all months of a year ex: [january,february, ... ]
//years :  contains the years range that you whant to be displayed in the select ex : [1990,2008]
// and return an array contaning options of days , months and years with today's date as selected.
//
function getDateArray(days,years)
{
  var today = new Date();
  var date_array = ["","","","",""];
  var months = ["","January","February","March","April","May","June","July","August","September","October","November","December"];
  var selected = "";
  for(var day = days[0]; day <= days[1]; day++){
    if( today.getDate() == day ){
      date_array[0] += "<option selected='selected' value='"+ day +"'> "+ day +"</option>";
    }
    else{
      date_array[0] += "<option value='"+ day +"'> "+ day +"</option>";
    }
    
  }
  for(var month = 1; month <= 12; month++){
    if( today.getMonth() == (month-1) ){
      date_array[1] += "<option selected='selected' value='"+  month +"'>"+ months[month] +"</option>";
    }
    else{
      date_array[1] += "<option value='"+  month +"'>" + months[month] + "</option>";
    }
  }
  for(var year = years[0]; year <= years[1]; year++){
    if( today.getFullYear() == year ){
      date_array[2] += "<option selected='selected' value='"+ year +"'>"+ year +"</option>";
    }
    else{
      date_array[2] += "<option value='"+ year +"'>"+ year +"</option>";
    }
  }
  for(var hour = 0; hour <= 23; hour++){
    if( today.getHours() == hour ){
      date_array[3] += "<option selected='selected' value='"+ hour +"'>"+ hour +"</option>";
    }
    else{
      date_array[3] += "<option value='"+ hour +"'>"+ hour +"</option>";
    }
  }
  for(var minute = 0; minute <= 59; minute++){
    if( today.getMinutes() == minute ){
      date_array[4] += "<option selected='selected' value='"+ minute +"'>"+ minute +"</option>";
    }
    else{
      date_array[4] += "<option value='"+ minute +"'>"+ minute +"</option>";
    }
  }
  return date_array;
}

function isNumber(element)
{
  value = element.value.split(" ");
  for (var i = 0; i < value.length; i++){ 
    if (isFinite(value[i]) == 0 && value[i] != ""){
		  alert ("Vous devez entrer un nombre");
		  $(element.id).value ="";
	  }
	}
}

//-------------------------------------------- dynamique attribute chooser methods------------------------------ 
function show_menu(obj)
{
  $(obj).siblings('LI').each(function(li){ hide_menu(li) })
  if($(obj).down('UL') != null)
    $(obj).down('UL').className = "visible_menu";
}

function hide_menu(obj)
{
  if($(obj).down('UL') != null)
    $(obj).down('UL').className = "hidden_menu"
    hideMenuWithChildren($(obj).down('UL'))
}

function hideMenuWithChildren(obj)
{
  while(obj != null){
    obj.className = "hidden_menu"
    obj = obj.down('.visible_menu')
  }
}

function startObserveToHideOnClick(ul)
{
  var event = null;
  
  Event.observe(window, 'mouseup', function(window_event) {
    event = window_event
    hideMenuWithChildren($(ul))
  });
  
  Event.observe(ul, 'mouseup', function(window_event) {
    if(event == null) return
  });
}

// method to permit to apply the attribute choice of the user 
// obj -> calling html entitie
// parent_div_id  -> the id of the parent div of the whole criterion
// attribute_type -> the data type of the attribute (boolean, string, etc...)
//
function save_path(obj, parent_div_id, attribute_type)
{
  var current = obj;
  var tab = new Array;
  
  // unselect the old path
  var element = obj.up('.attr_chooser').down('.selected')
  if(element != null){
    while(element != null) {
      element.removeClassName('selected')
      element = element.down('.selected')
    }
  }
  
  // add a new criterion
  if($(parent_div_id +'_attribute') == null) {
    get_attributes_select(true);
  }
  
  // select the new path
  while(!(current.tagName=='UL' && current.className=='attr_chooser' )){
    current = current.parentNode;
    if(current.tagName=='LI'){                                                         //verify that we are testing <li> balises
      current.addClassName('selected')
      for(var j=0;j<current.childNodes.length;j++){                                   //test all <a> that are children of current <li>
        item = current.childNodes.item(j);
        if(item.parentNode == current && item.tagName=="A"){                //get the good <a> balise that represent a sub model        
          tab.push(item.innerHTML);
        }
      }
    }
  }
    
  tab = tab.reverse();     // put in the good order because the path is parsed from the destination (attribute) to the source (parent)
  $(parent_div_id +'_label').innerHTML = "<div class='attribute_part'>" + tab.join("</div><div class='attribute_part'>") + "</div>";
  hidden_field = "<input type='hidden' id='"+ parent_div_id +"_attribute' value='"+ tab.join(".").gsub(" ","_") +"' name='criteria["+ parent_div_id +"][attribute]'/>";
  $(parent_div_id +'_action').innerHTML = hidden_field;
  
  get_action_select(attribute_type, parent_div_id);
}

//----------------------------------------------------------------------------------------------------------------------------------------
