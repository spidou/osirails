# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{active_counter}
  s.version = "0.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 1.2") if s.respond_to? :required_rubygems_version=
  s.authors = [%q{Mathieu Fontaine}]
  s.date = %q{2011-06-29}
  s.description = %q{ActiveCounter provides you a simple way to define counters, to update them and retrieve them.}
  s.email = %q{spidou@gmail.com}
  s.extra_rdoc_files = [%q{LICENSE}, %q{README}, %q{lib/active_counter.rb}, %q{lib/counter.rb}]
  s.files = [%q{LICENSE}, %q{README}, %q{Rakefile}, %q{generators/active_counter_migration/active_counter_migration_generator.rb}, %q{generators/active_counter_migration/templates/migration.rb}, %q{init.rb}, %q{lib/active_counter.rb}, %q{lib/counter.rb}, %q{Manifest}, %q{active_counter.gemspec}]
  s.homepage = %q{http://github.com/spidou/active_counter}
  s.rdoc_options = [%q{--line-numbers}, %q{--inline-source}, %q{--title}, %q{Active_counter}, %q{--main}, %q{README}]
  s.require_paths = [%q{lib}]
  s.rubyforge_project = %q{active_counter}
  s.rubygems_version = %q{1.8.5}
  s.summary = %q{ActiveCounter provides you a simple way to define counters, to update them and retrieve them.}

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
    else
    end
  else
  end
end
