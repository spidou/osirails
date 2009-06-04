/////////////////
// resources
function mark_resource_for_destroy(element) {
  resource = element.up('.resource')
  resource.down('.should_destroy').value = 1
  Effect.toggle(resource, 'appear')
  
  hide_resource_group(resource.up('.resource_group'))
}

function mark_resource_for_update(element) {
  resource = element.up('.resource')
  if (resource.down('.should_update').value != 1) {
    resource.down('.should_update').value = 1
    
    resource_form = resource.down('.resource_form')
    Effect.toggle(resource_form, 'slide')
  }
}

function mark_resource_for_dont_update(element) {
  resource = element.up('.resource')
  resource.down('.should_update').value = 0
  
  resource_form = resource.down('.resource_form')
  Effect.toggle(resource_form, 'slide')
}

function cancel_creation_of_new_resource(element) {
  resource_group = element.up('.resource_group')
  element.up('.resource').remove();
  
  hide_resource_group(resource_group)
}

function hide_resource_group(element_group) {
  group_children = element_group.select('.resource')
  count = 0
  for (i = 0; i < group_children.length; i++) {
    if (!group_children[i].down('.should_destroy') || group_children[i].down('.should_destroy').value == 0) {
      count++;
    }
  }
  
  //alert(count)
  if (count == 0) {
    new Effect.toggle(element_group)
  }
}
/////////////////
