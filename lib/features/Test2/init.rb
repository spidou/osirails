dependencies = [{:name => "Test", :version => ["0.1"]},{:name => "Test1", :version => ["0.1"]}]
conflicts = []
f = Osirails::Feature.find_or_create_by_name_and_version("Test2","0.1")
f.dependencies = dependencies
f.conflicts = conflicts
f.save
