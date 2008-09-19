module ContentsHelper
  def display_reload_button
    link_to("Actualiser la page", :action =>:edit) if @affiche == true
  end
end