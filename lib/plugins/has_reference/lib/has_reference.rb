# module that gather methods necessary to unique reference number
# generation for the the models which implements it. 
#
module HasReference

  class << self
    def included(base) #:nodoc:
#      base.class_eval do
#        validate :validates_not_reached_sequence_number_limit
#      end
      base.extend ClassMethods
    end
  end

  module ClassMethods

    AUTHORIZED_OPTIONS = [:symbols, :prefix]    
    
    def has_reference(options = {})
      # check options
      options.keys.each do |option|
        raise ArgumentError, "Unknown option :#{option.to_s}, option should be included in (#{AUTHORIZED_OPTIONS.join(', ')})" unless AUTHORIZED_OPTIONS.include?(option)
      end
      
      # prepare instance variables
      class_eval do
        include InstanceMethods
        
        attr_accessor :sequence_number_limit
        cattr_accessor :prefix
        validate :validates_not_reached_sequence_number_limit
        
        const_set 'SYMBOLS', options[:symbols]
        self.prefix = options[:prefix]
        
        true
      end
      
    end
  end
  
  module InstanceMethods  
  
    def validates_not_reached_sequence_number_limit
      errors.add(:reference, "La limite du numéro de séquence a été atteinte (#{sequence_number_limit})") unless sequence_number_limit.nil?
    end
  
    # Method to generate a unique number that will increment based on the rest of the pattern
    # until the pattern persit the number increase, and when it change the number restart from 0
    # must be the last called
    #
    def get_number(pattern)
      regexp = /\x24number\x28[0-9]*\x29/                             # $number([0-9]*)
      return pattern unless pattern.match(regexp)
      
      number_symbol = pattern.match(regexp).to_s
      number_option = extract_option(number_symbol, /\x24number\x28/, /\x29/)
      
      splitted_pattern = pattern.split(regexp)
      
      first_part  = splitted_pattern.first            || ''
      second_part = splitted_pattern.drop(1).join('') || ''
      
      objects = self.class.all(:conditions => ['reference REGEXP ?', "^#{first_part}[0-9]{#{number_option}}#{second_part}$"])
      
      number = objects.collect{|n| extract_option(n.reference, first_part, second_part) }.max || 0
      
      if (number + 1).to_s.rjust(number_option, '0').size > number_option
        self.sequence_number_limit = number
      else
        number += 1
      end
      
      return "#{first_part}#{number.to_s.rjust(number_option, '0')}#{second_part}"
    end
    
    # Method to extract "i" from "$number(i)"
    #
    def extract_option(text, first_part, second_part)
      text.gsub(first_part,'').gsub(second_part,'').to_i
    end
    
    # method to replace a symbol by his corresponding reference:
    #
    # === example
    #
    # $order   = obj.order.reference => obj respond to order AND order have a reference
    # $nothing = $nothing            => obj do not respond to nothing OR do not have a reference
    #
    # obj.match_all_symbols('$orderTT.number(3).$toto') #=> for obj.order.reference == 'DV01' and obj.toto = undefined
    #  #=> 'DVO1TT.$number(3).$toto'
    #
    # return the modified pattern in two part
    def match_all_symbols(pattern)
      result = pattern
      
        pattern.split(/\x24/).each do |text|
          next if text.match(/number\x28[0-9]*\x29/) or text.empty?
          
          (1...text.size).each do |i|
            word = text[0..i]
            if self.respond_to?(word) and self.send(word).respond_to?(:reference)
              result = result.gsub(Regexp.new("\\x24#{word}"), self.send(word).reference || '')
            end
          end
        end
      
      return result
    end
    
    def match_symbols(pattern)
      return pattern unless self.class.const_defined?("SYMBOLS")
      
      result = pattern
      self.class::SYMBOLS.each do |symbol|
        if self.respond_to?(symbol.to_s) and self.send(symbol.to_s).respond_to?(:reference)
          result = result.gsub(Regexp.new("\\x24#{symbol.to_s}"), self.send(symbol.to_s).reference || '')
        end
      end
      return result
    end

    # Method to generate unique reference according to the calling model
    # the calling model must have a configured patter into sales/config.yml
    #
    # === Options :
    #
    ## strftime formats symbols :
    #
    #  %d - Day of the month (01..31)
    #  %m - Month of the year (01..12)
    #  %Y - Year with century
    #
    #  Description:
    #  - more on http://apidock.com/ruby/Time/strftime?q=strftime
    #
    #   === example 
    #   pattern = "%d/%m/%Y"
    #   # => "09/12/2012"  (according to DateTime.now) 
    #
    ## Sequence number with auto increment :
    # 
    #  $number(+size+) - +size+ --> [0-9]*
    #  
    #  Description:
    #  - Will be processed only once, all the duplicates will be ignored.
    #  - Sequence number wil auto increment until the pattern is modified
    #
    #   === example
    #   pattern = "N-$number(2)" and the object is the 1st to generate a reference with that pattern
    #   # =>  "N-01"
    #   pattern = "N-$number(2)" and the object is the 100th to generate a reference with that pattern
    #   # =>  "N-99" it will not overstep +size+ limit and the object will not be able to be saved
    #   pattern = "N-$number(5)" and the object is the 2nd to generate a reference with that pattern
    #   # =>  "N-00002"
    #
    ## Custom symbol :
    #  $MODEL - +MODEL+ model name tableized and singlarized (TestModel -> $test_model)
    #
    #  Description:
    #  - +MODEL+ must respond to :reference
    #  - Calling model must have one +MODEL+
    #  - Custom symbols that doesn't respect previous rules will be ignored
    #
    #   === example
    #   pattern = "$good_model"
    #   # => "good_model_reference"
    #   pattern = "$bad_model"
    #   # => "$bad_model"
    #
    def generate_reference
      self.sequence_number_limit = nil
      
      pattern = ConfigurationManager.send("#{self.prefix.to_s}_#{self.class.to_s.tableize.singularize}_reference_pattern")
      raise "pattern should be defined for #{self.class.to_s} into config.yml" if pattern.nil?
      
      pattern_with_strftime = DateTime.now.strftime(pattern)
      pattern_with_symbols  = match_symbols(pattern_with_strftime)
      reference             = get_number(pattern_with_symbols)
      
      return reference
    end
  end
end

# Set it all up.
if Object.const_defined?("ActiveRecord")
  ActiveRecord::Base.send(:include, HasReference)
end
