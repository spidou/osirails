OsirailsBase.addMethods({
  
  update_real_value_element: function(element, value) { //TODO rename to update_real_value_numeric_element
    element.writeAttribute('real-value', value)
    element.writeAttribute('title', value)
  },
  
  update_displayed_value_element: function(element, value, precision) { //TODO rename to update_displayed_value_numeric_element
    if (isNaN(value))
      element.update(value)
    else if (!isFinite(value))
      element.update('∞')
    else
      element.update(roundNumber(value, precision || 2))
  },
  
  highlight_element: function(element) {
    new Effect.Highlight(element, {afterFinish: function(){ element.setStyle({backgroundColor: ''}) }})
  },
  
  update_and_highlight_element: function(element, value, precision) { //TODO rename to update_and_highlight_numeric_element
    this.update_real_value_element(element, value)
    this.update_displayed_value_element(element, value, precision || 2)
    this.highlight_element(element)
  }
  
})

function restore_original_value(element, value) {
  if (value.length > 0) {
    input = element.down('.input_' + value)
    original = element.down('.input_original_' + value)
    if (input != null && original != null && original.value.length > 0) {
      input.value = original.value
    }
  }
}
