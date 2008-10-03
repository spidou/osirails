class FileManager
  # Class method for upload a file to the server
  # options is a hash witch use the following symbol:
  # :file (it's the file to upload)
  # :directory (optional, it's a string contain the path, example: "public/upload")
  # :name (optional, it's a string to define the new name of the file)
  # :file_type_id correspond to the id of a file_type
  def self.upload_file(options)
    return false if options[:file].nil?
    if options[:directory].nil?
      options[:directory] = "tmp/"
    end
    
    unless options[:name].nil?
      name =  options[:name] + "." + real_extension(options[:file][:datafile])
    else
      name = options[:file][:datafile].original_filename
    end
    
    ## Creation of path on server
    directory = ""
    options[:directory].split("/").each do |d|
      directory += d +"/"
      Dir.mkdir(directory) unless File.exist?(directory)
    end
    path = File.join(options[:directory], name)
    
#    raise self.valid_mime_type?(options[:file][:datafile], options[:file_type_id]).inspect
    unless File.exist?(path)
      #TODO change this code to integre a test for mime type like "- application /..."
      ## Test if mime_type correspond with possible extension
      if self.valid_mime_type?(options[:file][:datafile], options[:file_type_id])
        File.open(path, "wb") { |f| f.write(options[:file][:datafile].read)}
        return File.exist?(path)
      else
        FileManager.delete_file(path)
        return false
      end
    end
  end
  
  def self.valid_mime_type?(file, file_type_id)
    response = false
    file_mime_type = File.mime_type?(file)
    FileType.find(file_type_id).mime_types.each{|mime_type| response = true if mime_type.name == file_mime_type}
    return response
  end
  
  def self.real_extension(file)
    real_extension = nil
    File.extensions.each_pair do |k,v|
      if v == File.mime_type?(file.path)
        real_extension = k.to_s
        break
      end
    end
    return real_extension
  end
  
  def self.delete_file(file)
    FileUtils.rm_rf(file)
  end

end