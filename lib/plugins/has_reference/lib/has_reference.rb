# module that gather methods necessary to unique reference number
# generation for the the models which implements it. 
# the model need an attribute +reference+
#
module HasReference

  class << self
    def included(base) #:nodoc:
      base.extend ClassMethods
    end
  end

  module ClassMethods

    AUTHORIZED_OPTIONS = [:symbols, :prefix]    
    
    def has_reference(options = {})
      # check options
      options.keys.each do |option|
        message = "[has_reference] (#{self.class.name}) Unknown option :#{option.to_s}, option should be included in (#{AUTHORIZED_OPTIONS.join(', ')})"
        raise ArgumentError, message unless AUTHORIZED_OPTIONS.include?(option)
      end
      
      options[:symbols] ||= []
      
      # prepare instance variables
      class_eval do
        include InstanceMethods
        
        attr_accessor   :sequence_number_limit
        cattr_accessor  :prefix_reference, :pattern, :pattern_updated_at, :pattern_key
        
        validates_uniqueness_of :reference, :unless => Proc.new{ |x| x.reference_was.nil? }
        
        validates_persistence_of :reference, :if => :reference_was
        
        validate :validates_not_reached_sequence_number_limit
        
        pattern_key   = "#{options[:prefix]}_#{self.to_s.tableize.singularize}_reference_pattern"
        configuration = Configuration.last(:conditions => ["name = ?", pattern_key])
        
        raise "[has_reference] (#{self.class.name}) pattern's configuration is not present in database (searching '#{pattern_key}' in 'configurations' table)" unless configuration # OPTIMIZE change the error type
        
        const_set 'SYMBOLS', options[:symbols]
        self.prefix_reference   = options[:prefix]
        self.pattern_key        = pattern_key
        self.pattern            = configuration.value
        self.pattern_updated_at = configuration.created_at
        
        true
      end
    end
  end
  
  module InstanceMethods  
    
    # Method to generate unique reference according to the calling model
    # the calling model must have a configured pattern into sales/config.yml
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
    #  - Sequence number will auto increment until the pattern is modified
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
    #  $MODEL - +MODEL+ model name tableized and singularized (TestModel -> $test_model)
    #
    #  Description:
    #  - +MODEL+ must respond to :reference
    #  - Calling class must :have_one +MODEL+
    #  - Custom symbols that doesn't respect previous rules will be ignored
    #
    #   === example
    #   pattern = "$good_model"
    #   # => good_model.reference
    #   pattern = "$bad_model"
    #   # => "$bad_model"
    #
    def generate_reference
      self.sequence_number_limit = nil
      
      pattern = update_pattern_value
      raise "pattern should be defined for #{self.class.to_s} into config.yml" if pattern.nil?
      
      pattern_with_strftime = DateTime.now.strftime(pattern)
      pattern_with_symbols  = match_symbols(pattern_with_strftime)
      reference             = pattern_with_symbols ? get_number(pattern_with_symbols) : nil
      
      return reference
    end
    
    def update_reference
      self.reference = generate_reference
    end
    
    # Method to update the accessor +custom_pattern+
    # set +pattern_updated_at+ at nil to force keep custom pattern value
    #
    def update_pattern_value
      configuration = Configuration.last(:conditions => ["name = ?", self.pattern_key])
      
      if configuration.created_at != self.class.pattern_updated_at
        self.class.pattern            = configuration.value
        self.class.pattern_updated_at = configuration.created_at
      end
      
      self.class.pattern
    end
    
    def reference_or_id
      reference || "##{self[:id]}"
    end
    
    private
      def validates_not_reached_sequence_number_limit
        errors.add(:reference, "La limite du numéro de séquence a été atteinte (#{sequence_number_limit})") unless sequence_number_limit.nil?
      end
    
      # Method to generate a unique number that will increment based on the rest of the pattern
      #  until the pattern persit the number increase, and when it change the number restart from 0.
      # Must be the last called.
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
        
        if (number + 1).to_s.size > number_option
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
      # obj.match_symbols('$orderTT.number(3).$toto') #=> for obj.order.reference == 'DV01' and obj.toto = undefined
      #  #=> 'DVO1TT.$number(3).$toto'
      #
      # return the modified pattern in two part
      #   
      def match_symbols(pattern)
        raise "[has_reference] #{self.class.name} expected to have a SYMBOLS constant defined" unless self.class::SYMBOLS
        return pattern if self.class::SYMBOLS.empty?
        
        result = pattern
        
        self.class::SYMBOLS.each do |symbol|
          if self.respond_to?(symbol)
            return unless self.send(symbol)
            raise "[has_reference] instance of '#{symbol}' expected to respond_to :reference (#{self.send(symbol).inspect})" unless self.send(symbol).respond_to?(:reference)
            
            result = result.gsub(Regexp.new("\\x24#{symbol.to_s}"), self.send(symbol).reference || '')
          else
            raise "[has_reference] instance of #{self.class.name} expected to respond_to '#{symbol}'"
          end
        end
        return result
      end
      
      # The same as 'match_symbols' but with dynamic +symbol+ retrievement
      #
      ## works but not used
      #
#     def match_all_symbols(pattern)
#       result = pattern
#       
#         pattern.split(/\x24/).each do |text|
#           next if text.match(/number\x28[0-9]*\x29/) or text.empty?
#           
#           (0...text.size).each do |i|
#             word = text[0..i]
#             if self.respond_to?(word) and self.send(word).respond_to?(:reference)
#               result = result.gsub(Regexp.new("\\x24#{word}"), self.send(word).reference || '')
#             end
#           end
#         end
#       
#       return result
#     end
  end
end

# Set it all up.
if Object.const_defined?("ActiveRecord")
  ActiveRecord::Base.send(:include, HasReference)
end
