var TabNavigator = Class.create({
  initialize: function(name, options) {
    this.name           = name
    this.can_unfold_all = options.can_unfold_all || false
    this.select         = options.select // can be 'none', 'first', 'last', an integer (2, 3, etc), or a tab_name ('summary', 'products', etc)
    
    this.element = $(name)
    this.root_element = this.element.up()
    this.tabs = []
    
    Event.observe(window, 'load', this.initialize_event_listeners.bindAsEventListener(this) )
  },
  
  nav_elements: function() {
    return this.element.childElements()
  },
  
  content_elements: function() {
    return this.element.up('.root_nav').select('.content_nav').select(function(i){ return i.readAttribute('rel') == this.name }, this)
  },
  
  initialize_event_listeners: function(event) {
    this.nav_elements().each( function(li) {
      this.initialize_tab(li)
    }, this)
    
    // select first tab which have an error if any, or the 'select' tab
    if ( failure = this.tabs.detect(function(tab){ return tab.failed() }) ) {
      failure.select()
    } else {
      if ( !isNaN(parseInt(this.select)) ) {
        var select = parseInt(this.select)
        if (select < 0)
          index = 0 // select first if is lower than 0
        else if (select < this.tabs.length)
          index = select
        else
          index = this.tabs.length - 1 // select last if is higher than length of array
      } else {
        if (this.tabs.collect(function(tab){ return tab.name }).include(this.select))
          index = this.tabs.indexOf(this.tabs.detect(function(tab){ return tab.name == this }, this.select))
        else if (this.select == 'first')
          index = 0
        else if (this.select == 'last')
          index = this.tabs.length - 1
        else if (this.select == 'none')
          index = -1
        else
          index = -1 // select none by default
      }
      
      if (index >= 0)
        this.tabs[index].select()
    }
  },
  
  initialize_tab: function(li) {
    this.tabs.push( new Tab(li.readAttribute('tab'), { parent: this }) )
    return this.tabs.last()
  },
  
  create_tab: function(name, title, content, options) {
    options = options || {}
    var selected = options.selected || false
    var disabled = options.disabled || false
    
    var li_class = options.class || ""
    if (disabled) { li_class += " disabled" } else if (selected) { li_class += " selected" }
    
    var a = new Element('a', { 'onclick': 'return false;', 'href': '#' } ).update(title)
    var li = new Element('li', { 'tab': name, 'title': title, 'class': li_class }).update(a)
    this.element.insert({ bottom: li })
    
    var div = new Element('div', { 'class': 'content_nav', 'rel': this.name, 'tab': name }).update(content)
    this.root_element.insert({ bottom: div })
    
    this.initialize_tab(this.nav_elements().last())
    
    return this.tabs.last()
  },
  
  find_tab: function(tab_name) {
    return this.tabs.find(function(tab){ return tab.name == this }, tab_name)
  },
  
  shown_tabs: function() {
    return this.tabs.reject(function(tab){ return tab.hidden() })
  },
  
  hidden_tabs: function() {
    return this.tabs.select(function(tab){ return tab.hidden() })
  }
});

var Tab = Class.create({
  initialize: function(name, options) {
    this.name       = name
    this.parent     = options.parent
    
    this.selectedClassName  = 'selected'
    this.disabledClassName  = 'disabled'
    this.hiddenClassName    = 'hidden'
    this.warnedClassName    = 'warning'
    this.failedClassName    = 'errors'
    
    this.nav_element = this.parent.nav_elements().detect(function(c){
      return c.readAttribute('tab') == this.name
    }, this)
    
    this.content_element = this.parent.content_elements().detect(function(s){
      return s.readAttribute('tab') == this.name
    }, this)
    
    this.nav_element.onmousedown   = function() { return false; } // disable text selection (Firefox)
    this.nav_element.onselectstart = function() { return false; } // disable text selection (IE)
    
    this.bind_select = this.select.bindAsEventListener(this)
    
    // call status function according to given classes in HTML
    if (this.enabled()) { this.enable() } else { this.disable() }
    if (this.selected()) { this.select() } else { this.unselect() }
  },
  
  sibling_tabs: function() {
    return this.parent.tabs.reject(function(tab){
      return tab.name == this.name
    }, this)
  },
  
  update_nav_title: function(new_string) {
    this.nav_element.writeAttribute('title', new_string)
    this.nav_element.down('a').update(new_string)
  },
  
  update_nav_content: function(new_content) {
    this.content_element.update(new_content)
  },
  
  nav_title: function() {
    return this.nav_element.down('a').innerHTML;
  },
  
  position: function() {
    position = 0
    this.parent.tabs.each(function(tab, index) {
      if (tab.name == this.name) { position = index }
    }, this)
    return position
  },
  
  // functions which change status and/or DOM
  
  remove: function() {
    //TODO make changes in DOM
    this.nav_element.remove()
    this.content_element.remove()
  },
  
  hide: function() {
    this.nav_element.addClassName(this.hiddenClassName)
    this.content_element.addClassName(this.hiddenClassName)
  },
  
  show: function() {
    this.nav_element.removeClassName(this.hiddenClassName)
  },
  
  disable: function() {
    this.nav_element.addClassName(this.disabledClassName)
    this.nav_element.stopObserving('click', this.bind_select)
    this.content_element.addClassName(this.disabledClassName)
  },
  
  enable: function() {
    this.nav_element.removeClassName(this.disabledClassName)
    this.nav_element.observe('click', this.bind_select)
    this.content_element.removeClassName(this.disabledClassName)
  },
  
  select: function() {
    if (!this.disabled() && !this.hidden()) {
      if (this.unselected()) {
        this.sibling_tabs().each(function(s){ s.unselect() })
        
        this.nav_element.addClassName(this.selectedClassName)
        this.content_element.addClassName(this.selectedClassName)
      } else if (this.parent.can_unfold_all) {
        this.unselect()
      }
    }
  },
  
  unselect: function() {
    this.nav_element.removeClassName(this.selectedClassName)
    this.content_element.removeClassName(this.selectedClassName)
  },
  
  warn: function() {
    this.nav_element.addClassName(this.warnedClassName)
  },
  
  unwarn: function() {
    this.nav_element.removeClassName(this.warnedClassName)
  },
  
  fail: function() {
    this.nav_element.addClassName(this.failedClassName)
  },
  
  unfail: function() {
    this.nav_element.removeClassName(this.failedClassName)
  },
  
  // functions which return status
  
  hidden: function() {
    //return !this.nav_element.visible()
    return this.nav_element.hasClassName(this.hiddenClassName)
  },
  
  shown: function() {
    return !this.hidden()
  },
  
  disabled: function() {
    return this.nav_element.hasClassName(this.disabledClassName)
  },
  
  enabled: function() {
    return !this.disabled()
  },
  
  selected: function() {
    return this.nav_element.hasClassName(this.selectedClassName)
  },
  
  unselected: function() {
    return !this.selected()
  },
  
  warned: function() {
    return this.nav_element.hasClassName(this.warnedClassName)
  },
  
  unwarned: function() {
    return !this.warned()
  },
  
  failed: function() {
    return this.nav_element.hasClassName(this.failedClassName)
  },
  
  unfailed: function() {
    return !this.failed()
  }
});
