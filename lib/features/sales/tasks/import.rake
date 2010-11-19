require 'csv'
require 'importer'

namespace :osirails do
  namespace :sales do
    namespace :db do
      
      desc "Import all data from CSV file for the sales feature"
      task :import => [ "import:product_reference_categories", "import:product_reference_sub_categories", "import:product_references", "import:subcontractors" ]
      
      namespace :import do
        desc "Import product_reference_categories from CSV file. Give IF_MATCH in 'SKIP', 'OVERRIDE', 'DUPLICATE'"
        task :product_reference_categories => :environment do
          file_path = File.join(File.dirname(__FILE__), "..", "import", "product_references.csv")
          if File.exists?(file_path)
            file = File.open(file_path)
            rows = CSV::Reader.parse(file)
            
            definitions = { :reference => 0, :name => 1 }
            
            importer = Osirails::Importer.new(:klass => :product_reference_category, :identifiers => :name, :definitions => definitions, :if_match => ENV["IF_MATCH"])
            importer.import_data(rows)
          else
            raise "No such file '#{file_path}'"
          end
        end
        
        desc "Import product_reference_sub_categories from CSV file. Give IF_MATCH in 'SKIP', 'OVERRIDE', 'DUPLICATE'"
        task :product_reference_sub_categories => :environment do
          file_path = File.join(File.dirname(__FILE__), "..", "import", "product_references.csv")
          if File.exists?(file_path)
            file = File.open(file_path)
            rows = CSV::Reader.parse(file)
            
            definitions = { :product_reference_category_id  => { :find_by_name_and_product_reference_category_id => [ 1, nil ] },
                            :name                           => 2 }
            
            importer = Osirails::Importer.new(:klass => :product_reference_sub_category, :identifiers => [ :name, :product_reference_category_id ], :definitions => definitions, :if_match => ENV["IF_MATCH"])
            importer.import_data(rows)
          else
            raise "No such file '#{file_path}'"
          end
        end
        
        desc "Import product_references from CSV file. Give IF_MATCH in 'SKIP', 'OVERRIDE', 'DUPLICATE'"
        task :product_references => :environment do
          file_path = File.join(File.dirname(__FILE__), "..", "import", "product_references.csv")
          if File.exists?(file_path)
            file = File.open(file_path)
            rows = CSV::Reader.parse(file)
            
            definitions = { :product_reference_sub_category_id  => { :find_by_name_and_product_reference_category_id => [ 2, { :product_reference_category_id => { :find_by_name => 1 } } ] },
                            :name                               => 3 }
            
            importer = Osirails::Importer.new(:klass => :product_reference, :identifiers => :reference, :definitions => definitions, :if_match => ENV["IF_MATCH"])
            importer.import_data(rows)
          else
            raise "No such file '#{file_path}'"
          end
        end
        
        desc "Import subcontractors from CSV file. Give IF_MATCH in 'SKIP', 'OVERRIDE', 'DUPLICATE'"
        task :subcontractors => :environment do
          file_path = File.join(File.dirname(__FILE__), "..", "import", "subcontractors.csv")
          if File.exists?(file_path)
            file = File.open(file_path)
            rows = CSV::Reader.parse(file)
            
            definitions = { :name                         => 0,
                            :legal_form_id                => { :find_or_create_by_name => 1 },
                            :siret_number                 => 3,
                            :activity_sector_reference_id => { :find_by_code => 4 },
                            :address_attributes           => { :street_name   => 5,
                                                               :country_name  => 9,
                                                               :city_name     => 7,
                                                               :zip_code      => 6 },
                            :phone_attributes             => { :indicative_id => { :find_by_indicative => 10 },
                                                               :number        => 11 },
                            :fax_attributes               => { :indicative_id => { :find_by_indicative => 12 },
                                                               :number        => 13 },
                            :website                      => 14 }
                            #TODO implement company_created_at and collaboration_started_at
            importer = Osirails::Importer.new(:klass => :subcontractor, :identifiers => :name, :definitions => definitions, :if_match => ENV["IF_MATCH"])
            importer.import_data(rows)
          else
            raise "No such file '#{file_path}'"
          end
        end
      end
      
    end
  end
end
