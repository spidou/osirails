# found at http://topfunky.net/svn/plugins/topfunky_power_tools/tasks/freeze.rake thanks to http://errtheblog.com/posts/50-vendor-everything
namespace :freeze do
  desc "Freeze Rails recursively. Works better with subversion than the built-in freeze."
  task :rails do      
    deps = %w(actionpack activerecord actionmailer activesupport actionwebservice)
    require 'rubygems'
    Gem.manage_gems

    rails = (version = ENV['VERSION']) ?
      Gem.cache.search('rails', "= #{version}").first :
      Gem.cache.search('rails').sort_by { |g| g.version }.last

    version ||= rails.version

    unless rails
      puts "No rails gem #{version} is installed.  Do 'gem list rails' to see what you have available."
      exit
    end

    puts "Recursively Freezing to the gems for Rails #{rails.version}"
    mkdir_p "vendor/rails"
    rm_rf "vendor/tmp_freeze"
    mkdir_p "vendor/tmp_freeze"

    chdir("vendor/tmp_freeze") do
      rails.dependencies.select { |g| deps.include? g.name }.each do |g|
        Gem::GemRunner.new.run(["unpack", "-v", "#{g.version_requirements}", "#{g.name}"])
        mv(Dir.glob("#{g.name}*").first, g.name)
      end

      Gem::GemRunner.new.run(["unpack", "-v", "=#{version}", "rails"])
      FileUtils.mv(Dir.glob("rails*").first, "railties")
    end

    # Copy files recursively to vendor/rails
  	Find.find("vendor/tmp_freeze") do |original_file|
  	  #next unless %r{/lib}.match(original_file)
  	  destination_file = original_file.gsub("tmp_freeze", "rails")

  	  if File.directory?(original_file)
  	    # Create every time in case intermediate directories were missed
        mkdir_p destination_file
      else
        puts "Copying #{destination_file}"
        `cp #{original_file} #{destination_file}`
  	  end
  	end

    rm_rf "vendor/tmp_freeze"
  end


  desc "Freeze third-party gems to 'vendor'. Requires GEMS environment variable to be set or passed on command-line (space-delimited)."
  task :others => :environment do
    if ENV['GEMS'].blank?
      raise "Requires a 'GEMS' environment variable (space-delimited)."
    end
    puts "Freezing #{ENV['GEMS']}..."

    libraries = ENV['GEMS'].split
    require 'rubygems'
    require 'find'
  
    libraries.each do |library|
      begin
        library_gem = Gem.cache.search(library).sort_by { |g| g.version }.last
        puts "Freezing #{library} for #{library_gem.version}..."
  
        # TODO Add dependencies to list of libraries to freeze
        #library_gem.dependencies.each { |g| libraries << g  }
      
        gems_folder = File.join("vendor", "gems")
        mkdir_p gems_folder
        
        if File.directory?(gem = File.join(gems_folder, library_gem.name))
          puts "#{gem} already exists. remove the old version before if you want to replace it"
          exit
        end
        
        system "cd #{gems_folder}; gem unpack -v '#{library_gem.version}' #{library_gem.name};"
        system "cd #{gems_folder}; mv #{library_gem.name}-#{library_gem.version} #{library_gem.name}"
      rescue
        raise "ERROR: Maybe you forgot to install the '#{library}' gem locally?"
      end
    end
  end
end
