Paperclip::Attachment.interpolations[:owner_class] = proc do |attachment, style|
  attachment.instance.has_document.class.name.tableize
end

Paperclip::Attachment.interpolations[:owner_id] = proc do |attachment, style|
  attachment.instance.has_document_id
end

Paperclip::Attachment.interpolations[:mimetype] = proc do |attachment, style|
  attachment.send(attachment.name.to_s + "_file_type").camelize
end