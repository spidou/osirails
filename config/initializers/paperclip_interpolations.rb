# defines interpolations for paperclip
if Object.const_defined?("Paperclip")
  Paperclip::Attachment.interpolations[:current_theme_path] = proc do |attachment, style|
    $CURRENT_THEME_PATH
  end
else
  raise Exception, "paperclip is required"
end
