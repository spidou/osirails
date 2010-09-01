require 'csv'
require 'importer'

namespace :osirails do
  namespace :logistics do
    namespace :db do
      
      desc "Import all data from CSV file for the logistics feature"
      task :import => [ "import:commodity_categories", "import:commodities", "import:consumable_categories", "import:consumables" ]
      
      namespace :import do
        desc "Import commodity_categories from CSV file. Give IF_MATCH in 'SKIP', 'OVERRIDE', 'DUPLICATE'"
        task :commodity_categories => :environment do
          file_path = File.join(File.dirname(__FILE__), "..", "import", "commodity_categories.csv")
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
            
            definitions = { :supply_category_id => { :find_by_name_and_type => [ 0, "CommodityCategory" ] },
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
          file_path = File.join(File.dirname(__FILE__), "..", "import", "commodities.csv")
          if File.exists?(file_path)
            file = File.open(file_path)
            rows = CSV::Reader.parse(file)
            
            definitions = { :supply_sub_category_id => { :find_by_name_and_supply_category_id => [ 1, { :supply_category_id => { :find_by_name_and_type => [ 0, "CommodityCategory" ] } } ] },
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
                            :packaging  => 13,
                            :unit_mass  => 14,
                            :measure    => 15,
                            :supplier_supply_attributes => [ { :supplier_id           => { :find_by_name => 16 },
                                                               :supplier_reference    => 17,
                                                               #:supplier_designation  => 18,
                                                               :fob_unit_price        => 22,
                                                               :taxes                 => 23 } ] }
            
            importer = Osirails::Importer.new(:klass => :commodity, :identifiers => nil, :definitions => definitions, :if_match => ENV["IF_MATCH"])
            importer.import_data(rows)
          else
            raise "No such file '#{file_path}'"
          end
        end
        
        desc "Import consumable_categories from CSV file. Give IF_MATCH in 'SKIP', 'OVERRIDE', 'DUPLICATE'"
        task :consumable_categories => :environment do
          file_path = File.join(File.dirname(__FILE__), "..", "import", "consumable_categories.csv")
          if File.exists?(file_path)
            puts "Import first level of consumable_categories"
            file = File.open(file_path)
            rows = CSV::Reader.parse(file)
            
            definitions = { :name => 0 }
            
            importer = Osirails::Importer.new(:klass => :consumable_category, :identifiers => :name, :definitions => definitions, :if_match => ENV["IF_MATCH"])
            importer.import_data(rows)
            
            puts "Import second level of consumable_categories"
            file = File.open(file_path)
            rows = CSV::Reader.parse(file)
            
            definitions = { :supply_category_id => { :find_by_name_and_type => [ 0, "ConsumableCategory" ] },
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
            
            importer = Osirails::Importer.new(:klass => :consumable_sub_category, :identifiers => [ :name, :supply_category_id ], :definitions => definitions, :if_match => ENV["IF_MATCH"])
            importer.import_data(rows)
          else
            raise "No such file '#{file_path}'"
          end
        end
        
        desc "Import consumables from CSV file. Give IF_MATCH in 'SKIP', 'OVERRIDE', 'DUPLICATE'"
        task :consumables => :environment do
          file_path = File.join(File.dirname(__FILE__), "..", "import", "consumables.csv")
          if File.exists?(file_path)
            file = File.open(file_path)
            rows = CSV::Reader.parse(file)
            
            definitions = { :supply_sub_category_id => { :find_by_name_and_supply_category_id => [ 1, { :supply_category_id => { :find_by_name_and_type => [ 0, "ConsumableCategory" ] } } ] },
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
                            :packaging  => 13,
                            :unit_mass  => 14,
                            :measure    => 15,
                            :supplier_supply_attributes => [ { :supplier_id           => { :find_by_name => 16 },
                                                               :supplier_reference    => 17,
                                                               #:supplier_designation  => 18,
                                                               :fob_unit_price        => 22,
                                                               :taxes                 => 23 } ] }
            
            importer = Osirails::Importer.new(:klass => :consumable, :identifiers => nil, :definitions => definitions, :if_match => ENV["IF_MATCH"])
            importer.import_data(rows)
          else
            raise "No such file '#{file_path}'"
          end
        end
      end
      
    end
  end
end
