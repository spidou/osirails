# overrides for the validates_timeliness plugin
# http://github.com/adzap/validates_timeliness/tree/master
#OPTIMIZE (see that page when we'll use rails 2.2+ l18n system)

#TODO see that page when we'll use rails 2.2+ l18n system
if Object.const_defined?("ValidatesTimeliness")
  
  ValidatesTimeliness::Validator.error_value_formats.update(
    :time     => '%H:%M:%S',
    :date     => '%d %B %Y',
    :datetime => '%d %B %Y à %H:%M:%S'
  )
  
  # When using the validation temporal restrictions there are times when the restriction value 
  # itself may be invalid. Normally this will add an error to the model such as 
  # ‘restriction :before value was invalid’. These can be annoying if you are using procs or methods
  # as restrictions and don’t care if they don’t evaluate properly and you want the validation to 
  # complete. In these situations you turn them off.
  # To turn them off:
  # ValidatesTimeliness::Validator.ignore_restriction_errors = true
  
  # The plugin has some extensions to ActionView and ActiveRecord by allowing invalid date and time 
  # values to be redisplayed to the user as feedback, instead of a blank field which happens 
  # by default in Rails. Though the date helpers make this a pretty rare occurence, given the select
  # dropdowns for each date/time component, but it may be something of interest. 
  # To activate it, put this in an initializer: 
  # ValidatesTimeliness.enable_datetime_select_extension!
end

module ActiveRecord
  class Errors
    @@default_error_messages.update( {
      :invalid_date     => "n'est pas une date valide",   # "is not a valid date",
      :invalid_time     => "n'est pas une heure valide",  # "is not a valid time",
      :invalid_datetime => "n'est pas une date valide",   # "is not a valid datetime",
      :before           => "doit être avant %s",          # "must be before %s",
      :on_or_before     => "doit être égal ou avant %s",  # "must be on or before %s",
      :after            => "doit être après %s",          # "must be after %s",
      :on_or_after      => "doit être égal ou après %s",  # "must be on or after %s",
      :between          => "doit être entre %s et %s",    # "must be between %s and %s"
    })
  end
end
