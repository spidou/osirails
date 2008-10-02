class MimeType < ActiveRecord::Base
  
  has_many :mime_type_extensions
  has_and_belongs_to_many :file_types, :join_table => 'file_types_mime_types', :foreign_key => 'mime_type_id', :association_foreign_key => 'file_type_id'
  
end