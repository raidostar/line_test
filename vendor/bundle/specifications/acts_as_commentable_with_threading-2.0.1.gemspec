# -*- encoding: utf-8 -*-
# stub: acts_as_commentable_with_threading 2.0.1 ruby lib

Gem::Specification.new do |s|
  s.name = "acts_as_commentable_with_threading".freeze
  s.version = "2.0.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["Evan Light".freeze, "Jack Dempsey".freeze, "Xelipe".freeze, "xxx".freeze]
  s.date = "2015-12-22"
  s.description = "Polymorphic threaded comments Rails gem for Rails 4+".freeze
  s.email = "evan@tripledogdare.net".freeze
  s.homepage = "http://github.com/elight/acts_as_commentable_with_threading".freeze
  s.rubygems_version = "3.0.3".freeze
  s.summary = "Polymorphic comments Rails gem - Rails 4+ only".freeze

  s.installed_by_version = "3.0.3" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_development_dependency(%q<rake>.freeze, [">= 0"])
      s.add_development_dependency(%q<rspec>.freeze, [">= 3.0"])
      s.add_development_dependency(%q<rails>.freeze, [">= 4.0"])
      s.add_runtime_dependency(%q<activerecord>.freeze, [">= 4.0"])
      s.add_runtime_dependency(%q<activesupport>.freeze, [">= 4.0"])
      s.add_runtime_dependency(%q<awesome_nested_set>.freeze, [">= 3.0"])
    else
      s.add_dependency(%q<rake>.freeze, [">= 0"])
      s.add_dependency(%q<rspec>.freeze, [">= 3.0"])
      s.add_dependency(%q<rails>.freeze, [">= 4.0"])
      s.add_dependency(%q<activerecord>.freeze, [">= 4.0"])
      s.add_dependency(%q<activesupport>.freeze, [">= 4.0"])
      s.add_dependency(%q<awesome_nested_set>.freeze, [">= 3.0"])
    end
  else
    s.add_dependency(%q<rake>.freeze, [">= 0"])
    s.add_dependency(%q<rspec>.freeze, [">= 3.0"])
    s.add_dependency(%q<rails>.freeze, [">= 4.0"])
    s.add_dependency(%q<activerecord>.freeze, [">= 4.0"])
    s.add_dependency(%q<activesupport>.freeze, [">= 4.0"])
    s.add_dependency(%q<awesome_nested_set>.freeze, [">= 3.0"])
  end
end
