require 'csv'
require 'importer'

namespace :osirails do
  namespace :db do
    namespace :import do
      
      desc "Import all data from CSV files. Give IF_MATCH in 'SKIP', 'OVERRIDE', 'DUPLICATE'"
      task :all => [ :activity_sector_references, :customers, :product_reference_categories, :product_references ]
      
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
                                                             :establishment_type_id         => { :first => nil },
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
                          :customer_grade_id          => { :find_or_create_by_name => 21 },
                          :customer_solvency_id       => { :find_or_create_by_name => 22 },
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
      
      desc "Import product_reference_categories from CSV file. Give IF_MATCH in 'SKIP', 'OVERRIDE', 'DUPLICATE'"
      task :product_reference_categories => :environment do
        file_path = File.join(RAILS_ROOT, "import", "product_reference_categories.csv")
        if File.exists?(file_path)
          # import first level of categories
          puts "Import first level of categories"
          file = File.open(file_path)
          rows = CSV::Reader.parse(file)
          
          definitions = { :name => 0 }
          importer = Osirails::Importer.new(:klass => :product_reference_category, :identifiers => :name, :definitions => definitions, :if_match => ENV["IF_MATCH"])
          importer.import_data(rows)
          
          # import second level of categories
          puts "Import second level of categories"
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
