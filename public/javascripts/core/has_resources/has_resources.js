/////////////////
// resources
function mark_resource_for_destroy(element) {
  resource = element.up('.resource')
  resource.down('.should_destroy').value = "1";
  Effect.toggle(resource, 'appear')
  
  if (resource.up('.resource_group')) {
    hide_resource_group(resource.up('.resource_group'))
  }
}

function mark_many_resources_for_destroy(div) {
  resources = div.select('.resource')
  
  resources.each(function(sub_resource){
    mark_resource_for_destroy(sub_resource.down('.should_destroy'))
  })
}

function destroy_resource_and_sub_resources(element, sub_elements_div, text){
  if (confirm(text)){
    mark_resource_for_destroy(element);
    mark_many_resources_for_destroy(sub_elements_div);
    sub_elements_div.toggle('appear');
  }
}

function mark_resource_for_hide(element) {
  resource = element.up('.resource')
  resource.down('.should_hide').value = 1
  Effect.toggle(resource, 'appear')
  
  if (resource.up('.resource_group')) {
    hide_resource_group(resource.up('.resource_group'))
  }
}

function mark_many_resources_for_hide(div) {
  resources = div.select('.resource')
  
  resources.each(function(sub_resource){
    mark_resource_for_hide(sub_resource.down('.should_hide'))
  })
}

function hide_resource_and_sub_resources(element, sub_elements_div, text){
  if (confirm(text)){
    mark_resource_for_hide(element);
    mark_many_resources_for_hide(sub_elements_div);
    sub_elements_div.toggle('appear');
  }
}

function mark_resource_for_update(element, options) {
  resource = element.up('.resource')
  resource.down('.should_update').value = 1
  
  resource_form = resource.down('.resource_form')
  if (!resource_form.visible()) {
    Effect.toggle(resource_form, 'slide', options)
  }
}

function mark_resource_for_dont_update(element) {
  resource = element.up('.resource')
  resource.down('.should_update').value = ''
  
  resource_form = resource.down('.resource_form')
  if (resource_form.visible()) {
    Effect.toggle(resource_form, 'slide')
  }
}

function cancel_creation_of_new_resource(element) {
  resource = element.up('.resource')
  resource_group = element.up('.resource_group')
  
  Effect.Fade(resource, { duration: 0.7, afterFinish: function(){
    resource.remove()
    if (resource_group) { hide_resource_group(resource_group) }
  }})
}

function hide_resource_group(element_group) {
  group_children = element_group.select('.resource')
  count = 0
  for (i = 0; i < group_children.length; i++) {
    if ( group_children[i].down('.should_hide').value != 1 && group_children[i].down('.should_destroy').value != 1) {
      count++;
    }
  }
  
  //alert(count)
  if (count == 0) {
    new Effect.toggle(element_group)
  }
}
/////////////////
