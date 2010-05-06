module Osirails
  class Importer
    attr_accessor :klass, :identifiers, :definitions, :attributes, :if_match
    
    # Importer can import all your data for any ActiveRecord class from a csv file
    #
    # +klass+       is the ActiveRecord class we want to import
    # +identifiers+ is the method name (or column name) which differenciate one instance of +klass+ by another
    # +definitions+ is a Hash which map each column of the csv file to an attribute of the model
    # +if_match+    specifies the policy when a duplicate is found (based on the identifiers attribute)
    #               "SKIP"      won't affect existing records
    #               "OVERRIDE"  will update existing records with value from the csv file
    #               "DUPLICATE" won't affect existing records, but create new records
    #
    # ==== Example
    #   definition = { :name                     => 0,
    #                  :legal_form_id            => 1,
    #                  :siret_number             => 2,
    #                  :establishment_attributes => { :name                  => 3,
    #                                                 :establishment_type_id => 4,
    #                                                 :address_attributes    => { :street_name => 5 }
    #
    #   Importer.new(:klass => :customer, :identifiers => :name, :definitions => definitions, :if_match => "SKIP")
    #
    def initialize(params = {})
      self.klass        = params[:klass].to_s.camelize.constantize
      self.identifiers  = [ params[:identifiers] ].flatten
      self.definitions  = params[:definitions]
      self.if_match     = ( params[:if_match] || "SKIP" ).upcase
      self.attributes   = {}
    end
    
    # import data via ActiveRecord models from a csv file
    def import_data(rows)
      raise "Importer expected to have 'identifiers' and 'definitions' to import data" unless identifiers and definitions
      
      count           = 0
      count_created   = 0
      count_failed    = 0
      count_skipped   = 0
      count_overrided = 0
      started_at = Time.now
      
      rows.each do |row|
        count += 1
        row.collect!{ |r| r ? r.strip : "" }
        
        attributes = map_definitions(row)
        
        identifier = identifiers.join("_and_")
        args = identifiers.collect{ |i| attributes[i] }
        object = klass.send("find_by_#{identifier}", *args) || klass.new # eg: User.find_by_username_and_role_id("admin", 1) if idenfifiers = [ :username, :role_id]
        
        if !object.new_record? # if object already exist
          puts "A similar entry has been found when trying to import this line : #{row.inspect}\nYou choose to #{if_match} this entry\n============"
          
          case if_match
          when "SKIP"
            count_skipped += 1
            next
          when "OVERRIDE"
            count_overrided += 1
          when "DUPLICATE"
            definitions.merge!(identifiers.first => attributes[identifiers.first] + " [DUPLICATED_AT_#{Time.now.strftime('%Y%m%d%H%M%S')}]")
            customer = klass.new
          end
        end
        was_new_record = object.new_record?
        
        object.attributes = attributes
        if object.save
          count_created += 1 if was_new_record
        else
          count_failed += 1
          puts "#{count_failed}. An entry has failed to be saved when trying to import this line : #{row.inspect}
Object => #{object.class.name} : #{object.attributes.inspect}
Errors => #{object.errors.full_messages}
============"
        end
      end
      
      puts "#{count} #{klass.to_s.underscore.pluralize} imported in #{Time.now - started_at} seconds. #{count_created} created, #{count_failed} failed, #{count_skipped} skipped, #{count_overrided} overrided"
    end
    
    # return a hash with correct values from the importation script
    # this method get a hash like this in argument :
    #
    #   { :name                     => 0,
    #     :legal_form_id            => 1,
    #     :siret_number             => 2,
    #     :establishment_attributes => { :name                  => 3,
    #                                    :establishment_type_id => 4,
    #                                    :address_attributes    => { :street_name => 5 } }
    #
    # and return a hash like this :
    #
    #   { :name                     => "The name",
    #     :legal_form_id            => 10,
    #     :siret_number             => "12345678901234",
    #     :establishment_attributes => { :name                  => "Another name",
    #                                    :establishment_type_id => 4,
    #                                    :address_attributes    => { :street_name => "Street name" }
    #
    #
    # The method accept different kind of argument to setup your importation definition
    # 1. You can give an +Integer+ like we did in first examples to point out a column in the csv file
    #
    # 2. You can give a +Hash+ like we did in first examples to point out a column in the csv file,
    #    but here to define a nested resource of the main model
    #
    # 3. You can give a +Hash+ with another +Hash+ as value to indicate the method to call to determine the value
    #    Its mainly used with belongs_to relationship
    # 
    # Example :
    #   { :product_reference_category_id => { :find_or_create_by_name_and_product_reference_category_id => [ 0, nil ] } }
    #
    # 4. You can nested as much as you want
    #
    # Example :
    #   { :reference                      => 0,
    #     :product_reference_category_id  => { :find_or_create_by_name_and_product_reference_category_id => [ 2, { :product_reference_category_id => { :find_by_name => 1 } } ] },
    #     :name                           => 3 }
    #
    #   # => { :reference                      => "REF",
    #          :product_reference_category_id  => 10,
    #          :name                           => "My Name" }
    #
    def map_definitions(row, hash = definitions, result = {})
      hash.each do |key, value|
        begin
          
          if value.is_a?(Hash) and key.to_s.ends_with?("_id")
            
            association_class = key.to_s.gsub(/_id$/, "").camelize.constantize
            method = value.keys.first
            attribute = value.values.first
            if attribute.is_a?(Array)
              args = attribute.collect do |a|
                if a.is_a?(Integer)
                  row[a]
                elsif a.is_a?(Hash)
                  map_definitions(row, a).values.first
                else
                  a
                end
              end
            elsif attribute.is_a?(Integer)
              args = row[attribute]
            else
              args = attribute
            end
            
            if instance = association_class.send(method, *args)
              result[key] = instance.id
            else
              puts "A record has not been found here : { :#{key} => #{association_class}.#{method}('#{args.collect(&:to_s).join("', '")}') }"
            end
              
          elsif value.is_a?(Hash)
            result[key] = map_definitions(row, value)
          elsif value.is_a?(Array)
            result[key] = []
            value.each do |sub_element|
              result[key] << map_definitions(row, sub_element)
            end
          elsif value.is_a?(Integer)
            result[key] = row[value]
          else
            result[key] = value.to_s
          end
          
        rescue Exception => e
          raise "\n==== mapping failure informations ==== :
row = #{row.inspect}
key = #{key.inspect}
value = #{value.inspect}
error = #{e.message}
@@ backtrace @@
#{e.backtrace.join("\n")}
@@ end of backtrace @@
====\n"
        end
      end
      
      return result
    end
  end
end
