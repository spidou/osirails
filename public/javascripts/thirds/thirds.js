function mark_for_destroy(id) {
  $(id).down('.should_destroy').value = 1;
  $(id).up('.establishment_general_infos').hide();
}

function mark_for_update(id) {
  $(id).down('.establishment_form').show();
  $(id).down('.should_update').value = 1;
}

function mark_for_dont_update(id) {
  $(id).down('.establishment_form').hide();
  $(id).down('.should_update').value = 0;
}