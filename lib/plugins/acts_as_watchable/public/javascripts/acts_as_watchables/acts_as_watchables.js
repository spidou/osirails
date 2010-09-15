function disabled_or_enabled_time_unity(element)
{ 

  var id = element.down('.watchable_function_id').value
  var time_unity = "time_unity_".concat(id); 
  var on_schedule = element.down('.on_schedule')
  Effect.toggle(time_unity, 'appear', { duration: 0.0 });
  update_on_schedule(element);
}

function update_on_modification(element)
{
  var on_modification_tmp = element.down('.on_modification_tmp')
  var on_modification = element.down('.on_modification')
   
  if (parseInt(on_modification.value) == 0){
    on_modification_tmp.value = 1
    on_modification.value = 1      
  }
  else{
    on_modification_tmp.value = 0
    on_modification.value = 0 
  }            
}

function update_on_schedule(element)
{
  var on_schedule_tmp = element.down('.on_schedule_tmp')
  var on_schedule = element.down('.on_schedule')
   
  if (parseInt(on_schedule.value) == 0){
    on_schedule_tmp.value = 1
    on_schedule.value = 1      
  }
  else{
    on_schedule_tmp.value = 0
    on_schedule.value = 0 
  }            
}


