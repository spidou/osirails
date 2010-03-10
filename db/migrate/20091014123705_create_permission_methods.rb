class CreatePermissionMethods < ActiveRecord::Migration
  def self.up
    create_table :permission_methods do |t|
      t.string :name, :title
    end
  end

  def self.down
    drop_table :permission_methods
  end
end
