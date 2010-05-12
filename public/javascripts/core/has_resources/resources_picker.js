var ResourcesPicker = Class.create({
  initialize: function(options) {
    this.options                 = options
    this.select                  = options.select                        || 'select'
    this.mode                    = options.mode                          || 'many'
    this.hidden_element_prefix   = options.hidden_element_prefix         || 'resource_container'
    this.input_class             = '.' + options.input_class             || '.input'
    this.removable_element_class = '.' + options.removable_element_class || '.resource'
    this.element_actions_class   = '.' + options.element_actions_class   || '.actions'
    
    // list of removable elements
    this.removable_elements = null
    
    select_element = $(this.select)
    this.removable_elements = $$(this.removable_element_class)
    
    if (this.mode == 'many') {
      
      Event.observe(select_element, 'change', this.pick_many_resources.bindAsEventListener(this) )
      
      for (var i = 0; i < this.removable_elements.length; i++) {
        Event.observe(this.removable_elements[i], 'mouseover', this.show_actions_button.bindAsEventListener(this))
        Event.observe(this.removable_elements[i], 'mouseout', this.hide_actions_button.bindAsEventListener(this))
      }
    
    } else if (this.mode == 'one') {
    
      Event.observe(select_element, 'focus', this.initialize_one_resource.bindAsEventListener(this) )
      Event.observe(select_element, 'change', this.pick_one_resource.bindAsEventListener(this) )
    
    } else {
      alert('\'' + this.mode + '\' is not a correct mode for ResourcesPicker')
    }
  },
  
  pick_many_resources: function(event) {
    select = event.target
    option = select.options[select.selectedIndex]
    resource_id = parseInt(option.value)
    
    if (resource_id > 0) {
      resource = $(this.hidden_element_prefix + '_' + resource_id)
      if (resource.down(this.input_class)) { resource.down(this.input_class).checked = true }
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
    if (resource.down(this.input_class)) { resource.down(this.input_class).checked = false }
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
  },
  
  initialize_one_resource: function(event) {
    //nothing to do here
  },
  
  pick_one_resource: function(event) {
    select = event.target
    option = select.options[select.selectedIndex]
    resource_id = parseInt(option.value)
    
    input_class = this.input_class
    
    this.removable_elements.each( function(element){
      element.down(input_class).checked = false
      element.hide()
    })
    
    if (resource_id > 0) {
      resource = $(this.hidden_element_prefix + '_' + resource_id)
      resource.down(input_class).checked = true
      resource.appear()
    }
  }
});
