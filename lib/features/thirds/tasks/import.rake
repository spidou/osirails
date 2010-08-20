require 'csv'
require 'importer'

namespace :osirails do
  namespace :thirds do
    namespace :db do
      
      desc "Import all data from CSV file for the thirds feature"
      task :import => [ "import:activity_sector_references", "import:customers" ]
      
      namespace :import do
        desc "Import activity_sector_references from CSV file. Give IF_MATCH in 'SKIP', 'OVERRIDE', 'DUPLICATE'"
        task :activity_sector_references => :environment do
          file_path = File.join(File.dirname(__FILE__), "..", "import", "activity_sector_references.csv")
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
          file_path = File.join(File.dirname(__FILE__), "..", "import", "customers.csv")
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
      end
      
    end
  end
end
