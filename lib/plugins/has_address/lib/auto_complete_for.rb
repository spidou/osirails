module AutoCompleteFor
  def auto_complete_for(object, method)
    @phrase    = params[:autocomplete_phrase]
    @keywords   = @phrase.split(" ")
    conditions = Array.new
    query      = String.new
    
    @keywords.each_with_index do |keyword, index|
      query += "#{method} like ?"
      query += " AND " unless index == @keywords.size - 1
      conditions.push("%#{keyword.mb_chars.downcase}%")
    end
    
    conditions.unshift(query)
    @items = "#{object}".camelize.constantize.find(:all, { :conditions  => conditions, :order => "#{method}"})
    render :inline => "<%= #{object}_#{method}_auto_complete_result(@items, @keywords) %>"
  end
end
