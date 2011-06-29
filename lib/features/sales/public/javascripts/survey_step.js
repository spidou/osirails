var SurveyStep = Class.create(OsirailsBase, {
  initialize: function(root_element) {
    this.root = Object.isElement(root_element) ? root_element : $(root_element)
    
    this._add_item_button = this.root.down('input.add_item')
    
    this.bind_add_item = this.add_item.bindAsEventListener(this)
    
    Event.observe(window, 'load', this.initialize_event_listeners.bindAsEventListener(this))
  },
  
  initialize_event_listeners: function() {
    if (this._add_item_button) this._add_item_button.observe('click', this.bind_add_item)
  },
  
  add_item: function() {
    var autocomplete_field = $(this._add_item_button.readAttribute('data-field-id'))
    var remote_path = this._add_item_button.readAttribute('data-remote-path')
    var authenticity_token = this._add_item_button.readAttribute('data-token')
    
    var reference_type = autocomplete_field.readAttribute('data-autocomplete-reference-type') // like 'product_reference' or 'service_delivery'
    var reference_id = autocomplete_field.readAttribute('data-autocomplete-reference-id')
    
    if ( (value = autocomplete_field.readAttribute('data-autocomplete-value')) == undefined || value == "") {
      alert("Vous devez d'abord choisir un produit dans le champ ci-contre")
      return;
    }
    
    if ( parseInt(reference_id) > 0 ) {
      new Ajax.Request(remote_path, {
        method: 'get',
        parameters: { 'product_reference_id':reference_id,
                      'authenticity_token':authenticity_token },
        onSuccess: function(transport) {
          $('new_end_products').insert({ bottom: transport.responseText })
          
          $('new_end_products').show()
          $('new_end_products').select('.end_product').last().scrollTo().show().highlight()
          initialize_autoresize_text_areas()
          //$('product_reference_reference').value = '#{default_value_for_autocomplete_field}' #TODO $('id').value = ''; $('id').blur() => but it doesn't work!! how can I do this ?
        }
      });
    }
  }
})
