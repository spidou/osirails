/////////////////
// establishment
function mark_establishment_for_destroy(id) {
  $(id).up('.establishment_general_infos').hide();
  $(id).down('.should_destroy').value = 1;
}

function mark_establishment_for_update(id) {
  $(id).down('.establishment_form').show();
  $(id).down('.should_update').value = 1;
}

function mark_establishment_for_dont_update(id) {
  $(id).down('.establishment_form').hide();
  $(id).down('.should_update').value = 0;
}
/////////////////

/////////////////
// contact
function mark_contact_for_destroy(id) {
  $(id).up('.contact_general_infos').hide();
  $(id).down('.should_destroy').value = 1;
}

function mark_contact_for_update(id) {
  $(id).down('.contact_form').show();
  $(id).down('.should_update').value = 1;
}

function mark_contact_for_dont_update(id) {
  $(id).down('.contact_form').hide();
  $(id).down('.should_update').value = 0;
}
/////////////////