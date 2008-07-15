dependencies = [{:name => "Test", :version => "0.1"}]
conflicts = []
f = Feature.find_or_create_by_name_and_version("Test1","0.1")
f.dependencies = dependencies
f.conflicts = conflicts
f.save

