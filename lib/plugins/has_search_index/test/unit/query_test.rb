require File.join(File.dirname(__FILE__), '..', 'test_helper')

class QueryTest < ActiveRecordTestCase
  fixtures :users
  
  should_belong_to(:creator)
  should_validate_presence_of(:name, :page_name, :columns)
  should_allow_values_for(:search_type, 'and', 'or', 'not')
  should_allow_values_for(:public_access, false, true)
  should_validate_presence_of(:creator, :with_foreign_key => :default)
  
  context "" do # context to setup some constant for testing purposes
    setup do
      silence_warnings { HasSearchIndex::HTML_PAGES_OPTIONS = { :person => {:columns => ['name'], :model => 'Person'} } }
    end
    
    context "A new query" do
      setup do
        @query = build_query
      end
      
      teardown do
        @query = nil
      end
      
      context "with a page_configuration for :criteria" do
        setup do
          HasSearchIndex::HTML_PAGES_OPTIONS[:person][:filters] = ['id']
        end

        should "validate :filters" do
          assert @query.should_validate?(:filters)
        end
        
        context "with :criteria has valid content" do
          setup do
            @query.criteria = {'id' => [ {:action => ">", :value => 0}, {:action => "=", :value => "value"}]}
          end
          
          should "be valid" do
            assert @query.valid?
          end
        end
        
        context "with :criteria has invalid content" do
          setup do
            @query.criteria = {'undefined_attribute' => [ "value", {:aktion => "=", :valu => "value"}]}
          end
          
          should "be invalid and have error on :criteria" do
            assert !@query.valid? && @query.errors.invalid?(:criteria)
          end
        end
        
        context "with :criteria is not a Hash" do
          setup do
            @query.criteria = []
          end

          should "be invalid and have error on :criteria" do
            assert !@query.valid? && @query.errors.invalid?(:criteria)
          end
        end
      end
      
      context "with a page_configuration for :order" do
        setup do
          HasSearchIndex::HTML_PAGES_OPTIONS[:person][:order] = ['id']
        end
        
        context "that has valid valid content" do
          setup do
            @query.order = ['id:desc']
          end
            
          should "be valid" do
            assert @query.valid?
          end
        end
        
        context "that do not contain order" do
          setup do
            @query.order =  ["id"]
          end
            
          should "be invalid and have error on :order" do
            assert !@query.valid? && @query.errors.invalid?(:order)
          end
        end
        
        context "that do not contain order in (:desc, :asc)" do
          setup do
            @query.order =  ["id:down"]
          end
            
          should "be invalid and have error on :order" do
            assert !@query.valid? && @query.errors.invalid?(:order)
          end
        end
        
        context "that has invalid content" do
          setup do
            @query.order =  ["undefined_attribute:desc"]
          end
            
          should "be invalid and have error on :order" do
            assert !@query.valid? && @query.errors.invalid?(:order)
          end
        end
      end
      
      context "with a page_configuration for :group" do
        setup do
          HasSearchIndex::HTML_PAGES_OPTIONS[:person][:group] = ['id']
        end
        
        context "that has valid valid content" do
          setup do
            @query.group =  ['id']
          end
            
          should "be valid" do
            assert @query.valid?
          end
        end
        
        context "that has invalid content" do
          setup do
            @query.group = ["undefined attribute"]
          end
            
          should "be invalid and have error on :group" do
            assert !@query.valid? && @query.errors.invalid?(:group)
          end
        end
      end
      
      [:group, :order].each do |option|
        context "with a page_configuration for :#{ option }" do
          setup do
            HasSearchIndex::HTML_PAGES_OPTIONS[:person][option] = ['id']
          end
          
          should "validate :#{ option }" do
            assert @query.should_validate?(option)
          end 
          
          context "that is not an Array" do
            setup do
              @query.send("#{option}=", "wrong type")
            end
                
            should "be invalid and have error on :#{ option }" do
              assert !@query.valid? && @query.errors.invalid?(option)
            end
          end 
        end
      end
      
      context "with a page_configuration for :per_page" do
        setup do
          HasSearchIndex::HTML_PAGES_OPTIONS[:person][:per_page] = [10, 20, 30]
        end
        
        should "validate :per_page" do
          assert @query.should_validate?(:per_page)
        end

        context "and :per_page has valid content" do
          setup do
            @query.per_page = [10]
          end
          
          should "be valid" do
            assert @query.valid?
          end 
        end
        
        context "and :per_page has invalid content" do
          setup do
            @query.per_page = ["undefined attribute"]
          end
          
          should "be invalid and have error on :per_page" do
            assert !@query.valid? && @query.errors.invalid?(:per_page)
          end
        end
        
        context "and :per_page is not an Array" do
          setup do
            @query.per_page = "wrong attribute"
          end
          
          should "be invalid and have error on :per_page" do
            assert !@query.valid? && @query.errors.invalid?(:per_page)
          end
        end
      end
      
      [:criteria, :order, :group].each do |option|
        context "without a page_configuration for :#{ option }" do
          
          should "not validate :#{ option }" do
            assert !@query.should_validate?(option)
          end
        end
      end
    end
    
    context "A query" do
      setup do
        @query = create_query
      end
      
      teardown do
        @query = nil
      end
      
      should "be valid" do
        assert @query.valid?
      end
      
      should "save" do
        assert @query.save
      end
      
      should "know the subject model" do
        assert_not_nil @query.subject_model
      end
      
      context "that is invalid" do
        setup do
          @query = Query.new
          flunk "@query should be invalid" if @query.valid?
        end
        
        should "fail to save" do
          assert !@query.save
        end
      end
      
      context "with :page_name is modified" do
        setup do
          @query.page_name = "another name"
        end
        
        should "be invalid and have error on page_name" do
          assert !@query.valid? && @query.errors.invalid?(:page_name)
        end
      end
      
      context "with :page_name is not a String" do
        setup do
          @query.page_name = :not_a_string
        end
        
        should "be invalid and have error on page_name" do
          assert !@query.valid? && @query.errors.invalid?(:page_name)
        end
      end
      
      context "that is not public" do
        setup do
          @query.public_access = 0   
        end
        
        should "not appear to be public" do
          assert !@query.is_public?
        end
      end
      
      context "performing a search" do
        setup do
          Person.has_search_index :only_attributes => ['name']
          flunk "Person should be created" unless Person.create(:name => 'ernesta', :age => 30)
          
          @expected_result = Person.search_with("name" => {:action => "like", :value => "e"})
          @query.criteria = {"name" => {:action => "like", :value => "e"}}
        end
        
        should "return expected result" do
          assert_equal @expected_result, @query.search
        end
      end
      
      context "with a quick_search_value and with quick_search_attributes" do
        setup do
          @query.quick_search_value = "some text"
          HasSearchIndex::HTML_PAGES_OPTIONS[:person][:quick_search] = ['id']
        end
        
        should "have a quick_search_option" do
          assert_not_nil @query.quick_search_option
        end
      end
      
      context "with a quick_search_value and without quick_search_attributes" do
        setup do
          @query.quick_search_value = "some text"
        end
        
        should "not have a quick_search_option" do
          assert_nil @query.quick_search_option
        end
      end
      
      context "without a quick_search_value" do
      
        should "not have a quick_search_option" do
          assert_nil @query.quick_search_option
        end
      end
    end
    
  end
  
  private
  
    def build_query(options = {})
      raise(ArgumentError, "See build_query method's definition for more informations") if options.keys.size > 8 
      query = Query.new(
        :creator     => users(:creator),
        :name        => options[:name]        || "new query",
        :page_name   => options[:page_name]   || "person",
        :search_type => options[:search_type] || "and",
        :columns     => options[:columns]     || ['name'],
        :criteria    => options[:criteria]    || {},
        :order       => options[:order]       || [],
        :group       => options[:group]       || [],
        :per_page    => options[:per_page]    || 10,
        :public_access => options[:public_access] || true
      )
      flunk "query should be valid #{ query.errors.inspect }" unless query.valid?
      return query
    end
    
    def create_query(options = {})
      query = build_query(options)
      query.save
      return query
    end
end
