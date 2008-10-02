class FileType < ActiveRecord::Base
  
  has_and_belongs_to_many :mime_types, :join_table => 'file_types_mime_types', :foreign_key => 'file_type_id', :association_foreign_key => 'mime_type_id'
  
end
