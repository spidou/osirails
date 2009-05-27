module SearchIndexesHelper

  def generate_table_headers(columns)
    html=""
    columns.each do |column|
      html+="<th>#{column.humanize.titleize}</th>"
    end
    return html
  end
  
  def generate_results_table_cells(collection, columns)
    html=""
    collection.each do |object|
      html+="<tr>"
      columns.each do |attribute|
        html+="<td>#{ format_date(object.send(attribute)) }</td>" if object.respond_to?(attribute)
      end
      html+="</tr>"
    end
    return html
  end
  
  def format_date(result)
    if result.class == ActiveSupport::TimeWithZone
      return result.strftime("%d/%b/%Y at %H:%M")
    elsif result.class == Date
      return result.strftime("%d/%b/%Y")
    elsif result.class == DateTime
      return result.strftime("%d/%b/%Y at %H:%M")
    elsif result.class == Time
      return result.strftime("%H:%M")
    else
      return result
    end
  end
end
