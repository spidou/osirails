  ############## Module required into has_search_index.rb ###########################
  ############## private methods called by +has_search_index+ method ################
  
module ImplementationValidation

  private
    
    # Method called by +has_search_index+ to check relationships configuration
    # return an Array of checked relationships from +associations+ and +options+ collection passed as arguments
    # return an empty Array if +except_relationships+ option contains :all symbol
    #
    def get_relationships_from_options(options, error_prefix)
      return [] if options[:except_relationships] == :all
      
      # Create a hash to store all associations that concern the current model
      associations = Hash.new
      self.reflect_on_all_associations.each do |association|
        associations.merge!(association.name => association) if [nil, false].include?(association.options[:polymorphic])
      end
      
      options[:relationships] = []
      
      if options[:only_relationships].empty?
        logger.warn("#{error_prefix} No relationships defined") if associations.empty?
        
        message = "#{error_prefix} Warning you must type an array or the symbol :all for :except_relationhips"
        raise ArgumentError, message unless options[:except_relationships].is_a?(Array)

        associations.each_value { |relationship| options[:relationships] << relationship.name }
        
        options[:except_relationships].each { |e| options[:relationships].delete(e) } if !options[:except_relationships].empty?
      else
        message = "#{error_prefix} Warning you must type an array for :only_relationhips"
        raise ArgumentError, message unless options[:only_relationships].is_a?(Array)
        
        message = "#{error_prefix} Warning you mustn't specify both 'only_relationships' and 'except_relationships'"
        raise ArgumentError, message unless options[:except_relationships].empty?
        
        options[:only_relationships].each do |relationship_name|
          message = "#{error_prefix} Undefined relationship '#{relationship_name}', maybe you misspelled it"
          raise ArgumentError, message if self.reflect_on_association(relationship_name).nil?
        end
        options[:relationships] = options[:only_relationships]
      end
      
      options[:relationships]
    end

    # Method called by +has_search_index+ to check attributes configuration
    # return an Hash of checked attributes according to +options+
    # return an empty Hash if +except_attributes+ option contains :all symbol
    #
    def get_attributes_from_options(options, error_prefix)
      return {} if options[:except_attributes] == :all
      
      options[:attributes] = {}
      
      if options[:only_attributes].empty?
        tmp = Hash.new
        
        message = "#{error_prefix} Warning you must type an array or the symbol :all for :except_attributes"
        raise ArgumentError, message unless options[:except_attributes].is_a?(Array)
        
        self.columns.each do |element|
          options[:attributes] = options[:attributes].merge(element.name => element.type.to_s)
        end
        options[:attributes].delete_if {|n,x| match_regexp(n, "*_id")}                 # filter default attributes that are used as foreign key
        unless options[:except_attributes].empty?
          options[:except_attributes].each do |attribute|
            options[:attributes].delete_if {|n,x| match_regexp(n, attribute.to_s)}
          end
        end 
      else
        message = "#{error_prefix} :only_attributes is wrong. Expected Array but was #{options[:only_attributes].inspect}:#{options[:only_attributes].class.to_s}"
        raise ArgumentError, message unless options[:only_attributes].is_a?(Array)
        
        message = "#{error_prefix} Warning you mustn't specify both 'only_attributes' and 'except_attributes' options, please choose one"
        raise ArgumentError, message unless options[:except_attributes].empty?
        
        options[:only_attributes].each do |attribute|
          message = "#{error_prefix} Undefined attribute '#{attribute}', maybe you misspelled it"
          raise ArgumentError, message unless self.new.respond_to?(attribute.to_s)
          
          self.columns.each do |element|
            options[:attributes] = options[:attributes].merge(element.name => element.type.to_s) if element.name == attribute.to_s
          end
        end
      end
      options[:attributes]
    end

    # Method that return true if the +relationship+ have some options to be taken in account
    #
    def relationship_need_to_be_checked?(relationship, sql_options)
      association = self.reflect_on_association(relationship)
      association.macro != :belongs_to and (association.options.keys-sql_options).size < association.options.keys.size
    end

    # Method that check +relationships_options+ to take in account some ignored options when using eager loading (:order,:group,:limit...)
    #
    def check_relationships_for_sql_options_support(relationships)
      
      sql_options   = [:group, :order, :limit]   # don't put :having because it is not implemented into rails 2.1.0, and :offset because it depend on :limit presence
      relationships = relationships.reject {|n| !relationship_need_to_be_checked?(n, sql_options)} # filter 'belongs_to' because there's no options usable with it
      
      relationships.each do |relationship|
        
        association = self.reflect_on_association(relationship)
        table       = self.quoted_table_name
        class_name  = association.class_name
        table_alias = "#{association.name.to_s}_#{self.table_name}" if (self.to_s == class_name)   # alias table when self referencing
        class_table = class_name.constantize.quoted_table_name
        foreign_key = association.options[:foreign_key] ||  "#{self.to_s.underscore}_id"
        primary_key = association.options[:primary_key] || "id"
        
        # options like :order or :conditions ...
        options = association.options
        
        # Has_and_belongs_to_many
        join_table              = "`#{options[:join_table]}`"
        association_foreign_key = (association.respond_to?('association_foreign_key'))? association.association_foreign_key : "#{class_name.underscore}_id"
       
        # polymorphique
        polymorphique_interface      = options[:as]
        polymorphique_interface_type = "'#{self.to_s}'"
        
        # TODO test relation with through pointing to a polymorphic to view the generated sql to know how to manage the source_type .
        source      = options[:source] || relationship.to_s
        source_type = options[:source_type] # for +has_one+ or +has_many+ pointing to a +belongs_to+ with ':polymorphic == true'
        
        # the relationship go through another one 
        unless options[:through].nil?     
          through             = options[:through]
          through_association = self.reflect_on_association(through)
          through_class_name  = through_association.class_name
          through_class_table = through_class_name.constantize.quoted_table_name
          # Manage N-N self reference
          default             = (self.to_s == class_name)? association.name.to_s.singularize : class_name.underscore
          through_fk          = through_association.options[:foreign_key] || "#{default}_id"
          through_pk          = through_association.options[:primary_key] || "id"
          through_polymorphique_interface = through_association.options[:as]
        end
        
        sql = "SELECT #{class_table}.id FROM #{class_table}"
         
        case association.macro
        
          when :has_one, :has_many
            join_end = through.nil? ? "#{class_table}." : "#{through_class_table}."
            
            unless through.nil?       
              sql += " INNER JOIN #{through_class_table} ON #{class_table}.#{through_pk} = #{through_class_table}.#{through_fk}"                
              if through_polymorphique_interface.nil?
                join_end    += "#{foreign_key}"
              else
                join_end    += "#{through_polymorphique_interface}_id"
                where_clause = " WHERE (#{through_class_table}.#{through_polymorphique_interface}_type = #{polymorphique_interface_type})"
              end             
            else
              if polymorphique_interface.nil?
                join_end    += "#{foreign_key}"
              else
                join_end    += "#{polymorphique_interface}_id"
                where_clause = " WHERE (#{class_table}.#{polymorphique_interface}_type = #{polymorphique_interface_type})"
              end               
            end
            
          when :has_and_belongs_to_many
            sql     += " INNER JOIN #{join_table} ON #{class_table}.#{primary_key} = #{join_table}.#{association_foreign_key}"
            join_end = "#{join_table}.#{foreign_key}"
        end
        
        table_with_alias = table_alias.nil? ? "#{table} ON #{table}" : "#{table} #{table_alias} ON #{table_alias}"
        sql += " LEFT OUTER JOIN #{table_with_alias}.#{primary_key} = #{join_end}"
        
        # where
        sql += where_clause unless where_clause.nil?         
        
        # FIXME remove that raise when mysql's subquery error will be fixed
        message  = "#{self::ERROR_PREFIX} #{association.macro} :#{association.name} -> " 
        message += ":LIMIT is not supported yet by mysql into subqueries 'http://dev.mysql.com/doc/refman/5.1/en/subquery-errors.html'"
        raise ArgumentError, message if association.macro != :has_one and !options[:limit].nil?
        ##################################################################
        
        sql_options.each do |option|     
          case option
            when :group
              unless options[:group].nil? or association.macro == :has_one
                sql += " GROUP BY #{ options[:group].to_s.split('.').last.split(',').collect{|n| "#{class_table}.#{n.strip}"}.join(', ') }"
              end
            when :order
              sql += " ORDER BY #{ options[:order].to_s.split('.').last.split(',').collect{|n| "#{class_table}.#{n.strip}"}.join(', ') }" unless options[:order].nil?
            when :limit
              sql += (association.macro == :has_one)? ' LIMIT 1' : add_limit_offset!('', {:limit => options[:limit], :offset => options[:offset]})
          end
          self.reflect_on_association(relationship).options.delete(option)
        end
        
        operator  = (association.macro == :has_one)? '=' : 'in'
        statement = "#{class_table}.#{primary_key} #{operator} (#{sql})"
        if options[:conditions].nil?
          self.reflect_on_association(relationship).options[:conditions]     = statement.to_a
        else
          self.reflect_on_association(relationship).options[:conditions][0] += " AND #{statement}"
        end
      end       
    end

end
