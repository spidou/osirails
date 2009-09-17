require_dependency 'service'
require_dependency 'application_helper'

class Service
  has_many :memorandums_services
  has_many :memorandums, :through => :memorandums_services
end

module ApplicationHelper
  # This method permit to make diplay memorandums under banner
  def display_memorandums
    under_banner = []
    unless current_user.employee.nil?
      size = last_memorandums.size
      memorandum_number = ( size == 0 ? "0" : "1" )
      under_banner << "<div id='text_under_banner' style='overflow: hidden;' onclick='show_memorandum(this, 0)'>"
      under_banner << last_memorandums
      under_banner << "</div>"
      under_banner <<	"<div id='block_button_under_banner'>"
      under_banner << "<input type='button' id='previous' class='previous_memorandum_#{size}' alt='bouton précédent' title='Information précédente' onclick='change_memorandum(this, #{size}, event)'  />"
      under_banner << "<span class='number'> #{memorandum_number} </span>|<span class='number'> #{size} </span>"
      under_banner << "<input type='button' id='next' class='next_memorandum_2' alt='bouton suivant' title='Information suivante' onclick='change_memorandum(this, #{size}, event)'  />"
      under_banner << "</div>"
    else
      under_banner << "<span id='not_employee_reference'>Vous ne pouvez recevoir de notes de service car vous n'&ecirc;tes pas associ&eacute; &agrave; un employ&eacute;</span>"
    end
  end
   
  # This method permit to recover last 10 memorandums
  def last_memorandums
    unless current_user.employee.nil?
      memorandums = Memorandum.find_by_services([current_user.employee.service])
      last_memorandum = []
      max_memorandums = 0
      memorandums.each do |memorandum|
        unless memorandum.published_at.nil?
          max_memorandums += 1
          last_memorandum << format_memorandum(memorandum, max_memorandums) if max_memorandums < 11
        end
      end
    
      last_memorandum.reverse
    end
  end
  
  # This method permit to format memorandum
  def format_memorandum(memorandum, max_memorandums)
      formated_memorandum = []
      memorandum_signature = "<strong>"+memorandum.signature+".</strong>"
      memorandum_date = "<span class='memorandum_date'>Le "+Memorandum.get_structured_date(memorandum)+".</span> "
      memorandum_title = "<span class='memorandum_title'>"+memorandum.title+"</span> : "
      memorandum_size = 400
      memorandum_subject_size = memorandum_size - (memorandum_signature.size + memorandum_date.size + memorandum_title.size) 
      memorandum_subject = "<span class='memorandum_subject'>"+truncate(memorandum.subject, memorandum_subject_size)+".</span> "
      display = ( max_memorandums == 1 ? "inline" : "none" )
      formated_memorandum << "<div id='banner_memorandum_#{memorandum.id}' class='memorandums position_#{max_memorandums}' style='display: #{display};'>"
      formated_memorandum << memorandum_date
      formated_memorandum << memorandum_title
      formated_memorandum << memorandum_subject
      formated_memorandum << memorandum_signature+"</div>"
  end
end
