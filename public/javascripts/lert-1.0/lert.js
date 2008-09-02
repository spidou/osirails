/*
* Lert v1.0
* by Jeffrey Sambells - http://JeffreySambells.com
* For more information on this script, visit http://JeffreySambells.com/openprojects/lert/
* Licensed under the Creative Commons Attribution 2.5 License - http://creativecommons.org/licenses/by/2.5/
* Icons from Tango Desktop Project http://tango.freedesktop.org/Tango_Desktop_Project
*/
function Lert(message, buttons, options) {
	this.message_ = message;
	this.buttons_ = buttons;
	this.defaultButton_ = options.defaultButton || this.buttons_[0];
	this.icon_ = options.icon || null;
}

Lert.prototype.display = function() {
	var body = document.getElementsByTagName ('BODY')[0];
	var pageScroll = getPageScroll();
	var pageSize = getPageSize();

	//create the overlay if necessary
	var overlay = document.getElementById('lertOverlay');
	if(!overlay) {
		var overlay = document.createElement("div");
		overlay.setAttribute('id','lertOverlay');
		overlay.style.display = 'none';
		body.appendChild(overlay);
	}

	//position and show the overlay
	overlay.style.height=pageSize[1]+'px';
	overlay.style.display='block';

	//create the container if necessary
	var container = document.getElementById('lertContainer');
	if(!container) {
		var container = document.createElement("div");
		container.setAttribute('id','lertContainer');
		container.style.display = 'none';
		body.appendChild(container);
	}

	//position and show the container
	container.style.top = ( pageScroll[1] + (pageSize[3] / 15) ) + 'px';
	container.style.display = 'block';

	//create the window
	var win = document.createElement('div');
	win.setAttribute('id','lertWindow');

	//create the optional icon
	if(this.icon_ != null) {
		var icon = document.createElement('img');
		icon.setAttribute('src',this.icon_);
		icon.setAttribute('id','lertIcon');
		icon.setAttribute('alt','');
		win.appendChild(icon);
	}

	//create the message space
	var message = document.createElement('p');
	message.setAttribute('id','lertMessage');
	message.innerHTML = this.message_;
	win.appendChild(message);

	//create the button space
	var buttons = document.createElement('div');
	buttons.setAttribute('id','lertButtons');

	var oldKeyDown = document.onkeydown;

	//add each button
	for(i in this.buttons_) {
		var button = this.buttons_[i];
		if(button.getDom) {
			var domButton = button.getDom(function() {
				container.style.display = 'none';
				overlay.style.display = 'none';
				document.onkeydown=oldKeyDown;
				container.innerHTML = '';
				button.onclick_;
			},this.defaultButton_);
			buttons.appendChild(domButton);
		}
	}
	win.appendChild(buttons);

	document.onkeydown = this.keyboardControls;

	//append the window
	container.appendChild(win);
}

Lert.prototype.keyboardControls = function(e) {
	if (e == null) { keycode = event.keyCode; } // ie
	else { keycode = e.which; } // mozilla
	if(keycode==13) { document.getElementById('lertDefaultButton').onclick(); }
}

function LertButton(label, event, options) {
	this.label_ = label;
	this.onclick_ = event;
	this.eventClick = function() {};
}

LertButton.prototype.getDom = function(eventCleanup,defaultButton) {
	var button = document.createElement('a');
	button.setAttribute('href','javascript:void(0);');
	button.className = 'lertButton';
	if(this == defaultButton) button.setAttribute('id','lertDefaultButton');
	button.innerHTML = this.label_;

	var eventOnclick =  this.onclick_;
	button.onclick = function() {
		eventCleanup();
		eventOnclick();
	}
	this.eventClick = button.onclick;
	return button;
}

//
// getPageScroll()
// Returns array with x,y page scroll values.
// Core code from - quirksmode.org
function getPageScroll(){

	var yScroll;

	if (self.pageYOffset) {
		yScroll = self.pageYOffset;
	} else if (document.documentElement && document.documentElement.scrollTop){	 // Explorer 6 Strict
		yScroll = document.documentElement.scrollTop;
	} else if (document.body) {// all other Explorers
		yScroll = document.body.scrollTop;
	}

	arrayPageScroll = new Array('',yScroll)
	return arrayPageScroll;
}

// -----------------------------------------------------------------------------------

//
// getPageSize()
// Returns array with page width, height and window width, height
// Core code from - quirksmode.org
// Edit for Firefox by pHaez
//
function getPageSize(){

	var xScroll, yScroll;

	if (window.innerHeight && window.scrollMaxY) {
		xScroll = document.body.scrollWidth;
		yScroll = window.innerHeight + window.scrollMaxY;
	} else if (document.body.scrollHeight > document.body.offsetHeight){ // all but Explorer Mac
		xScroll = document.body.scrollWidth;
		yScroll = document.body.scrollHeight;
	} else { // Explorer Mac...would also work in Explorer 6 Strict, Mozilla and Safari
		xScroll = document.body.offsetWidth;
		yScroll = document.body.offsetHeight;
	}

	var windowWidth, windowHeight;
	if (self.innerHeight) {	// all except Explorer
		windowWidth = self.innerWidth;
		windowHeight = self.innerHeight;
	} else if (document.documentElement && document.documentElement.clientHeight) { // Explorer 6 Strict Mode
		windowWidth = document.documentElement.clientWidth;
		windowHeight = document.documentElement.clientHeight;
	} else if (document.body) { // other Explorers
		windowWidth = document.body.clientWidth;
		windowHeight = document.body.clientHeight;
	}

	// for small pages with total height less then height of the viewport
	if(yScroll < windowHeight){
		pageHeight = windowHeight;
	} else {
		pageHeight = yScroll;
	}

	// for small pages with total width less then width of the viewport
	if(xScroll < windowWidth){
		pageWidth = windowWidth;
	} else {
		pageWidth = xScroll;
	}

	arrayPageSize = new Array(pageWidth,pageHeight,windowWidth,windowHeight)
	return arrayPageSize;
}
