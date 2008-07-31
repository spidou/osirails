class RenameContribuorsColumn < ActiveRecord::Migration
  def self.up
    rename_column(:content_versions, :contributors, :contributor)
  end

  def self.down
    rename_column(:content_versions, :contributor, :contributors)
  end
end
