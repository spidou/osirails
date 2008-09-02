class FileTypesFileTypeExtensions < ActiveRecord::Base
  
  belongs_to :file_type
  belongs_to :file_type_extension
  
end