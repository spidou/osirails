function refresh(object,event) {
 //  alert(event.keyCode);
if (event.keyCode == 27) {
object.getElementsByClassName('inplaceeditor-form')[0].remove();
object.getElementsByClassName('in_line_editor_span')[0].style.display = 'inline-block';
}
}