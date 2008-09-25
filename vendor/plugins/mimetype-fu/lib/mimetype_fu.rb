class File
  
  def self.mime_type?(file)
    if file.class == File
      mime = find_mimetype(file.path)
    elsif file.class == String
      mime = find_mimetype(file)
    elsif file.class == StringIO
      temp = File.open(Dir.tmpdir + '/upload_file.' + Process.pid.to_s, "wb")
      temp << file.string
      temp.close
      mime = `file -bir #{temp.path}`
      mime = mime.gsub(/^.*: */,"")
      mime = mime.gsub(/;.*$/,"")
      mime = mime.gsub(/,.*$/,"")
      File.delete(temp.path)
    end
    
    mime ||= false
    return mime
  end

  def self.extensions
    EXTENSIONS
  end
  
  private
    def self.find_mimetype(path_to_file)
      if RUBY_PLATFORM.include?('mswin32') or !File.exists?(path_to_file)
        return EXTENSIONS[File.extname(path_to_file).gsub('.','').downcase.to_sym]
      else
        return `file -bir #{path_to_file}`.strip.split("/")[1].split(";")[0].to_s
      end
    end
    
end