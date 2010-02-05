require File.dirname(__FILE__) +  '/../../../../../test/fixtures/reference_generator' # add mock class

module HasReferenceTest
  
  class << self
    def included base
      base.class_eval do
        
        context "with pattern containing only strftime symbols " do
          
          setup do
            @pattern = "%d/%m/%y"
            set_pattern(@pattern) 
          end
          
          should "respect pattern" do
            assert_equal DateTime.now.strftime(@pattern), @reference_owner.generate_reference
          end
          
        end
        
        context "with pattern containing only '$number()'" do
        
          context "(pattern do not change)" do
            setup do
              @pattern = "ID$number(2)"
              set_pattern(@pattern)
            end
            
            teardown do
              @pattern = nil
            end
            
            context ",and not already used by another reference owner" do
              
              should "(re)start sequence number to 1" do
                assert_equal "ID01", @reference_owner.generate_reference
              end
            
            end
            
            context ",and already used by another reference owner" do
            
              setup do
                @other_reference_owner.reference = @other_reference_owner.generate_reference
                @other_reference_owner.save
              end
              
              should "increment number" do
                assert_equal "ID02", @reference_owner.generate_reference
              end
              
            end
          end
          
          context "(change pattern after '$number()')" do
            setup do
              @other_reference_owner.reference = "10.after"
              @pattern = "$number(2).changed_after"
              set_pattern(@pattern)
            end
            
            should "restart sequence number to 1" do
              assert_equal "01.changed_after", @reference_owner.generate_reference
            end
          end
          
          context "(nothing after '$number()')" do
            setup do
              @other_reference_owner.reference = "10.after"
              @pattern = "$number(2)"
              set_pattern(@pattern)
            end
            
            should "restart sequence number to 1" do
              assert_equal "01", @reference_owner.generate_reference
            end
          end
          
          context "(change pattern before '$number()')" do
            setup do
              @other_reference_owner.reference = "before.10"
              @pattern = "changed_before.$number(2)"
              set_pattern(@pattern)
            end
            
            should "restart sequence number to 1" do
              assert_equal "changed_before.01", @reference_owner.generate_reference
            end
          end
          
          context "(nothing before '$number()')" do
            setup do
              @other_reference_owner.reference = "before.10"
              @pattern = "$number(2)"
              set_pattern(@pattern)
            end
            
            should "restart sequence number to 1" do
              assert_equal "01", @reference_owner.generate_reference
            end
          end
          
          context "('$number(option)' reaching the option limit)" do
            
            setup do
              @other_reference_owner.reference = '9'
              @other_reference_owner.save
              
              @pattern = "$number(1)"
              set_pattern(@pattern)
            end
            
            should "not imcrement more" do
              assert_equal '9', @reference_owner.generate_reference
            end
            
            should "be invalid" do
                @reference_owner.reference = @reference_owner.generate_reference
                @reference_owner.valid?
                assert @reference_owner.errors.invalid?(:reference)
            end
          end
          
          context "(the first reference owner having a greater sequence number than the last one)" do
            
            setup do
              @reference_owner.reference = '5'
              @reference_owner.save
              @other_reference_owner.reference = '1'
              @reference_owner.save
              
              @pattern = "$number(1)"
              set_pattern(@pattern)
            end
            
            should "imcrement according to the greatest sequence number" do
              assert_equal '6', @reference_owner.class.new.generate_reference
            end
          end
          
        end
        
        context "with pattern containing custom symbols" do
        
          setup do
            if @reference_owner.class.const_defined?("SYMBOLS")
              @constant_backup = @reference_owner.class::SYMBOLS
            end
            
            @reference_owner.class.class_eval do
              silence_warnings { const_set 'SYMBOLS', [:reference_generator] }
              def reference_generator
                ReferenceGenerator.new
              end
            end
            
            @pattern = "$reference_generator"
            set_pattern(@pattern)
          end
          
          teardown do
            @reference_owner.class.class_eval do
              const_set 'SYMBOLS', @constant_backup unless @constant_backup.nil?
            end
          end
          
          should "respect pattern" do
            assert_equal @reference_owner.reference_generator.reference , @reference_owner.generate_reference
          end
        end
        
        context "with pattern containing undefined custom symbols " do
          setup do
            @pattern = "$undefined_symbol"
            set_pattern(@pattern)
          end
          
          teardown do
            @pattern = nil
          end
          
          should "respect pattern" do
            assert_equal @pattern, @reference_owner.generate_reference
          end
        end
        
        context "with nil pattern" do
          setup do
            set_pattern(nil)
          end
          
          should "raise an error" do
            assert_raise(RuntimeError) { @reference_owner.generate_reference }
          end
        end
        
      end
    end
  end
  
  private
  
    def set_pattern(pattern)
      owner_class = @reference_owner.class.to_s.tableize.singularize
      prefix = @reference_owner.class.prefix
      ConfigurationManager.send("#{prefix}_#{owner_class}_reference_pattern=", pattern)
    end
end
