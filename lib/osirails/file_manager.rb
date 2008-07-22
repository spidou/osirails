module Osirails
  class FileManager
    # Class method for upload a file to the server
    # options is a hash witch use the following symbol:
    # :file (it's the file to upload)
    # :directory (optional, it's a string contain the path)
    # :name (optional, it's a string to define the new name of the file)
    def self.upload_file(options)
      return false if options[:file].nil?
      if  options[:directory].nil?
        directory = "public"
      end
      if options[:name].nil?
        name =  options[:file]['datafile'].original_filename
      end
      path = File.join(directory, name)
      File.open(path, "wb") { |f| f.write(options[:file]['datafile'].read) }
      true
    end

  end
end