/////////////////
// documents
function mark_document_for_destroy(id) {
  element = $('document_'+id)
  element.down('.should_destroy').value = 1;
  Effect.toggle(element, 'appear');
  
  hide_document_group(element.up('.document_group'))
}

function mark_document_for_update(id) {
  element = $('document_'+id)
  if (element.down('.should_update').value != 1) {
    element.down('.should_update').value = 1;
    Effect.toggle('document_form_' + id, 'slide');
  }
}

function mark_document_for_dont_update(id) {
  element = $('document_'+id)
  element.down('.should_update').value = 0;
  Effect.toggle('document_form_' + id, 'slide');
}

function cancel_creation_of_new_document(element) {
  element_group = element.up('.document_group')
  element.up('.document').remove();
  
  hide_document_group(element_group)
}

function hide_document_group(element_group) {
  group_children = element_group.select('.document')
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
