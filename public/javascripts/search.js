function action_choose(select,line,month)
{ 
  document.getElementById("blank" + line).disabled=true;
  document.getElementById('add_link').style.display='inline';
  document.getElementById('delete_link'+line).style.display='inline';
  document.getElementById('attribute_name' + line).innerHTML ="of " + select.options[select.selectedIndex].parentNode.label;
  document.getElementById('parent_name' + line).value = select.options[select.selectedIndex].parentNode.label;
  switch( select.options[select.selectedIndex].value.split(",")[1] )
  {
    case "date" :
      document.getElementById('actions' + line).innerHTML = ""
      document.getElementById('actions' + line).innerHTML = "<select name=\"criteria["+ line+ "][action]\">" +
                                                              "<option value=\"=\"> le </option>"+
                                                              "<option value=\"!=\"> diff&eacute;rrent du </option>"+
                                                              "<option value=\">\"> aprés le </option>"+
                                                              "<option value=\"<\"> avant le </option>"+
                                                              "<option value=\"<=\"> avant et inclus le </option>"+
                                                              "<option value=\">=\"> apr&egrave;s et inclus le </option>"+
                                                            "</select>";
      inputType(select,line,month);
      break;                                                
    case "number" :
      document.getElementById('actions' + line).innerHTML = ""
      document.getElementById('actions' + line).innerHTML = "<select name=\"criteria[" + line + "][action]\">" +
                                                              "<option value=\"=\"> egal &agrave</option>"+
                                                              "<option value=\"!=\"> diff&eacute;rrent de </option>"+
                                                              "<option value=\">\"> plus grand que</option>"+
                                                              "<option value=\"<\"> plus petit que</option>"+
                                                              "<option value=\"<=\"> plus petit &agrave; &eacute;gal &agrave;</option>"+
                                                              "<option value=\">=\"> plus grand &agrave; &eacute;gal &agrave;</option>"+
                                                            "</select>";
      inputType(select,line,month);
      break;
    case "string" :
      document.getElementById('actions' + line).innerHTML = ""
      document.getElementById('actions' + line).innerHTML = "<select name=\"criteria[" + line + "][action]\">" +
                                                              "<option value=\"like\"> contient</option>"+
                                                              "<option value=\"not like\">ne contient pas</option>"+
                                                              "<option value=\"=\"> est</option>"+
                                                              "<option value=\"!=\"> n&apos;est pas</option>"+
                                                            "</select>";                                                  
      inputType(select,line,month);
      break;
  } 
}

function inputType(select,line,month)
{
  switch( select.options[select.selectedIndex].value.split(",")[1] )
  {
    case "string" :
      document.getElementById('input_type' + line).innerHTML = "<input type=\"text\" name=\"criteria[" + line + "][value]\" />";                                             
      break;                                                
    case "number" :
      document.getElementById('input_type' + line).innerHTML = "<input type=\"text\" name=\"criteria[" + line + "][value]\" id=\"number_input\" onkeyup=\"isNumber(this);\" />";
      break;
    case "date" :
      today = new Date();
      date_array = getDateArray([1,31],month,[1930,today.getFullYear()]);
      document.getElementById('input_type' + line).innerHTML = "<select name=\"criteria[" + line + "][date(3i)]\">" +
                                                                date_array[0] +
                                                               "</select>"+" "+
                                                               "<select name=\"criteria[" + line + "][date(2i)]\">" +
                                                                date_array[1] +
                                                               "</select>"+" "+ 
                                                               "<select name=\"criteria[" + line + "][date(1i)]\">" +
                                                                date_array[2]
                                                               "</select>";                                                                                                                                               
      break;
  } 
}

// method that take arrays has arguments:
//days : contain the first an the last day's month number ex: [1,31]
//months : contains all months of a year ex: [january,february, ... ]
//years :  contins the years range that you whant to be displayed in the select ex : [1990,2008]
// and return an array contaning options of days , months and years with today's date as selected. 
function getDateArray(days,months,years)
{
  today = new Date();
  date_array = ["","",""];
  selected = "";
  for(i=days[0];i<=days[1];i++)
  {
    if( today.getDate() == i )
    {
      date_array[0] += "<option selected=\"selected\" value=\"" + i + "\"> " + i + "</option>";
    }
    else
    {
      date_array[0] += "<option value=\"" + i + "\"> " + i + "</option>";
    }
    
  }
  for(i=1;i<=12;i++)
  {
    if( today.getMonth() == (i-1) )
    {
      date_array[1] += "<option selected=\"selected\" value=\"" +  i + "\">" + months[i] + "</option>";
    }
    else
    {
      date_array[1] += "<option value=\"" +  i + "\">" + months[i] + "</option>";
    }
  }
  for(i=years[0];i<=years[1];i++)
  {
    if( today.getFullYear() == i )
    {
      date_array[2] += "<option selected=\"selected\" value=\"" + i + "\"> " + i + "</option>";
    }
    else
    {
      date_array[2] += "<option value=\"" + i + "\"> " + i + "</option>";
    }
  }
  return date_array 
}

function isNumber(elemnt)
{
  if (isFinite(elemnt.value) == 0 )
	{
		alert ("vous devez entrer des chiffres");
		document.getElementById(elemnt.id).value ="";

	}
}

function has_criteria(select)
{
  disable_blank(select)
  if(document.getElementById('criteria_list').childNodes.length>4)
  {
    alert( "Etes vous sur de vouloir changer de section de recherche? \nCeci aura pour conséquence de réinitiliser les critères");
  }
}

function disable_blank(select)
{
  select.options[0].disabled = true; 
}
      
