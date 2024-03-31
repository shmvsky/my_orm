# frozen_string_literal: true

require_relative 'lib/my_orm/version'

Gem::Specification.new do |spec|
  spec.name = 'my_orm'
  spec.version = MyOrm::VERSION
  spec.authors = %w[shmvsky viaznikov]

  spec.summary = 'Реализация ORM в Ruby'
  spec.license = 'MIT'
  spec.required_ruby_version = '>= 2.6.0'

  spec.files = Dir.chdir(__dir__) do
    `git ls-files -z`.split("\x0").reject do |f|
      (File.expand_path(f) == __FILE__) ||
        f.start_with?(*%w[bin/ test/ spec/ features/ .git .circleci appveyor Gemfile])
    end
  end
  spec.require_paths = ['lib']

  spec.add_dependency 'rake', '~> 13.0'
  spec.add_dependency 'sqlite3', '~> 1.3'
  spec.add_development_dependency 'activerecord', '~> 7.1'
  spec.add_development_dependency 'minitest', '~> 5.0'
  spec.add_development_dependency 'rspec', '~> 3.5'
  spec.add_development_dependency 'rubocop', '~> 1'
end
