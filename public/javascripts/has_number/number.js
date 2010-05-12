function mark_number_for_destroy(id) {
  $(id).next('.should_destroy').value = 1;
  $(id).up('.number').hide();
}

function toggle_more_less_button(link, more_text, less_text)
{
  element = $(link).previous()
  (element.visible() ? element.blindUp() : element.blindDown())
  
  $(link).innerHTML = ($(link).previous().visible() ? less_text : more_text);
}

// function that is a trick used to prepare html entities to be linked together (contact with his numbers)
// TODO delete that method when the trick will become useless
//
function get_contact_fake_id(element)
{
  if(element.up('.contact'))
    element.parentNode.previous('.number').down('.has_number_id').value = element.up('.contact').down('.contact_id').value;
}
