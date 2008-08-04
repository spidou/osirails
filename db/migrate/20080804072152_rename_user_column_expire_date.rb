class RenameUserColumnExpireDate < ActiveRecord::Migration
  def self.up
    rename_column(:users, :expire_date, :password_updated_at)
  end

  def self.down
    rename_column(:users, :password_updated_at, :expire_date)
  end
end
