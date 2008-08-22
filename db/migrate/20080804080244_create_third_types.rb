class CreateThirdTypes < ActiveRecord::Migration
  def self.up
    create_table :third_types do |t|
      t.string :wording
      
      t.timestamps
    end
    
    ThirdType.create :wording => "Privé"
    ThirdType.create :wording => "Public"
    
  end

  def self.down
    drop_table :third_types
  end
end
