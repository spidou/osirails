# Create a script gediturl with the following:
#
#    #!/usr/bin/ruby
#    
#    arg = ARGV.first
#    url = arg.split('file:').last
#    file, line = url.to_s.split('&')
#    
#    if !line.nil? 
#    	l = line[5..line.length]
#    	system("/usr/bin/gedit #{file} +#{l}")
#    else
#    	system("/usr/bin/gedit #{file}")
#    end
#
# Make it executable (chmod +x gediturl)
#
# On Firefox, type about:config and create new boolean named 'network.protocol-handler.expose.txmt' at 'false'
# When clicking on a Footnote link with 'txmt' protocol, Firefox asks you to choose a program. Select 'gediturl' and voilà!
#
#
#
# With rails-footnotes 3.6.7 (compatible with rails 2.2.*), queries_note is not configured to display INSERT queries,
# here is a way to set it up :
#
# open the file ~/.gem/gems/rails-footnotes-3.6.7/lib/rails-footnotes/notes/queries_note.rb
# and replace the line 154:
#    if query =~ /^(select|create|update|delete)\b/i
# by:
#    if query =~ /^(select|create|insert|update|delete)\b/i
#

if defined?(Footnotes) && Rails.env.development?
  Dir["#{RAILS_ROOT}/lib/notes/**"].map do |note| 
    require note
  end
  
  Footnotes::Filter.notes += [:loading_time]
end
