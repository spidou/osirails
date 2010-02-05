function check_type(select)
{
  var selected = select.options[select.selectedIndex].value;
  var options  = $('tool_event_status').options;
  
  for (var i = 0; i < options.length; i++){
    var option = options[i];
    
    // selected = 1 mean the Type is 'intervention'
    // opt.value = 2 mean the Status is 'scrapped'
    if (selected == '1' && option.value == '2'){
      option.disabled = true;
      disable_date_select('tool_event_end_date', false);
      $('alarms_for_intervention').show();
    }
    else{
      option.disabled = false;
      disable_date_select('tool_event_end_date', true);
      $('alarms_for_intervention').hide();
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

function check_delay_type(select)
{
  var selected = select.options[select.selectedIndex].value;
  
  if (selected == '0') { // '0' mean 'Une date' is selected
    $(select).up('.alarm').down('.duration').hide();
    $(select).up('.alarm').down('.date').show();
  }
  else {
    $(select).up('.alarm').down('.duration').show();
    $(select).up('.alarm').down('.date').hide();
  }
}

function check_duration_unit()
{
  var select = $('alarm__do_alarm_before')
  var new_value = parseFloat(select.value) / 60;
  select.value = new_value.toString();
}

function mark_resource_for_destroy(id)
{
  $(id).up('.resource').down('.should_destroy').value = 1;
  $(id).up('.resource').fade();
}
