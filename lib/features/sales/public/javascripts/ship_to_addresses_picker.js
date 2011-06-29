var ShipToAddressesPicker = Class.create({
  initialize: function(options) {
    this.options                 = options
    this.select                  = options.select                        || 'select'
    this.hidden_element_prefix   = options.hidden_element_prefix         || 'resource_container'
    this.create_class            = '.' + options.create_class            || '.should_create'
    this.destroy_class           = '.' + options.destroy_class           || '.should_destroy'
    this.removable_element_class = '.' + options.removable_element_class || '.resource'
    this.element_actions_class   = '.' + options.element_actions_class   || '.actions'
    
    // store the last selected option in the select box (only in 'one' mode)
    this.previously_selected_option = null
    // list of removable elements
    this.removable_elements = null
    
    select_element = $(this.select)
    this.removable_elements = $$(this.removable_element_class)
    
    Event.observe(select_element, 'change', this.pick_many_resources.bindAsEventListener(this) )
    
    for (var i = 0; i < this.removable_elements.length; i++) {
      Event.observe(this.removable_elements[i], 'mouseover', this.show_actions_button.bindAsEventListener(this))
      Event.observe(this.removable_elements[i], 'mouseout', this.hide_actions_button.bindAsEventListener(this))
    }
  },
  
  pick_many_resources: function(event) {
    select = event.target
    option = select.options[select.selectedIndex]
    resource_id = parseInt(option.value)
    
    if (resource_id > 0) {
      resource = $(this.hidden_element_prefix + '_' + resource_id)
      resource.down(this.create_class).value = 1
      resource.down(this.destroy_class).value = 0
      resource.show()
      resource.highlight()
      option.disabled = true
    }
  },
  
  show_actions_button: function(event) {
    element = event.target.up(this.removable_element_class) || event.target
    //if (!element) { alert('An error has occured. Please resource your administrator.\nerror: ' + '\'' + this.removable_element_class + '\' doesn\'t exist'); return; }
    if (!element) { return; } //TODO dump the error message to javascript console to make easier debugging
    
    element.down(this.element_actions_class).setStyle({display:'block'})
  },
  
  hide_actions_button: function(event) {
    element = event.target.up(this.removable_element_class) || event.target
    //if (!element) { alert('An error has occured. Please resource your administrator.\nerror: ' + '\'' + this.removable_element_class + '\' doesn\'t exist'); return; }
    if (!element) { return; } //TODO dump the error message to javascript console to make easier debugging
    
    element.down(this.element_actions_class).hide();
  },
  
  remove_resource_from_list: function(element) {
    resource = element.up(this.removable_element_class)
    resource.down(this.create_class).value = 0
    resource.down(this.destroy_class).value = 1
    resource.fade()
    
    // retrieve resource ID from the id attribute of the tag
    str_resource_id = resource.id.toString()
    resource_id = str_resource_id.substr(str_resource_id.lastIndexOf("_") + 1)
    select = $(this.select)
    options = select.options
    for (var i = 0; i < options.length; i++) {
      if (options.item(i).value == resource_id) {
        options.item(i).disabled = false
      }
    }
  }
});
