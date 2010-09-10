/* inspired by this file : http://github.com/edavis10/redmine/blob/69769e1dfde5194edda2b8afafc7bbfc5ece247e/public/javascripts/context_menu.js */

Array.prototype = {
  include: function (value) {
    for (var i = 0; i < this.length; i++) {
      if (this[i] === value) return true;
    }
    return false;
  }
};

var selectableItemsHtmlClasses = new Array();
var anyContextMenu;
var contextMenu;

ContextMenu = Class.create();
ContextMenu.prototype = {
	initialize: function (url, selectableItemHtmlClass) {
    if(!anyContextMenu) {
      contextMenu = this;
	    this.identifier = 'context-menu';
	    this.url = url;
	    this.lastSelectedForContextMenu = null;
	    
      if (!this.getIdentifier()) {
        var menu = document.createElement("div");
        menu.setAttribute("id", this.identifier);
        menu.setAttribute("style", "display:none;");
        this.getFormAncestorItem().appendChild(menu);
      }
      
	    Event.observe(document, 'click', this.clickListener.bindAsEventListener(this));
	    Event.observe(document, (window.opera ? 'click' : 'contextmenu'), this.rightClickListener.bindAsEventListener(this));
	    
	    Event.observe(window, 'load', function() {
        contextMenu.tagSelectableItems();
        contextMenu.unselectAll();
      }); 
	    
	    anyContextMenu = true;
    }
    
    if(!selectableItemsHtmlClasses.include(selectableItemHtmlClass)) { selectableItemsHtmlClasses.push(selectableItemHtmlClass); }
	},
	
	tagSelectableItems: function(){
	  selectableItemsHtmlClasses.each(function(s) {
      var items = $$('.'+s);
      
      items.each(function(i) {
        i.addClassName('hascontextmenu');
      });
    });
	},
  
  hideMenu: function() {
    Element.hide(this.identifier);
  },
	
	showMenu: function(e) {
    var mouse_x = Event.pointerX(e);
    var mouse_y = Event.pointerY(e);
    var render_x = mouse_x;
    var render_y = mouse_y;
    var dims;
    var menu_width;
    var menu_height;
    var window_width;
    var window_height;
    var max_width;
    var max_height;

    this.getIdentifier().style['left'] = (render_x + 'px');
    this.getIdentifier().style['top'] = (render_y + 'px');		
    Element.update(this.identifier, '');

    new Ajax.Updater({success:this.identifier}, this.url, 
    {asynchronous:true,
     evalScripts:true,
     parameters:Form.serialize(this.getFormAncestorItem()),
     onComplete:function(request){
		   dims = contextMenu.getIdentifier().getDimensions();
		   menu_width = dims.width;
		   menu_height = dims.height;
		   max_width = mouse_x + 2*menu_width;
		   max_height = mouse_y + menu_height;
	
		   var ws = getWindow_size();
		   window_width = ws.width;
		   window_height = ws.height;
	
		   /* display the menu above and/or to the left of the click if needed */
		   if (max_width > window_width) {
		     render_x -= menu_width;
		     contextMenu.getIdentifier().addClassName('reverse-x');
		   } else {
			   contextMenu.getIdentifier().removeClassName('reverse-x');
		   }
		   if (max_height > window_height) {
		     render_y -= menu_height;
		     contextMenu.getIdentifier().addClassName('reverse-y');
		   } else {
			   contextMenu.getIdentifier().removeClassName('reverse-y');
		   }
		   if (render_x <= 0) render_x = 1;
		   if (render_y <= 0) render_y = 1;
		   contextMenu.getIdentifier().style['left'] = (render_x + 'px');
		   contextMenu.getIdentifier().style['top'] = (render_y + 'px');
		   
       Effect.Appear(contextMenu.identifier, {duration: 0.20});
       if (window.parseStylesheets) { window.parseStylesheets(); } // IE
    }})
  },
  
  clickListener: function(e){
	  this.hideMenu();
	  if (Event.element(e).tagName == 'A') { return; }
    if (window.opera && e.altKey) {	return; }
    if (Event.isLeftClick(e) || (navigator.appVersion.match(/\bMSIE\b/))) {     
	    var selectableItem = this.getSelectableItem(Event.element(e));
      if (selectableItem!=null && selectableItem!=document && selectableItem.hasClassName('hascontextmenu')) {
        // a row was clicked, check if the click was on checkbox
        var box = Event.element(e);
        if (box!=document && box!=undefined && box.tagName == 'INPUT' && box.type == 'checkbox') {
          // a checkbox may be clicked
          if (box.checked) {
            box.checked = false;
            var inputReference = this.getAllSelectedCheckboxes()[0];
            if(inputReference != undefined && this.getAssociatedCheckbox(selectableItem).name != inputReference.name ){
              this.unselectAll();
            }
            this.addSelection(selectableItem);
          } else {
            this.removeSelection(selectableItem);
          }
        } else {
          if (e.ctrlKey) {
            if (this.lastSelectedForContextMenu != null) {
              var inputReference = this.getAllSelectedCheckboxes()[0];
              if(this.getAssociatedCheckbox(selectableItem).name != inputReference.name ){
                this.unselectAll();
              }
              this.toggleSelection(selectableItem);
              this.lastSelectedForContextMenu = selectableItem;
            }
          } else if (e.shiftKey) {
            if (this.lastSelectedForContextMenu != null) {
              var inputReference = this.getAllSelectedCheckboxes()[0];
              if(this.getAssociatedCheckbox(selectableItem).name == inputReference.name){
                var toggling = false;
                var boxes = this.getFormAncestorItem().descendants().findAll(function(n) { return n.tagName == 'INPUT' && n.type == 'checkbox' && n.name == inputReference.name})            
                for (i=0; i<boxes.length; i++) {
                  if (toggling || this.getSelectableItem(boxes[i])==selectableItem) {
                    this.addSelection(this.getSelectableItem(boxes[i]), true);
                  }
                  if (this.getSelectableItem(boxes[i])==selectableItem || this.getSelectableItem(boxes[i])==this.lastSelectedForContextMenu) {
                    toggling = !toggling;
                  }
                }
              } else {
                this.newSelection(selectableItem);         
              }
            } 
          } else {
            this.newSelection(selectableItem);
          }
        }
      } else {
        // click is outside the rows
        var t = Event.findElement(e, 'a');
        if (t == document || t == undefined) {
          this.unselectAll();
        } else {
          if (Element.hasClassName(t, 'disabled') || Element.hasClassName(t, 'submenu')) {
            Event.stop(e);
          }
        }
      }
    }
    else{
    }
  },
  
  rightClickListener: function(e) {
	  this.hideMenu();
	  // do not show the context menu on links
	  if (Event.element(e).tagName == 'A') { return; }
	  // right-click simulated by Alt+Click with Opera
	  if (window.opera && !e.altKey) { return; }
	  var selectableItem = this.getSelectableItem(Event.element(e));
	  if (selectableItem == document || selectableItem == undefined  || !selectableItem.hasClassName('hascontextmenu')) { return; }
	  Event.stop(e);
	  if (!this.isSelected(selectableItem)) {
		  this.unselectAll();
		  this.addSelection(selectableItem);
	  }
	  this.showMenu(e);
  },
  
  unselectAll: function() {
    var inputs = this.getAllSelectedCheckboxes();
    for (i=0; i<inputs.length; i++) {
      this.removeSelection(this.getSelectableItem(inputs[i]));
    }
    
    this.lastSelectedForContextMenu = null;
  },
  
  getIdentifier: function() {
    return $(this.identifier);
  },
  
  getFormAncestorItem: function() {
    return $('block_body');
  },
  
  getAllSelectedCheckboxes: function(){
    return this.getFormAncestorItem().descendants().findAll(function(n) { return n.tagName == 'INPUT' && n.type == 'checkbox' && n.checked == true });
  },
  
  getAssociatedCheckbox: function(object) {
    return object.descendants().find(function(c) { return c.tagName == 'INPUT' && c.type == 'checkbox' && contextMenu.getSelectableItem(object) == contextMenu.getSelectableItem(c)});
  },

  getSelectableItem: function(object) {
    if (object.hasClassName('hascontextmenu')){
      return object;
    } else {
      return object.up('.hascontextmenu');
    }
  },
  
  isSelected: function(selectableItem) {
    return selectableItem.hasClassName('context-menu-selection');
  },

  checkSelectionBox: function(selectableItem, checked) {
    this.getAssociatedCheckbox(selectableItem).checked = checked;
  },

  addSelection: function(selectableItem) {
    this.addSelection(selectableItem, false);
  },

  addSelection: function(selectableItem, cancel) {
    if(!selectableItem.hasClassName('context-menu-selection')){
      if(this.getAssociatedCheckbox(selectableItem).hasClassName('context-menu-single-selection')){
        if(cancel) { return; } else { this.unselectAll(); }
      }
      selectableItem.addClassName('context-menu-selection');
      this.checkSelectionBox(selectableItem, true);
      this.clearDocumentSelection();
      if(!cancel){
        this.lastSelectedForContextMenu = selectableItem;
      }
    }
  },

  removeSelection: function(selectableItem) {
    selectableItem.removeClassName('context-menu-selection');
    this.checkSelectionBox(selectableItem, false);
  },
  
  newSelection: function(selectableItem) {
    this.unselectAll();
    this.addSelection(selectableItem);     
  },

  toggleSelection: function(selectableItem) {
    if (this.isSelected(selectableItem)) {
      this.removeSelection(selectableItem);
    } else {
      this.addSelection(selectableItem);
    }
  },

  clearDocumentSelection: function() {
    if (document.selection) {
      document.selection.clear(); // IE
    } else {
      window.getSelection().removeAllRanges();
    }
  }
}

function toggleSelectableItems(selectableItemsClass) {
	var boxes = contextMenu.getFormAncestorItem().descendants().findAll(function(n) { return n.tagName == 'INPUT' && n.type == 'checkbox' && n.name == selectableItemsClass+'_ids[]' });
	var all_checked = true;
	for (i = 0; i < boxes.length; i++) { if (boxes[i].checked == false) { all_checked = false; break; } }
	contextMenu.unselectAll();
	if(!all_checked){
	  for (i = 0; i < boxes.length; i++) {
	    selectableItem = contextMenu.getSelectableItem(boxes[i]);
		  contextMenu.addSelection(selectableItem, true);
	    contextMenu.lastSelectedForContextMenu = selectableItem;
	  }
	}
}

function getWindow_size() {
  var w;
  var h;
  if (window.innerWidth) {
    w = window.innerWidth;
    h = window.innerHeight;
  } else if (document.documentElement) {
    w = document.documentElement.clientWidth;
    h = document.documentElement.clientHeight;
  } else {
    w = document.body.clientWidth;
    h = document.body.clientHeight;
  }
  return {width: w, height: h};
}
