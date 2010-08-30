module JournalizationHelper
  def display_journals_list(journals_subject)
    content_tag :div, render(:partial => "journals/journal", :collection => journals_subject.journals_with_lines), :id => "journals_list"
  end
  
  def render_collection_changes_for(journal_line)
    klass               = journal_line.journal.journalized_type.constantize
  
    belongs_to_property = journal_line.journal.journalized_type.constantize.journalized_belongs_to_attributes[journal_line.property.to_sym]
    
    old_value           = YAML.load(journal_line.old_value) if journal_line.old_value
    new_value           = YAML.load(journal_line.new_value) if journal_line.new_value
    
    if belongs_to_property
      property   = belongs_to_property.camelize
      created_at = journal_line.journal.created_at
      
      old_value = get_identifier("belongs_to", [property, old_value, created_at]) unless old_value.blank?
      new_value = get_identifier("belongs_to", [property, new_value, created_at]) unless new_value.blank?
      
      property = klass.human_attribute_name(property.underscore)
      
      if old_value.blank? && !new_value.blank?
        html = journal_li(journal_strong(property) + " #{get_translation("added", :initialization)}: " + new_value)
      elsif !old_value.blank? && new_value.blank?
        html = journal_li(journal_strong(property) + " " + old_value + " #{get_translation("removed", :one_removal)}")
      else
        html = journal_li(journal_strong(property) + " " + get_translation("changed from " + old_value + " to " + new_value, :changes, {:old_value => old_value, :new_value => new_value}))
      end
    else
      property = journal_line.property
      
      html = ""
      if old_value.instance_of?(Array) && new_value.instance_of?(Array)
        created_objects   = []
        destroyed_objects = []
        
        [old_value, new_value].each_with_index do |array, index|
          array.each do |v|
            unless [new_value, old_value][index].include?(v)
              [destroyed_objects, created_objects][index] << v unless journal_line.journal.journal_lines.detect {|l| l.property == journal_line.property && l.property_id == v}
            end
          end
        end
        
        [destroyed_objects, created_objects].each do |array|
          if array.any?
            several = array.size > 1
            html << "<li>#{journal_strong(klass.human_attribute_name(several ? property : property.singularize))} #{array == destroyed_objects ? (several ? get_translation("removed", :several_removals) : get_translation("removed", :one_removal)) : (several ? get_translation("added", :several_additions) : get_translation("added", :one_addition))}: " 
            array.each do |object|
              journal_line.property_id = object
              html << get_identifier("subresource", journal_line)
              html << ", " unless object == array.last
            end
            html << "</li>"
          end
        end
      else
        [old_value, new_value].each do |object|
          if object
            journal_line.property_id = object
            unless object == new_value && journal_line.journal.journal_lines.detect {|l| l.property == journal_line.property && l.property_id == object}
              html << journal_li("#{journal_strong(klass.human_attribute_name(property))} #{object == old_value ? get_translation("removed", :one_removal) : get_translation("added", :one_addition)}")
            end
          end
        end
      end
    end
    return html
  end
  
  def render_changes_for(journal_line)
    property = journal_line.property
    klass    = journal_line.journal.journalized_type.constantize
    
    unless has_subresource?(journal_line)
      property = klass.human_attribute_name(property)
    end
    
    old_value = journal_line.old_value
    new_value = journal_line.new_value
    
    if has_subresource?(journal_line)
      subresource_class_name = (plural?(property) ? property.singularize : property).camelize
      is_first = journal_line.referenced_journal == Journal.find_for(subresource_class_name, journal_line.property_id).first
      
      subresource_name = klass.human_attribute_name(subresource_class_name.underscore)
      
      html = journal_strong(subresource_name) + get_identifier("subresource", journal_line) + " #{is_first ? get_translation("added", :one_addition) : get_translation("modified", :modification)}"
      html << " (" + link_to_function("#{get_translation("Show details", :show_details)}", "Effect.toggle(this.next(), 'slide'); if(this.next().style.display == 'none') {this.innerHTML = '#{get_translation("Close", :hide_details)}'} else {this.innerHTML = '#{get_translation("Show details", :show_details)}'}") + ")"
      html << render(:partial => "journals/journal", :object => journal_line.referenced_journal, :locals => {:has_parent => true})
    elsif !old_value.blank? && !new_value.blank?
      html = journal_strong(property) + " " + get_translation("changed from " + journal_em(old_value) + " to " + journal_em(new_value), :changes, {:old_value => journal_em(old_value), :new_value => journal_em(new_value)} )
    elsif !old_value.blank? && new_value.blank?
      html = journal_strong(property) + " " + journal_em(old_value) + " #{get_translation("removed", :one_removal)}"
    elsif old_value.blank? && !new_value.blank?
      html = journal_strong(property) + " #{get_translation("added", :initialization)}: " + journal_em(new_value)
    end
    
    return journal_li(html)
  end
  
  def has_subresource?(journal_line)
    property = journal_line.property
    klass = journal_line.journal.journalized_type.camelize.constantize
    
    klass.journalized_subresources[:has_one].include?(property.to_sym) || klass.journalized_subresources[:has_many].include?(property.to_sym) || klass.journalized_belongs_to_attributes.include?(property.to_sym)
  end
  
  def render_journal_line(journal_line)
    journal_line.property_id.nil? && has_subresource?(journal_line) ? render_collection_changes_for(journal_line) : render_changes_for(journal_line)
  end
  
  def get_identifier(type, params)
    if type == "actor"
      journalized_klass_name = params.actor.class.name
      journalized_id         = params.actor.id
      created_at             = params.created_at
    elsif type == "subresource"
      reflection = params.journal.journalized_type.constantize.reflect_on_association(params.property.to_sym)
      journalized_klass_name = reflection.class_name
      journalized_id         = params.property_id
      created_at             = params.journal.created_at
      
      return "" if reflection.macro == :has_one
    elsif type == "belongs_to"
      journalized_klass_name = params[0]
      journalized_id         = params[1]
      created_at             = params[2]
    end
    
    default_identifier = "#{journalized_klass_name} ##{journalized_id}"
    default_identifier = " \"#{journal_em(default_identifier)}\""
    
    journalized_identifier = JournalIdentifier.find_last_for(journalized_klass_name, journalized_id)
    if journalized_identifier
      last_identifier   = journalized_identifier.new_value
      last_identifier ||= default_identifier
      last_identifier   = journal_em(last_identifier)
      
      if type == "actor"
        last_identifier = link_to(last_identifier, send("#{Journalization::ActorClassName.underscore}_path", journalized_id))
      else
        last_identifier = " \"#{last_identifier}\""
      end
      
      old_journalized_identifier = JournalIdentifier.find_last_for(journalized_klass_name, journalized_id, created_at)
      if old_journalized_identifier && old_journalized_identifier.new_value != journalized_identifier.new_value
        old_identifier = journal_em(old_journalized_identifier.new_value)

        old_identifier = "\"#{old_identifier}\"" unless type == "actor"
        identifier = old_identifier + " (" + get_translation("currently known as #{last_identifier}", :current_identifier, :identifier => last_identifier) + ")"
      else
        identifier = last_identifier
      end
    end
    
    identifier ||= default_identifier
    return identifier
  end
  
  def get_lines_with_paperclip_management(journal_lines)
    return [] if journal_lines.empty?
    
    journal_lines.first.journal.journalized_type.constantize.journalized_attachments.each do |attachment|
      journal_lines = journal_lines.reject {|l| l.property == "#{attachment}_file_size"}.each {|l| l.property = attachment.to_s if  l.property == "#{attachment}_file_name"}
    end
      
    return journal_lines
  end
  
  def get_title(journal)
    author = content_tag :span, :class => "journal_author" do
      get_translation("#{"By " + get_identifier("actor", journal)}", :author, :author => get_identifier("actor", journal)) if journal.actor
    end
    
    time_distance = content_tag :span, :class => "journal_time_distance", :title => defined?(I18n) ? l(journal.created_at) : journal.created_at.strftime("%A, %B %d, %Y at %H:%M") do
      content = get_translation("#{time_ago_in_words(journal.created_at)} ago", :time_distance, :time_distance => time_ago_in_words(journal.created_at))
      content.capitalize! unless journal.actor
      content
    end
    
    return journal.actor ? "#{author}, #{time_distance}" : time_distance
  end
  
  # This method permits to manage projects which Rails version is under 2.2 (without I18n)
  # OPTIMIZE me to avoid repetition, default values are the same as those in lib/locale/en.yml
  def get_translation(default, key, interpolations = {})
    return defined?(I18n) ? t("journalization.#{key}", interpolations.merge(:default => default)) : default
  end
  
  def journal_em(text, options = {})
    content_tag :em, text, options
  end
  
  def journal_li(text, options = {})
    content_tag :li, text, options
  end
  
  def journal_strong(text, options = {})
    content_tag :strong, text, options
  end
  
  def journal_strike(text, options = {})
    content_tag :strike, text, options
  end
  
  def plural?(string)
    return false if string.last == "s" and string.pluralize   != string
    return true  if string.last == "s" and string.pluralize   == string
    return true  if string.last != "s" and string.singularize != string
    return false if string.last != "s" and string.singularize == string
  end
end
