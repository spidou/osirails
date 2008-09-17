class FileTypeExtension < ActiveRecord::Base
  
  has_many :file_types_file_type_extensions, :class_name => "FileTypesFileTypeExtensions"
  has_many :file_types, :through => :file_types_file_type_extensions
  
end