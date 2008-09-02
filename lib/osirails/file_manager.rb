class FileManager
  # Class method for upload a file to the server
  # options is a hash witch use the following symbol:
  # :file (it's the file to upload)
  # :directory (optional, it's a string contain the path, example: "public/upload")
  # :name (optional, it's a string to define the new name of the file)
  # :extensions (optional, it's an array of string where contains the allowed extensions, example: ["gif", "jpg"])
  def self.upload_file(options)
    return false if options[:file].nil?
    if options[:directory].nil?
      options[:directory] = "tmp/"
    end
    if options[:name].nil?
      name =  options[:file]['datafile'].original_filename
    else
      name = options[:name]
    end
    valid_extension = false
    
    unless options[:extensions].nil?
      valid_extension = false
      options[:extensions].each do |extension|
        if name.end_with?("." + extension)
          valid_extension = true
        end
      end
      unless valid_extension
        raise "Not valid extension"
        return false
      end
    end
    ## Creation of path on server
    directory = ""
    options[:directory].split("/").each do |d|
      directory += d +"/"
      Dir.mkdir(directory) unless File.exist?(directory)
    end
    path = File.join(options[:directory], name)
    File.open(path, "wb") { |f| f.write(options[:file]['datafile'].read) }
    true
  end
  
  def self.delete_file(file)
    FileUtils.rm_rf(file)
  end

end