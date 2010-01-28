Object.extend(Element.ClassNames.prototype, Enumerable);

if (window.Widget == undefined) window.Widget = {};

Widget.Textarea = Class.create({
  initialize: function(textarea, options)
  {
    this.textarea = $(textarea);
    this.options = $H({
      'min_height' : this.textarea.getHeight(),
    }).update(options);
    
    if (this.options.get('min_height') == 0) {
      this.bind_reinitialize = this.reinitialize.bindAsEventListener(this)
      Event.observe(this.textarea, 'keyup', this.bind_reinitialize)
    } else {
      this.textarea.observe('keyup', this.refresh.bind(this));
      
      this._shadow = new Element('div').setStyle({
        lineHeight : this.textarea.getStyle('lineHeight'),
        fontSize : this.textarea.getStyle('fontSize'),
        fontFamily : this.textarea.getStyle('fontFamily'),
        position : 'absolute',
        top: '-10000px',
        left: '-10000px',
        width: this.textarea.getWidth() + 'px'
      });
      this.textarea.insert({ after: this._shadow });
      
      this.refresh();
    }
  },
  
  refresh: function()
  {
    this._shadow.update($F(this.textarea).replace(/\n/g, '<br/>'));
    this.textarea.setStyle({
      height: Math.max(parseInt(this._shadow.getHeight()) + parseInt(this.textarea.getStyle('lineHeight').replace('px', '')), this.options.get('min_height')) + 'px'
    });
  },
  
  reinitialize: function()
  {
    this.options.unset('min_height')
    this.initialize(this.textarea, this.options)
    Event.stopObserving(this.textarea, 'keyup', this.bind_reinitialize);
  }
});

Element.addMethods();
