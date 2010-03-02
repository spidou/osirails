require File.dirname(__FILE__) +  '/../../../../../test/fixtures/reference_generator' # add mock class

module HasReferenceTest
  
  # this module shoul be implemented into the calling classe's test suite
  #
  #
  # SAMPLE
  #
  #  context "generate a reference" do
  #    setup do
  #      @reference_owner       = ... 
  #      @other_reference_owner = ...
  #    end
  #    
  #    include HasReferenceTest
  #  end
  #
  # ==== example
  #
  # for Quote into "quote_test.rb"
  #
  #  context "generate a reference" do
  #    setup do
  #      @reference_owner       = create_default_quote  # the method 'create_default_quote' return a valid instance of Quote 
  #      @other_reference_owner = create_default_quote
  #    end
  #    
  #    include HasReferenceTest
  #  end
  #
  #  
  #  @reference_owner and @other_reference_owner should: 
  #  - be the only one variable depending on the calling class
  #  - retrun a valid instance of the calling class
  #
  class << self
    def included base
      base.class_eval do
        
        context "for @reference_owner" do # this is just for declare specific setup and teardown
          setup do
            flunk "@reference_owner and @other_reference_owner should exist" unless @reference_owner and @other_reference_owner
            get_original_pattern
          end
          
          teardown do
            reset_pattern
          end
          
          #TODO find another way to test this plugin, because the method set_pattern change de configuration for all the following tests, and this is very embarassing
          # the method +reset_pattern+ should restore the original pattern, but it doesn't work. we have to find a way to restore the original value of the configuration before uncomment all these tests
          
          #context "with pattern containing only strftime symbols" do
          #  
          #  setup do
          #    @pattern = "%d/%m/%y"
          #    set_pattern(@pattern)
          #  end
          #  
          #  should "respect pattern" do
          #    assert_equal DateTime.now.strftime(@pattern), @reference_owner.generate_reference
          #  end
          #  
          #end
          
          context "with pattern containing only $number(OPTION)," do
          
            #context "when pattern do not change," do
            #  setup do
            #    @pattern = "ID$number(2)"
            #    set_pattern(@pattern)
            #  end
            #  
            #  teardown do
            #    @pattern = nil
            #  end
            #  
            #  context "and not already used by another reference owner," do
            #    
            #    should "(re)start sequence number to 1" do
            #      assert_equal "ID01", @reference_owner.generate_reference
            #    end
            #  
            #  end
            #  
            #  context "and already used by another reference owner," do
            #  
            #    setup do
            #      @other_reference_owner.update_reference
            #      @other_reference_owner.save(false) # save without validation to avoid some persitence validation failure onto reference attribute 
            #    end
            #    
            #    should "increment number" do
            #      assert_equal "ID02", @reference_owner.generate_reference
            #    end
            #    
            #  end
            #end
            
            #context "when $number is in the middle and modifying pattern's end," do
            #  setup do
            #    @other_reference_owner.reference = "[before]10[after]"
            #    @pattern = "[before]$number(2)[changed_after]"
            #    set_pattern(@pattern)
            #  end
            #  
            #  should "restart sequence number to 1" do
            #    assert_equal "[before]01[changed_after]", @reference_owner.generate_reference
            #  end
            #end
            
            #context "when removing pattern's end after $number," do
            #  setup do
            #    @other_reference_owner.reference = "[before]10[after]"
            #    @pattern = "[before]$number(2)"
            #    set_pattern(@pattern)
            #  end
            #  
            #  should "restart sequence number to 1" do
            #    assert_equal "[before]01", @reference_owner.generate_reference
            #  end
            #end
            
            #context "when $number() is in the middle and modifying pattern's beginning," do
            #  setup do
            #    @other_reference_owner.reference = "[before]10[after]"
            #    @pattern = "[changed_before]$number(2)[after]"
            #    set_pattern(@pattern)
            #  end
            #  
            #  should "restart sequence number to 1" do
            #    assert_equal "[changed_before]01[after]", @reference_owner.generate_reference
            #  end
            #end
            
            #context "when removing pattern's beginning before $number," do
            #  setup do
            #    @other_reference_owner.reference = "[before]10[after]"
            #    @pattern = "$number(2)[after]"
            #    set_pattern(@pattern)
            #  end
            #  
            #  should "restart sequence number to 1" do
            #    assert_equal "01[after]", @reference_owner.generate_reference
            #  end
            #end
            
            #context "when OPTION reaching his limit," do
            #  
            #  setup do
            #    @other_reference_owner.reference = '9'
            #    @other_reference_owner.save(false) # save without validation to avoid some persitence validation failure onto reference attribute 
            #    
            #    @pattern = "$number(1)"
            #    set_pattern(@pattern)
            #  end
            #  
            #  should "not increment more" do
            #    assert_equal '9', @reference_owner.generate_reference
            #  end
            #  
            #  should "be invalid with the good error message" do
            #    @reference_owner.update_reference
            #    @reference_owner.valid?
            #    assert @reference_owner.errors.invalid?(:reference)
            #    assert !@reference_owner.errors.on(:reference).to_a.collect {|n| n.match(/La limite du numéro de séquence a été atteinte ([0-9]*)/)}.empty?
            #  end
            #end
            
            #context "when the first reference owner have a greater sequence number than the last one," do
            #  
            #  setup do
            #    @reference_owner.reference = '5'
            #    @reference_owner.save(false) # save without validation to avoid some persitence validation failure onto reference attribute 
            #    
            #    @other_reference_owner.reference = '1'
            #    @reference_owner.save(false) # save without validation to avoid some persitence validation failure onto reference attribute 
            #    
            #    @pattern = "$number(1)"
            #    set_pattern(@pattern)
            #  end
            #  
            #  should "increment according to the greatest sequence number" do
            #    assert_equal '6', @reference_owner.generate_reference
            #  end
            #end
            
          end
          
          #context "with pattern containing custom symbols" do
          #
          #  setup do
          #    @reference_owner.class.class_eval do
          #      silence_warnings { const_set 'SYMBOLS', [:reference_generator] }
          #      def reference_generator
          #        r = ReferenceGenerator.new
          #        r.reference = "pattern_test"
          #        r
          #      end
          #    end
          #    
          #    @pattern = "$reference_generator"
          #    set_pattern(@pattern)
          #  end
          #  
          #  should "respect pattern" do
          #    assert_equal @reference_owner.reference_generator.reference , @reference_owner.generate_reference
          #  end
          #end
          
          #context "with pattern containing custom symbols returning nil reference" do
          #
          #  setup do
          #    @reference_owner.class.class_eval do
          #      silence_warnings { const_set 'SYMBOLS', [:reference_generator] }
          #      def reference_generator
          #        r = ReferenceGenerator.new
          #        r.reference = nil
          #        r
          #      end
          #    end
          #    
          #    @pattern = "$reference_generator"
          #    set_pattern(@pattern)
          #  end
          #  
          #  should "return reference without custom symbol" do
          #    assert_equal '', @reference_owner.generate_reference
          #  end
          #end
          
          #context "with pattern containing undefined custom symbols " do
          #  setup do
          #    @pattern = "$undefined_symbol"
          #    set_pattern(@pattern)
          #  end
          #  
          #  teardown do
          #    @pattern = nil
          #  end
          #  
          #  should "respect pattern" do
          #    assert_equal @pattern, @reference_owner.generate_reference
          #  end
          #end
          
          #context "with nil pattern" do
          #  setup do
          #    set_pattern(nil)
          #  end
          #  
          #  should "raise an error" do
          #    assert_raise(RuntimeError) { @reference_owner.generate_reference }
          #  end
          #end
        end
      end
    end
  end
  
  private
    
    def get_original_pattern
      klass = @reference_owner.class
      prefix = klass.prefix_reference
      method = "#{prefix}_#{klass.to_s.underscore}_reference_pattern"
      @original_pattern = ConfigurationManager.send(method)
    end
    
    def set_pattern(pattern)
      klass = @reference_owner.class
      prefix = klass.prefix_reference
      method = "#{prefix}_#{klass.to_s.underscore}_reference_pattern"
      
      ConfigurationManager.send("#{method}=", pattern)
      flunk "failed to set configuration for key = '#{method}' with value = '#{pattern}' (actual value = '#{ConfigurationManager.send(method)}')" unless ConfigurationManager.send(method) == pattern
    end
    
    # unset and reload the class to be sure the class keep it original pattern
    def reset_pattern
      klass = @reference_owner.class
      prefix = klass.prefix_reference
      method = "#{prefix}_#{klass.to_s.underscore}_reference_pattern"
      
      ConfigurationManager.send("#{method}=", @original_pattern)
      flunk "failed to restore configuration for key = '#{method}' with value = '#{@original_pattern}' (actual value = '#{ConfigurationManager.send(method)}')" unless ConfigurationManager.send(method) == @original_pattern
    end
end
