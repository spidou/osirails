osibox_wall = 'osibox_wall';
osibox_popup = 'osibox_popup';

function osibox_open (id) {
	id = id ? id : 1;
	
	osibox_wall_elm = document.getElementById(osibox_wall + id);
	osibox_popup_elm = document.getElementById(osibox_popup + id);
	
	osibox_popup_elm.style.display = 'block';
	osibox_wall_elm.style.display = 'block';
	
	var top = (document.body.offsetHeight - osibox_popup_elm.offsetHeight) / 2;
	if (top < 10) {
		top = 10;
	};
	var left = (document.body.offsetWidth - osibox_popup_elm.offsetWidth) / 2;
	if (left < 10) {
		left = 10;
	};
	
	osibox_popup_elm.style.top = top + document.documentElement.scrollTop + 'px';
	osibox_popup_elm.style.left = left + 'px';
	osibox_wall_elm.style.height = document.documentElement.scrollHeight + "px";
	
	if (osibox_popup_elm.offsetHeight > (document.body.offsetHeight + 20) ) {
		osibox_popup_elm.style.height = (document.body.offsetHeight - 50) + 'px';
		osibox_popup_elm.style.overflow = 'auto';
	};
	
	document.body.style.overflow = 'hidden';
	
	osibox_wall_elm.style.visibility = 'visible';	
	osibox_popup_elm.style.visibility = 'visible';
	
	osibox_popup_elm.style.display = 'none';
	Effect.Appear(osibox_popup_elm);
}

function osibox_close () {
	osibox_elements = document.getElementsByClassName('osibox');

	for (var i=0; i < osibox_elements.length; i++) {
		Effect.Fade(osibox_elements[i], {duration: 0.6});
		};
		document.body.style.overflow = '';
}