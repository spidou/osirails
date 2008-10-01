class File
  
  def self.mime_type?(file)
    if file.class == File
      mime = find_mimetype(file.path)
    elsif file.class == ActionController::UploadedTempFile
      mime = find_mimetype(File.open(file))
    elsif file.class == String
      mime = find_mimetype(file)
    elsif file.class == StringIO or file.class == ActionController::UploadedStringIO
      temp = File.open(Dir.tmpdir + '/upload_file.' + Process.pid.to_s, "wb")
      temp << file.string
      temp.close
      mime = find_mimetype(temp.path)
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
        return `file -bir #{path_to_file}`.strip
      end
    end
    
end