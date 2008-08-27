class RenameColumnCountry < ActiveRecord::Migration
  def self.up
    remove_column :indicatives ,:country
    add_column :indicatives ,:country_id ,:integer
    
            
    Indicative.create :indicative => "+1", :country_id => 5
    Indicative.create :indicative => "+33",:country_id=> 1  
    Indicative.create :indicative => "+34", :country_id => 7
    Indicative.create :indicative => "+44", :country_id => 6
    Indicative.create :indicative => "+49", :country_id => 8
    Indicative.create :indicative => "+81", :country_id => 4
    Indicative.create :indicative => "+86", :country_id => 9
    Indicative.create :indicative => "+262", :country_id => 2
    
  end

  def self.down
    remove_column :indicatives ,:country_id
    add_column :indicatives ,:country ,:string
    
    Indicative.destroy_all
  end
end
