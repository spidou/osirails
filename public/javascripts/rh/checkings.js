function disable_fields(select)
{
  alert(select.options[select.selectedIndex].value);
  var tab = new Array;
  var all_attributes = ["checking_afternoon_delay_hours", "checking_afternoon_delay_minutes", "checking_afternoon_overtime_hours", "checking_afternoon_overtime_minutes",
             "checking_afternoon_delay_comment", "checking_afternoon_overtime_comment","checking_morning_delay_hours", "checking_morning_delay_minutes",
             "checking_morning_overtime_hours", "checking_morning_overtime_minutes", "checking_morning_delay_comment", "checking_morning_overtime_comment"];
  switch (select.options[select.selectedIndex].value){
    case "1" :
      tab = ["checking_morning_delay_hours", "checking_morning_delay_minutes", "checking_morning_overtime_hours", "checking_morning_overtime_minutes",
             "checking_morning_delay_comment", "checking_morning_overtime_comment"];
      break;
    case "2" :
      tab = ["checking_afternoon_delay_hours", "checking_afternoon_delay_minutes", "checking_afternoon_overtime_hours", "checking_afternoon_overtime_minutes",
             "checking_afternoon_delay_comment", "checking_afternoon_overtime_comment"];
      break;
    case "3" :
      tab = all_attributes
      break ;
  }
  
  // default all are enabled
  for(var i=0; i<all_attributes.length; i++){
    $(all_attributes[i]).disabled='';
  }
  
  // disbled the good fields
  for(var i=0; i<tab.length; i++){
    $(tab[i]).disabled='disabled';
  }
}
