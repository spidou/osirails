module Shoulda # :nodoc:
  module ActiveRecord # :nodoc:
    module Macros
      ### This is an override of a method of the plugin thoughtbot-shoulda
      ### see in vendor/gems/thoughtbot-shoulda-2.10.2/lib/shoulda/active_record/macros.rb
      #
      # Ensures that the model cannot be saved if one of the attributes listed is not present.
      #
      # Options:
      # * <tt>:message</tt> - value the test expects to find in <tt>errors.on(:attribute)</tt>.
      #   Regexp or string.  Default = <tt>I18n.translate('activerecord.errors.messages.blank')</tt>
      #
      # * <tt>:foreign_key</tt> - if a foreign_key is given, it will also be tested.
      #   If the symbol <tt>:default</tt> is given, the foreign_key is guessed by suffixing '_id' to the attribute
      #
      # Example:
      #   should_validate_presence_of :name, :phone_number
      #   should_validate_presence_of :user, :foreign_key => :user_id
      #   should_validate_presence_of :user, :foreign_key => :default
      #
      def should_validate_presence_of(*attributes)
        message, foreign_key = get_options!(attributes, :message, :with_foreign_key)
        
        attributes.each do |attribute|
          matcher = validate_presence_of(attribute).with_message(message)
          should matcher.description do
            assert_accepts(matcher, subject)
          end
          
          if foreign_key
            attribute = ( foreign_key == :default ) ? "#{attribute}_id".to_sym : foreign_key
            matcher = validate_presence_of(attribute).with_message(message)
            should matcher.description do
              assert_accepts(matcher, subject)
            end
          end
        end
      end
      
    end
  end
end
