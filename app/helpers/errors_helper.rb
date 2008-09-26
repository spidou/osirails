# hack for customize error messages
module ErrorsHelper
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
      options[:header_message] = "#{pluralize(count, 'erreur est survenue', 'erreurs sont survenues')} lors de la sauvegarde" unless options.include?(:header_message)
      unless options.include?(:message)
        options[:message] ||= count > 1 ? 'Les champs suivants ne sont pas valides :' : "Le champ suivant n'est pas valide :"
      end
      error_messages = objects.map {|object| object.errors.full_messages.map {|msg| content_tag(:li, msg) } }

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
