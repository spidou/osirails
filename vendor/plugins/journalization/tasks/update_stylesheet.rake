namespace :journalization do
  desc "Update stylesheet"
  task :update_stylesheet do
    load File.join(File.dirname(__FILE__), "..", "lib", "update_stylesheet.rb")
  end
end
