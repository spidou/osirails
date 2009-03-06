/* Globals */
checkbox_permission_class = 'checkbox_permission'

/* Functions */

// Function that return every siblings checkbox object who are on the same 
// line of the checkbox (class=checkbox_permission_class) specified in
// argument
function siblings_checkbox_of (object) {
  var siblings = new Array();
  var siblings_td = object.ancestors()[1].childNodes
  for (var i=0; i < siblings_td.length; i++) {
    if (siblings_td[i].tagName == 'TD') {
      child_elm = siblings_td[i].firstChild;
      if (child_elm.tagName == 'INPUT' && child_elm.type == 'checkbox' && child_elm.className != checkbox_permission_class) {
        siblings.push(child_elm);
      };
    };
  };
  return siblings;
}

// Function that check or uncheck all the sibilings checkbox object who are on 
// the same line of the checkbox (class=checkbox_permission_class) specified
// in argument
function check_all_permission (object) {
  siblings = siblings_checkbox_of(object);
  for (var i=0; i < siblings.length; i++) {
    siblings[i].checked = object.checked;
  };
}

// Function called when a normal checkbox is clicked. Than permit tout verify
// if we must check the checkbox (class=checkbox_permission_class) of the
// line
function verify_all_checkbox (object) {
  var checkbox_perm = object.ancestors()[1].getElementsByClassName(checkbox_permission_class)[0];
  must_check_checkbox_permission(checkbox_perm);
}

// Check the checkbox (class=checkbox_permission_class) if all of he's
// siblings checkbox are checked. Or contrary if not.
function must_check_checkbox_permission (object) {
  var must_be_checked = true;
  var siblings = siblings_checkbox_of(object);
  for (var i=0; i < siblings.length; i++) {
    if (siblings[i].checked == false) { must_be_checked = false };
  };
  
  object.checked = must_be_checked;
}

// Set every onclick attributes on every checkbox. And verify if checkbox
// (class=checkbox_permission_class) must be checked or not.
function init_checkbox_permission () {
  var all_checkbox = document.getElementsByClassName(checkbox_permission_class);
  
  for (var i=0; i < all_checkbox.length; i++) {
    must_check_checkbox_permission(all_checkbox[i]);
    all_checkbox[i].setAttribute('onclick', 'check_all_permission(this);');
    
    var siblings = siblings_checkbox_of(all_checkbox[i]);
    for (var j=0; j < siblings.length; j++) {
      siblings[j].setAttribute('onclick', 'verify_all_checkbox(this);');
    };
  };
}

init_checkbox_permission();
