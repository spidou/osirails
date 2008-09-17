class FileType < ActiveRecord::Base
  
  has_many :file_types_file_type_extensions, :class_name => "FileTypesFileTypeExtensions"
  has_many :file_type_extensions, :through => :file_types_file_type_extensions
  
end
