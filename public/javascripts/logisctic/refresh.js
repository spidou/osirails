function refresh(object,event) {
if (event.keyCode == 27) {
object.getElementsByClassName('inplaceeditor-form')[0].remove();
object.getElementsByClassName('in_line_editor_span')[0].style.display = 'block';

}
}