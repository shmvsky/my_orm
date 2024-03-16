# frozen_string_literal: true

require_relative "lib/my_orm/version"

Gem::Specification.new do |spec|
  spec.name = "my_orm"
  spec.version = My_Orm::VERSION
  spec.authors = ["shmvsky","viaznikov"]

  spec.summary = "Реализация ORM в Ruby"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 2.6.0"

  spec.files = Dir.chdir(__dir__) do
    `git ls-files -z`.split("\x0").reject do |f|
      (File.expand_path(f) == __FILE__) ||
        f.start_with?(*%w[bin/ test/ spec/ features/ .git .circleci appveyor Gemfile])
    end
  end
  spec.require_paths = ["lib"]
  spec.add_dependency "zeitwerk", "~> 2.6"
  spec.add_dependency "sqlite3", "~> 1.3", ">= 1.3.11"

end
