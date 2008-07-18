dependencies = []
conflicts = []
f = Osirails::Feature.find_or_create_by_name_and_version("Test","0.1")
f.dependencies = dependencies
f.conflicts = conflicts
f.save
