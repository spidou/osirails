function get_attributes_select(add)
{
  var select = document.getElementById('model_select');
  var models_options = MODELS.get(select.options[select.selectedIndex].value);
  var criterion = "";
  
  if( add == false ) 
  { 
    document.getElementById('criteria_div').innerHTML =''; 
  }
    
  // I use appendChild to perform a clean element add to avoid the reinterpretation of the html code into the current node when using innerHTML
  div = document.createElement('div');
  div.setAttribute('id','criterion_'+ID);
  document.getElementById('criteria_div').appendChild(div);

  criterion = "<select onchange='get_action_select(this);' name='criteria[criterion_"+ ID+"][attribute]'> <option selected='selected' value='blank'>choose an attribute</option>";
  models_options.each(function(pair){
    criterion += "<option value= '"+ pair.value +","+pair.key+"'> "+ pair.key +" </option> " ;
  })
  document.getElementById('criterion_'+ ID).innerHTML += criterion + "</select><span></span></div>";
  
  document.getElementById('add_link').hide();
  select.options[0].disabled=true;
  ID++;
}

function criterion_destroy(elemnt)
{
  var p = elemnt.parentNode.parentNode;
  p.parentNode.removeChild(p);
}

function get_action_select(select)
{
  var type = select.options[select.selectedIndex].value.split(",")[0];
  var actions = new Hash(ACTIONS);
  var data_types = new Hash(DATA_TYPES)
  var criterion = "<select name='criteria["+select.parentNode.id+"][action]'>";
  
  select.options[0].disabled=true;
  for(i=0;i<data_types.get(type).length;i++){
    criterion += "<option value= '"+ data_types.get(type)[i] +"'> "+ actions.get( data_types.get(type)[i] ) +" </option> " ;
  }
  delete_link = "<a href='#' onclick='criterion_destroy(this);'><img src='/images/delete_16x16.png'/></a>";
  select.parentNode.lastChild.innerHTML = criterion + "</select>" + input_type(select) + delete_link;
  document.getElementById('add_link').show();
}

function input_type(select)
{
  var r_value="";
  var today = new Date();
  var date_array = getDateArray([1,31],[1930,today.getFullYear()]);
  switch( select.options[select.selectedIndex].value.split(",")[0] )
  {
    case "string" :
    case "text" :
      r_value = "<input type='text' name='criteria["+select.parentNode.id+"][value]' />";                                             
      break;
    case "boolean" :
      r_value = "<select name='criteria["+select.parentNode.id+"][value]'>" 
              + "<option value='1'>True</option>"
              + "<option value='0'>False</option>"
              + "</select>";                                            
      break;                                                  
    case "integer":
    case "float" :
      r_value = "<input type='text' name='criteria["+select.parentNode.id+"][value]' id='number_input' onkeyup='isNumber(this);' />";
      break;
    case "datetime" :
      r_value = "<select name='criteria["+select.parentNode.id+"][date(3i)]'>" + date_array[3] + "</select> : "
              + "<select name='criteria["+select.parentNode.id+"][date(4i)]'>" + date_array[4] + "</select>";
    case "date" :

      r_value = "<select name='criteria["+select.parentNode.id+"][date(0i)]'>" + date_array[0] + "</select>"
              + "<select name='criteria["+select.parentNode.id+"][date(1i)]'>" + date_array[1] + "</select>" 
              + "<select name='criteria["+select.parentNode.id+"][date(2i)]'>" + date_array[2] + "</select>"
              + r_value ;
      break;
  } 
  return r_value;
}

// method that take arrays has arguments:
//days : contain the first an the last day's month number ex: [1,31]
//months : contains all months of a year ex: [january,february, ... ]
//years :  contins the years range that you whant to be displayed in the select ex : [1990,2008]
// and return an array contaning options of days , months and years with today's date as selected. 
function getDateArray(days,years)
{
  var today = new Date();
  var date_array = ["","","",""];
  var months = ["","January","February","March","April","May","June","July","August","September","October","November","December"];
  var selected = "";
  for(i=days[0];i<=days[1];i++)
  {
    if( today.getDate() == i )
    {
      date_array[0] += "<option selected='selected' value='" + i + "'> " + i + "</option>";
    }
    else
    {
      date_array[0] += "<option value='" + i + "'> " + i + "</option>";
    }
    
  }
  for(i=1;i<=12;i++)
  {
    if( today.getMonth() == (i-1) )
    {
      date_array[1] += "<option selected='selected' value='" +  i + "'>" + months[i] + "</option>";
    }
    else
    {
      date_array[1] += "<option value='" +  i + "'>" + months[i] + "</option>";
    }
  }
  for(i=years[0];i<=years[1];i++)
  {
    if( today.getFullYear() == i )
    {
      date_array[2] += "<option selected='selected' value='" + i + "'>" + i + "</option>";
    }
    else
    {
      date_array[2] += "<option value='" + i + "'>" + i + "</option>";
    }
  }
  for(i=0;i<=23;i++)
  {
    if( today.getHours() == i )
    {
      date_array[3] += "<option selected='selected' value='" + i + "'>" + i + "</option>";
    }
    else
    {
      date_array[3] += "<option value='" + i + "'>" + i + "</option>";
    }
  }
  for(i=0;i<=59;i++)
  {
    if( today.getMinutes() == i )
    {
      date_array[4] += "<option selected='selected' value='" + i + "'>" + i + "</option>";
    }
    else
    {
      date_array[4] += "<option value='" + i + "'>" + i + "</option>";
    }
  }
  return date_array 
}

function isNumber(element)
{
  elemnt = elment.split(" ")
  for(i=0;i<elemnt.length;i++)
  { 
    if (isFinite(elemnt.value) == 0 )
	  {
		  alert ("You should type a number");
		  document.getElementById(elemnt.id).value ="";
	  }
	}
}
