module I18n
  class << self
    
    # Add support of boolean translation when giving a boolean to the method #translate
    # You have to configure your locale files like that :
    # 
    # en:
    #   boolean_true: "Yes"
    #   boolean_false: "No"
    #
    # fr:
    #   boolean_true: "Oui"
    #   boolean_false: "Non"
    #
    def translate_with_boolean_support(*args)
      if args.first.is_a?(TrueClass) || args.first.is_a?(FalseClass)
        value = "boolean_#{args.shift}"
        translate_without_boolean_support(value, *args) # t('boolean_true') or t('boolean_false') instead of t('true') or t('false') which fail
      else
        translate_without_boolean_support(*args)
      end
      
    end
    
    alias_method_chain :translate, :boolean_support
  end
end
