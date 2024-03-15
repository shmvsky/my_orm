# frozen_string_literal: true

require_relative "lib/my_orm/version"

Gem::Specification.new do |spec|
  spec.name = "my_orm"
  spec.version = MyOrm::VERSION
  spec.authors = ["shmvsky"]

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

end
