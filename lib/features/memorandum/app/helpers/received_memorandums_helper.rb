module ReceivedMemorandumsHelper

  # This method permit to show memorandums
  def show_memorandums(memorandums)
  memorandums_list = []
      memorandums.each do |memorandum|
        unless memorandum.published_at.nil?
          link_to_show = link_to("#{memorandum.title}", received_memorandum_path(memorandum.id))
        
          memorandums_list << "<tr title='#{memorandum.subject}'>"
          memorandums_list << "<td>#{link_to_show}</td>"
          memorandums_list << "<td>#{Memorandum.get_structured_date(memorandum)}</td>"
          memorandums_list << "<td>#{memorandum.signature}</td>"
          memorandums_list << "</tr>"
        end
      end
    memorandums_list
  end

  # This method permit to view a memorandum
  def view_memorandum(memorandum)
    view = []
    view << "<p><strong>Objet : </strong>#{memorandum.subject}</p>"
    view << "<p><strong>Date : </strong>#{Memorandum.get_structured_date(memorandum)}</p>"
    view << "<p><strong>Destinataire : </strong>#{Memorandum.get_recipient(memorandum)}</p>"
    view << "<hr/>"
    view << memorandum.text
    view << "<hr/>"
    view << "<p><strong>De : </strong> #{memorandum.signature}</p>"
    view << "<p><strong>Publi&eacute; par : </strong> #{Memorandum.get_employee(memorandum)}</p>"
  end

end
