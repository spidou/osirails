module ReceivedMemorandumsHelper

  # This method permit to show memorandums
  def show_received_memorandums(memorandums)
  memorandums_list = []
      memorandums.each do |memorandum|
        unless memorandum.published_at.nil?
          link_to_show = ( Memorandum.can_view?(current_user) ? link_to("#{memorandum.title}", received_memorandum_path(memorandum.id)) : "#{memorandum.title}")
          period_memorandum = Memorandum.color_memorandums(memorandum)
          
          memorandums_list << "<tr title='#{memorandum.subject}' class='#{period_memorandum}'>"
          memorandums_list << "<td>#{link_to_show}</td>"
          memorandums_list << "<td>#{memorandum.subject}</td>"
          memorandums_list << "<td>#{memorandum.published_at.humanize}</td>"
          memorandums_list << "<td>#{memorandum.signature}</td>"
          memorandums_list << "</tr>"
        end
      end
    memorandums_list
  end

  # This method permit to view a memorandum
  def view_received_memorandum(memorandum)
    view = []
    view << "<p><strong>Objet : </strong>#{memorandum.subject}</p>"
    view << "<p><strong>Publiée le : </strong>#{memorandum.published_at.humanize}</p>"
    view << "<p><strong>Destinataire : </strong>#{Memorandum.get_recipient(memorandum)}</p>"
    view << "<hr/>"
    view << memorandum.text
    view << "<hr/>"
    view << "<p><strong>De : </strong> #{memorandum.signature}</p>"
    view << "<p><strong>Publié par : </strong> #{Memorandum.get_employee(memorandum)}</p>"
  end
  
  def received_memorandums_link
    text = "Voir toutes les notes de service reçues"#"List all received memorandums"
    link_to image_tag("list_16x16.png", :alt => text, :title => text) + " #{text}", received_memorandums_path
  end

end
