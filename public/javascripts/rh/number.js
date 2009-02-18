function mark_resource_for_destroy(id) {
  $(id).next('.should_destroy').value = 1;
  $(id).up('.number').hide();
}

