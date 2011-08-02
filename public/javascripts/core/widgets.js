Event.observe(window, 'load', function() {
  init_widgets()
});

function init_widgets() {
  // defines droppable areas on top of each column
  $$('.droppable_area.top_column').each(function(element){
    var column = element.up('.widget_column').id.gsub('column_', '')
    
    Droppables.add(element.id, {
      accept: 'widget_container',
      hoverclass: 'droppable_hover',
      onHover: function(dragged, dropped, overlap) {
        var height = dragged.getStyle('height')
        dropped.setStyle({ height: height })
      },
      onEndHover: function(dropped) {
        dropped.setStyle({ height: '5px' })
      },
      onDrop: function(dragged, dropped, event) {
        dropped.insert({ after: dragged })
        
        var widget_name = dragged.id.gsub('widget_container_', '')
        var position = 1
        update_widget(widget_name, column, position)
      }
    });
  });
  
  // defines droppable areas on bottom of each widget
  $$('.droppable_area.bottom_widget').each(function(element){
    Droppables.add(element.id, {
      accept: 'widget_container',
      hoverclass: 'droppable_hover',
      onHover: function(dragged, dropped, overlap) {
        var height = dragged.getStyle('height')
        dropped.setStyle({ height: height})
      },
      onEndHover: function(dropped) {
        dropped.setStyle({ height: '5px' })
      },
      onDrop: function(dragged, dropped, event) {
        dropped.up('.widget_container').insert({ after: dragged })
        
        var widget_name = dragged.id.gsub('widget_container_', '')
        var column = dragged.up('.widget_column').id.gsub('column_', '')
        var position = dragged.previousSiblings().select(function(e){ return e.hasClassName('widget_container') }).length + 1
        update_widget(widget_name, column, position)
      }
    });
  });
  
  // defines droppable areas on entire column
  $$('.widget_column').each(function(element){
    var column = element.id.gsub('column_', '')
    var other_columns = $$('.widget_column').reject(function(e){ return e == this }, element)
    
    Droppables.add(element.id, {
      accept: 'widget_container',
      containment: other_columns.map(function(c){ return c.id }),
      hoverclass: 'droppable_hover',
      onDrop: function(dragged, dropped, event) {
        dropped.insert(dragged)
        
        var widget_name = dragged.id.gsub('widget_container_', '')
        var position = dropped.select('div.widget_container').length
        update_widget(widget_name, column, position)
      }
    });
  });
  
  // defines draggable elements
  $$('.widget_container').each(function(element){
    new Draggable(element.id, {
      scroll: window,
      handle: 'widget h2',
      revert: function(element, top_offset, left_offset) {
        element.setStyle({ top: '0px', left: '0px'})
      }
    });
  });
}

function update_widget(widget_name, column, position){
  var remote_path = "/widgets/"+widget_name+"/"+column+"/"+position
  new Ajax.Request(remote_path, {
    method: 'post',
    parameters: { 'authenticity_token': AUTH_TOKEN },
    evalScripts: false,
    onSuccess: function(transport) {
      log('success : ' + remote_path)
    },
    onFailure: function(transport) {
      log('failure : ' + remote_path)
    }
  })
}
