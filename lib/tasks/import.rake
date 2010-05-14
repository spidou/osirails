require 'csv'
require 'importer'

namespace :osirails do
  namespace :db do
    namespace :import do
      
      desc "Import all data from CSV files. Give IF_MATCH in 'SKIP', 'OVERRIDE', 'DUPLICATE'"
      task :all => [ :activity_sector_references, :customers, :commodity_categories, :commodities, :product_reference_categories, :product_references ]
      
      desc "Import activity_sector_references from CSV file. Give IF_MATCH in 'SKIP', 'OVERRIDE', 'DUPLICATE'"
      task :activity_sector_references => :environment do
        file_path = File.join(RAILS_ROOT, "import", "activity_sector_references.csv")
        if File.exists?(file_path)
          file = File.open(file_path)
          rows = CSV::Reader.parse(file)
          
          definitions = { :code                       => 0,
                          :activity_sector_id         => { :find_or_create_by_name => 1 },
                          :custom_activity_sector_id  => { :find_or_create_by_name => 2 } }
          
          importer = Osirails::Importer.new(:klass => :activity_sector_reference, :identifiers => :code, :definitions => definitions, :if_match => ENV["IF_MATCH"])
          importer.import_data(rows)
        else
          raise "No such file '#{file_path}'"
        end
      end
      
      desc "Import customers from CSV file. Give IF_MATCH in 'SKIP', 'OVERRIDE', 'DUPLICATE'"
      task :customers => :environment do
        file_path = File.join(RAILS_ROOT, "import", "customers.csv")
        if File.exists?(file_path)
          file = File.open(file_path)
          rows = CSV::Reader.parse(file)
          
          definitions = { :name                       => 0,
                          :legal_form_id              => { :find_or_create_by_name_and_third_type_id => [ 1, { :third_type_id => { :find_or_create_by_name => "IMPORTED" } } ] },
                          :head_office_attributes     => [ { :name                          => 0,
                                                             :establishment_type_id         => { :first => nil }, #TODO retrieve good value
                                                             :siret_number                  => 2,
                                                             :activity_sector_reference_id  => { :find_by_code  => 3 },
                                                             :address_attributes            => { :street_name   => 4,
                                                                                                 :country_name  => 9,
                                                                                                 :city_name     => 7,
                                                                                                 :zip_code      => 5 },
                                                             :phone_attributes              => { :indicative_id => { :find_by_indicative => 10 },
                                                                                                 :number        => 11 },
                                                             :fax_attributes                => { :indicative_id => { :find_by_indicative => 12 },
                                                                                                 :number        => 13 }, } ],
                          :customer_grade_id          => { :find_by_name => 21 },
                          :customer_solvency_id       => { :find_by_name => 22 },
                          :bill_to_address_attributes => { :street_name   => 4,
                                                           :country_name  => 9,
                                                           :city_name     => 7,
                                                           :zip_code      => 5 } }
                          #TODO implement company_created_at and collaboration_started_at
          importer = Osirails::Importer.new(:klass => :customer, :identifiers => :name, :definitions => definitions, :if_match => ENV["IF_MATCH"])
          importer.import_data(rows)
        else
          raise "No such file '#{file_path}'"
        end
      end
      
      desc "Import commodity_categories from CSV file. Give IF_MATCH in 'SKIP', 'OVERRIDE', 'DUPLICATE'"
      task :commodity_categories => :environment do
        file_path = File.join(RAILS_ROOT, "import", "commodity_categories.csv")
        if File.exists?(file_path)
          puts "Import first level of commodity_categories"
          file = File.open(file_path)
          rows = CSV::Reader.parse(file)
          
          definitions = { :name => 0 }
          
          importer = Osirails::Importer.new(:klass => :commodity_category, :identifiers => :name, :definitions => definitions, :if_match => ENV["IF_MATCH"])
          importer.import_data(rows)
          
          puts "Import second level of commodity_categories"
          file = File.open(file_path)
          rows = CSV::Reader.parse(file)
          
          definitions = { :supply_category_id => { :find_by_name => 0 },
                          :name               => 1,
                          :supply_categories_supply_size_attributes => [ { :supply_size_id  => { :find_by_name    => "Épaisseur" },
                                                                           :unit_measure_id => { :find_by_symbol  => 2 }, },
                                                                         { :supply_size_id  => { :find_by_name    => "Diamètre" },
                                                                           :unit_measure_id => { :find_by_symbol  => 3 }, },
                                                                         { :supply_size_id  => { :find_by_name    => "Largeur" },
                                                                           :unit_measure_id => { :find_by_symbol  => 4 }, },
                                                                         { :supply_size_id  => { :find_by_name    => "Longueur" },
                                                                           :unit_measure_id => { :find_by_symbol  => 5 }, },
                                                                         { :supply_size_id  => { :find_by_name    => "Hauteur" },
                                                                           :unit_measure_id => { :find_by_symbol  => 6 }, },
                                                                         { :supply_size_id  => { :find_by_name    => "Angle" },
                                                                           :unit_measure_id => { :find_by_symbol  => 7 }, },
                                                                         { :supply_size_id  => { :find_by_name    => "Volume" },
                                                                           :unit_measure_id => { :find_by_symbol  => 8 }, },
                                                                         { :supply_size_id  => { :find_by_name    => "Puissance" },
                                                                           :unit_measure_id => { :find_by_symbol  => 9 }, },
                                                                         { :supply_size_id  => { :find_by_name    => "Tension" },
                                                                           :unit_measure_id => { :find_by_symbol  => 10 }, },
                                                                         { :supply_size_id  => { :find_by_name    => "Intensité" },
                                                                           :unit_measure_id => { :find_by_symbol  => 11 } } ],
                          :unit_measure_id => { :find_by_symbol => 12 } }
          
          importer = Osirails::Importer.new(:klass => :commodity_sub_category, :identifiers => [ :name, :supply_category_id ], :definitions => definitions, :if_match => ENV["IF_MATCH"])
          importer.import_data(rows)
        else
          raise "No such file '#{file_path}'"
        end
      end
      
      desc "Import commodities from CSV file. Give IF_MATCH in 'SKIP', 'OVERRIDE', 'DUPLICATE'"
      task :commodities => :environment do
        file_path = File.join(RAILS_ROOT, "import", "commodities.csv")
        if File.exists?(file_path)
          file = File.open(file_path)
          rows = CSV::Reader.parse(file)
          
          definitions = { :supply_sub_category_id => { :find_by_name_and_supply_category_id => [ 1, { :supply_category_id => { :find_by_name => 0 } } ] },
                          :name => 2,
                          :supplies_supply_size_attributes => [ { :supply_size_id   => { :find_by_name => "Épaisseur" },
                                                                  :value            => 3 },
                                                                { :supply_size_id   => { :find_by_name => "Diamètre" },
                                                                  :value            => 4 },
                                                                { :supply_size_id   => { :find_by_name => "Largeur" },
                                                                  :value            => 5 },
                                                                { :supply_size_id   => { :find_by_name => "Longueur" },
                                                                  :value            => 6 },
                                                                { :supply_size_id   => { :find_by_name => "Hauteur" },
                                                                  :value            => 7 },
                                                                { :supply_size_id   => { :find_by_name => "Angle" },
                                                                  :value            => 8 },
                                                                { :supply_size_id   => { :find_by_name => "Volume" },
                                                                  :value            => 9 },
                                                                { :supply_size_id   => { :find_by_name => "Puissance" },
                                                                  :value            => 10 },
                                                                { :supply_size_id   => { :find_by_name => "Tension" },
                                                                  :value            => 11 },
                                                                { :supply_size_id   => { :find_by_name => "Intensité" },
                                                                  :value            => 12 }, ],
                          :unit_mass  => 13,
                          :measure    => 19,
                          :supplier_supply_attributes => [ { :supplier_id         => { :first => nil },
                                                             :supplier_reference  => 16,
                                                             :fob_unit_price      => 21,
                                                             :taxes               => 22 } ] }
          
          importer = Osirails::Importer.new(:klass => :commodity, :identifiers => nil, :definitions => definitions, :if_match => ENV["IF_MATCH"])
          importer.import_data(rows)
        else
          raise "No such file '#{file_path}'"
        end
      end
      
      desc "Import product_reference_categories from CSV file. Give IF_MATCH in 'SKIP', 'OVERRIDE', 'DUPLICATE'"
      task :product_reference_categories => :environment do
        file_path = File.join(RAILS_ROOT, "import", "product_reference_categories.csv")
        if File.exists?(file_path)
          puts "Import first level of product_reference_categories"
          file = File.open(file_path)
          rows = CSV::Reader.parse(file)
          
          definitions = { :name => 0 }
          
          importer = Osirails::Importer.new(:klass => :product_reference_category, :identifiers => :name, :definitions => definitions, :if_match => ENV["IF_MATCH"])
          importer.import_data(rows)
          
          puts "Import second level of product_reference_categories"
          file = File.open(file_path)
          rows = CSV::Reader.parse(file)
          
          definitions = { :name                           => 1,
                          :product_reference_category_id  => { :find_or_create_by_name_and_product_reference_category_id => [ 0, nil ] } }
          
          importer = Osirails::Importer.new(:klass => :product_reference_category, :identifiers => [ :name, :product_reference_category_id ], :definitions => definitions, :if_match => ENV["IF_MATCH"])
          importer.import_data(rows)
        else
          raise "No such file '#{file_path}'"
        end
      end
      
      desc "Import product_references from CSV file. Give IF_MATCH in 'SKIP', 'OVERRIDE', 'DUPLICATE'"
      task :product_references => :environment do
        file_path = File.join(RAILS_ROOT, "import", "product_references.csv")
        if File.exists?(file_path)
          file = File.open(file_path)
          rows = CSV::Reader.parse(file)
          
          definitions = { :reference                      => 0,
                          :product_reference_category_id  => { :find_or_create_by_name_and_product_reference_category_id => [ 2, { :product_reference_category_id => { :find_by_name => 1 } } ] },
                          :name                           => 3 }
          
          importer = Osirails::Importer.new(:klass => :product_reference, :identifiers => :reference, :definitions => definitions, :if_match => ENV["IF_MATCH"])
          importer.import_data(rows)
        else
          raise "No such file '#{file_path}'"
        end
      end
      
    end
  end
end
