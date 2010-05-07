/////////////////
// establishments and contacts
function mark_resource_for_destroy(id) {
  $(id).down('.should_destroy').value = 1;
  $(id).hide();
}

function mark_resource_for_update(id) {
  $(id).down('.should_update').value = 1;
  $(id).down('.resource_form').show();
}

function mark_resource_for_dont_update(id) {
  $(id).down('.should_update').value = 0;
  $(id).down('.resource_form').hide();
}
/////////////////
