require 'modules/plugin_private_class_methods'
require 'modules/plugin_restricted_methods'
require 'modules/plugin_yaml_configuration_validation'
require 'modules/plugin_implementation_validation'

module HasSearchIndex
   
  MODELS       = []
  HTML_PAGES_OPTIONS = {}
  ACTIONS_TEXT = { '='        => 'est égal à',#"is ",
                   '!='       => 'est différent de',#"is not ",
                   'like'     => 'contient',#"is like",
                   'not like' => 'ne contient pas',#"is not like",
                   '>='       => 'est plus grand ou égal à',#"is greater to equal than",
                   '<='       => 'est plus petit ou égal à',#"is smaller to equal than",
                   '<'        => 'est plus petit que',#"is smaller than",
                   '>'        => 'est plus grand que' }#"is greater than" }
                   
  ACTIONS      = {:string   => string = [ "like", "not like", "=", "!=" ],
                  :text     => string,
                  :binary   => string,
                  :integer  => integer = [ ">=", "<=", ">", "<", "=", "!=" ],
                  :date     => integer,
                  :datetime => integer,
                  :decimal  => integer,
                  :float    => integer,
                  :boolean  => [ "=", "!=" ] }
                  
  class << self
    def included base #:nodoc:
      base.extend ClassMethods
    end
  end

  module ClassMethods
    include ActiveRecord::ConnectionAdapters::DatabaseStatements                          # Used by method 'check_relationships_options'
    include PrivateClassMethods
    include ImplementationValidation
    
    AUTHORIZED_OPTIONS = [ :except_attributes, :only_attributes, :additional_attributes, :identifier,
                           :except_relationships, :only_relationships ]
    
    # Method called into all models that implement the plugin,
    # it define search_index class variable based on passed options hash
    #
    # Look above at AUTHORIZED_OPTIONS to view all possible options.
    #
    ##  except_*              => Means all except specified.
    #
    ##  only_*                => Means only specified.
    #
    ##  *_attributes          => Permit to define (database) attributes that can be criteria.
    #                            It must be an Array of Symbols or Strings:
    #                            - [:attribut1, 'attribut2']
    #
    #   *_relationships       => Permit to define (database) relationship to use nested attribute as criteria.
    #                            It must be an Array of Symbols or Strings:
    #                            - [:relationship_1, :relationship2]
    #                            - ['relationship', :relationship]
    #
    ##  additional_attributes => Permit to define attributes that are not table columns, like accessors or even methods (if they return something).
    #                            PS: be carrefull with that kind of attributes because the search's treatments is performed by ruby and it 's not
    #                                as efficient as sql engine.
    #                            It must be an Hash:
    #                            - {:ATTRIBUTE => TYPE}  ATTRIBUTE should return a TYPE object (look at ACTIONS above to see the available types).
    #                            - {:full_name => string}
    #
    #   identifier            => permit to define how to display the object.
    #                         example ===
    #                            Employees.has_search_index(:identifier => :last_name)
    #                            Employee.last will be displayed like Employee.last.send(:last_name)
    #
    def has_search_index( options = {} )
      error_prefix = "(has_search_index) model: #{self} >"
      const_set 'ERROR_PREFIX', error_prefix unless const_defined?('ERROR_PREFIX')
      
      # Remember that the model implement the plugin
      (HasSearchIndex::MODELS << self.to_s).uniq!
      
      options[:additional_attributes] ||={}
      options[:only_attributes]       ||=[]
      options[:except_attributes]     ||=[]
      options[:except_relationships]  ||=[]
      options[:only_relationships]    ||=[]

      # Check options arg for some errors
      options.keys.each do |key|
        raise ArgumentError, "#{error_prefix} Unknown option :#{key.to_s}" unless AUTHORIZED_OPTIONS.include?(key)      
      end
      
      # Check & prepare relationshsips
      options[:relationships] = get_relationships_from_options(options, error_prefix)
      options.delete(:except_relationships)
#      options.delete(:only_relationships)                                              # Do not delete that option because it is used into +reflect_relationship+ method
      
      # Check & prepare attributes
      options[:attributes] = get_attributes_from_options(options, error_prefix)
      options.delete(:except_attributes)
      options.delete(:only_attributes)
      
      #DELETEME This feature has been commented because it doesn't seem to take in account
      #         methods which are defined after the call of 'has_search_index' in the model.
      #         So, for now, if the method doesn't exist, we will have an error
      #         on running instead of on starting up server.
      # Check identifer # TODO test
      # message  = "#{ error_prefix } :identifier is wrong: "
      # message += "expected to be a valid method or attribute"
      # raise ArgumentError, message unless self.respond_to?(options[:identifier]) if options[:identifier]
      
      # Prepare additional_attributes
      message  = "#{error_prefix} :additional_attributes is wrong: "
      message += "Expected Hash but was '#{options[:additional_attributes].inspect}':#{options[:additional_attributes].class.to_s}"
      raise ArgumentError, message unless options[:additional_attributes].is_a?(Hash)
      options[:additional_attributes].each { |k, v| options[:additional_attributes][k] =  v.to_s }.stringify_keys!
      
      check_relationships_for_sql_options_support(options[:relationships])
      
      # Create class var to permit to access to search option from te model
      class_eval do
        cattr_accessor :search_index
        silence_warnings { const_set( 'SEARCH_INDEX', {}.merge(options)) }                # get all attributes and relationships configured into the plugin
        self.extend RestrictedMethods                                                    # Class method that are defined for Models that implement the plugin
      end
      
      def self.search_index
        self::SEARCH_INDEX
      end
    end
   
  end
  
end

# Set it all up.
if Object.const_defined?("ActiveRecord")
  ActiveRecord::Base.send(:include, HasSearchIndex)
end
