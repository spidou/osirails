module ActionView
  module Helpers
    module TextHelper
      # Source: https://rails.lighthouseapp.com/projects/8994-ruby-on-rails/tickets/3593-patch-support-for-highlighting-with-ignoring-special-chars
    
      # Highlights one or more +phrases+ everywhere in +text+ by inserting it into
      # a <tt>:highlighter</tt> string. The highlighter can be specialized by passing <tt>:highlighter</tt>
      # as a single-quoted string with \1 where the phrase is to be inserted (defaults to
      # '<strong class="highlight">\1</strong>')
      #
      # ==== Examples
      #   highlight('You searched for: rails', 'rails')
      #   # => You searched for: <strong class="highlight">rails</strong>
      #
      #   highlight('You searched for: ruby, rails, dhh', 'actionpack')
      #   # => You searched for: ruby, rails, dhh
      #
      #   highlight('You searched for: rails', ['for', 'rails'], :highlighter => '<em>\1</em>')
      #   # => You searched <em>for</em>: <em>rails</em>
      #
      #   highlight('You searched for: rails', 'rails', :highlighter => '<a href="search?q=\1">\1</a>')
      #   # => You searched for: <a href="search?q=rails">rails</a>
      #
      #   highlight('Šumné dievčatá', ['šumňe', 'dievca'], :ignore_special_chars => true)
      #   # => <strong class="highlight">Šumné</strong> <strong class="highlight">dievča</strong>tá  
      #
      # You can still use <tt>highlight</tt> with the old API that accepts the
      # +highlighter+ as its optional third parameter:
      #   highlight('You searched for: rails', 'rails', '<a href="search?q=\1">\1</a>')     # => You searched for: <a href="search?q=rails">rails</a>
      def highlight(text, phrases, *args)
        options = args.extract_options!
        unless args.empty?
          options[:highlighter] = args[0] || '<strong class="highlight">\1</strong>'
        end
        options.reverse_merge!(:highlighter => '<strong class="highlight">\1</strong>')

        if text.blank? || phrases.blank?
          text
        else
          haystack = text.clone
          match = Array(phrases).map { |p| Regexp.escape(p) }.join('|')
          if options[:ignore_special_chars]
            haystack = haystack.mb_chars.normalize(:kd) 
            match = match.mb_chars.normalize(:kd).gsub(/[^\x00-\x7F]+/n, '').gsub(/\w/, '\0[^\x00-\x7F]*')
          end
          highlighted = haystack.gsub(/(#{match})(?!(?:[^<]*?)(?:["'])[^<>]*>)/i, options[:highlighter])
          highlighted = highlighted.mb_chars.normalize(:kc) if options[:ignore_special_chars]
          highlighted
        end
      end
    end
  end
end
