function check_type(select)
{
  var selected = select.options[select.selectedIndex].value;
  var options  = $('tool_event_status').options;
  
  for (var i = 0; i < options.length; i++){
    var opt = options[i];
    
    // selected = 1 mean the Type is 'intervention'
    // opt.value = 2 mean the Status is 'scrapped'
    if (selected == '1' && opt.value == '2'){
      opt.disabled = true;
      disable_date_select('tool_event_end_date', false);
    }
    else{
      opt.disabled = false;
      disable_date_select('tool_event_end_date', true);
    }
  }
}

function disable_date_select(id, disabled)
{
  var date = new Array($(id +'_1i'), $(id +'_2i'), $(id +'_3i'));

  for (var i = 0; i < date.length; i++){
    date[i].disabled = disabled;
  }
}
