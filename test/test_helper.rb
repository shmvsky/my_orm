# frozen_string_literal: true

$LOAD_PATH.unshift File.expand_path("../lib", __dir__)
require "my_orm"

require "minitest/autorun"

require_relative "my_orm\lib\my_orm\database"