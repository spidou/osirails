function disabled_or_enabled_time_unity(element) {
  var id = element.down('.watchable_function_id').value
  var time_unity = $("time_unity_".concat(id))
  var on_schedule = element.down('.on_schedule')
  time_unity.show()
  update_on_schedule(element)
}

function update_on_modification(element) {
  var on_modification_tmp = element.down('.on_modification_tmp')
  var on_modification = element.down('.on_modification')
  
  if (parseInt(on_modification.value) == 0) {
    on_modification_tmp.value = 1
    on_modification.value = 1      
  } else {
    on_modification_tmp.value = 0
    on_modification.value = 0
  }
}

function update_on_schedule(element) {
  var on_schedule_tmp = element.down('.on_schedule_tmp')
  var on_schedule = element.down('.on_schedule')
  
  if (parseInt(on_schedule.value) == 0) {
    on_schedule_tmp.value = 1
    on_schedule.value = 1
  } else {
    on_schedule_tmp.value = 0
    on_schedule.value = 0
  }
}

function update_all_changes(element) {
  var all_changes_tmp = element.down('.all_changes_tmp')
  var all_changes = element.down('.all_changes')
  
  if (parseInt(all_changes.value) == 0) {
    all_changes_tmp.value = 1
    all_changes.value = 1
  } else {
    all_changes_tmp.value = 0
    all_changes.value = 0
  }
}

function display_popup_box() {
  new Popup("popup_box", null, {modal:true}, {position:'center'})
  $("popup_box").popup.show();   
}

function update_acts_as_watchable_buttons(id) {
  $("popup_box").popup.hide()
  if ($(id))
    $(id).update($("watching_button_holder_for_update").innerHTML)
  
  if ($("watching_button_holder_for_update"))
    $("watching_button_holder_for_update").update('')
}
