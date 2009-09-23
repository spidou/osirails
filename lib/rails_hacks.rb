# basics overrides are put in config/initializers/basics_overrides.rb.
# if you want to hack rails but you can't put your code in basics_overrides.rb
# because initializers are loaded after plugins, you might put your hack here

module ActiveRecord
  class Base
    def self.singularized_table_name
      name.underscore # 'table_name.singularize' return a wrong result when we use single table inheritance
    end
  end
end
