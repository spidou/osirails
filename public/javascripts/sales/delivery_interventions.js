function toggle_internal_and_subcontractor(element) {
  element_to_show = element.id + '_div'
  
  if (element.id.match(/internal/)) {
    element_to_hide = element_to_show.replace('internal', 'subcontracting')
  } else {
    element_to_hide = element_to_show.replace('subcontracting', 'internal')
  }
  
  new Effect.Fade(element_to_hide)
  new Effect.Appear(element_to_show)
  
  //new Effect.SlideUp(element_to_hide, {afterFinish: function(){ new Effect.SlideDown(element_to_show) }})
  //new Effect.BlindUp(element_to_hide, {afterFinish: function(){ new Effect.BlindDown(element_to_show) }})
  
  clear_all_data_inputs_in(element_to_hide)
}

function toggle_delivered_or_not(element) {
  element_to_show = element.id + '_div'
  
  if (element.id.match(/true/)) {
    element_to_hide = element_to_show.replace('true', 'false')
  } else {
    element_to_hide = element_to_show.replace('false', 'true')
  }
  
  new Effect.Fade(element_to_hide)
  new Effect.Appear(element_to_show)
  
  clear_all_data_inputs_in(element_to_hide)
}

function clear_all_data_inputs_in(element) {
  $(element).select('select').each(function(select){
    select.select('option').each(function(option){
      option.selected = 0
    });
  });
  
  $(element).select('textarea').each(function(textarea){
    textarea.clear()
  })
  
  $(element).select('input').each(function(input){
    input.clear()
  })
}

function toggle_disable_comments_for_discard(element) {
  input = element.up('tr').down('.comments')
  if (element.value == "0") {
    input.clear()
    input.disable()
  } else {
    input.enable()
    input.focus()
  }
}
