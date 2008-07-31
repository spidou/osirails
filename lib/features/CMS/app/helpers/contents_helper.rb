module ContentsHelper
  def display_button
    link_to("reload", :action =>:edit) if @affiche == true
  end
end