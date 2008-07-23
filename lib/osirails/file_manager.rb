module Osirails
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
        directory = "public"
      end
      if options[:name].nil?
        name =  options[:file]['datafile'].original_filename
      end
      if !options[:extensions].nil?
        valid_extension = false
        options[:extensions].each do |extension|
          valid_extension ||= name.end_with?("." + extension)
        end
        if valid_extension == false
          raise "File uploaded is not a valid extension: " + name
          return false
        end
      end
      path = File.join(options[:directory], name)
      File.open(path, "wb") { |f| f.write(options[:file]['datafile'].read) }
      true
    end

  end
end