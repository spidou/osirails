module ErrorsHelper
  # That rewriting of the "error_messages_for" method was made to customize his behaviour 
  #
  # ==== Put links on nested resource error messages
  # By default, links are put on nested resource error messages to focus on the targetted nested
  # resource section. The redirection works assuming that the nested resource section has a HTML id.
  #
  # Links can be skipped by passing the "skip_links" option:
  #   error_messages_for(:skip_links => true)
  #
  # ==== Hide "is invalid" error messages on attributes
  # By default, "is invalid" error messages on attributes are hidden. Commonly, this happens when
  # an error is raised on an attribute and its error message is empty, but precised on the "base".
  #
  # "is invalid" error messages on attributes can be kept by passing the "keep_invalid_attributes" option:
  #   error_messages_for(:keep_invalid_attributes => true)
  #
  # ==== Miscellaneous
  # * Fixes an issue encountered on nested resource, error messages were repeated once more than necessary.
  # * Uses a custom counter to display the correct number of errors when some of them are hidden.
  def error_messages_for(*params)
    options = params.extract_options!.symbolize_keys
    if object = options.delete(:object)
      objects = [object].flatten
    else
      objects = params.collect {|object_name| instance_variable_get("@#{object_name}") }.compact
    end
    count   = objects.inject(0) {|sum, object| sum + object.errors.count }
    unless count.zero?
      html = {}
      [:id, :class].each do |key|
        if options.include?(key)
          value = options[key]
          html[key] = value unless value.blank?
        else
          html[key] = 'errorExplanation'
        end
      end
      options[:object_name] ||= params.first
      unless options.include?(:message)
        options[:message] ||= I18n.t 'activerecord.errors.template.body'
      end
    
      errors_count = 0
      error_messages = objects.map do |object|
        object.errors.full_messages.uniq.map do |full_message| 
          full_message_index = object.errors.full_messages.index(full_message)
          error_attribute = object.errors.map[full_message_index][0]
          error_message = object.errors.map[full_message_index][1]
          if object.attributes.map{|attribute| attribute[0]}.include?(error_attribute) or error_attribute == "base"
            unless (error_message == I18n.t('activerecord.errors.messages.invalid') and !options[:keep_invalid_attributes])
              errors_count +=1
              content_tag(:li, full_message)
            end
          else
            errors_count +=1
            options[:skip_links] ? content_tag(:li, full_message) : content_tag(:li, content_tag(:a, full_message, :href => "##{error_attribute}"))
          end
        end
      end
      
      header_message = errors_count > 1 ? "other" : "one"
      options[:header_message] = I18n.t("activerecord.errors.template.header.#{header_message}", :count => errors_count) unless options.include?(:header_message)

      contents = ''
      contents << content_tag(options[:header_tag] || :h2, options[:header_message]) unless options[:header_message].blank?
      contents << content_tag(:p, options[:message]) unless options[:message].blank?
      contents << content_tag(:ul, error_messages)

      content_tag(:div, contents, html)
    else
      ''
    end
  end
end
