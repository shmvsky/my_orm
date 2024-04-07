# frozen_string_literal: true
# frozen_string_literal: true

require_relative '..\lib\my_orm'

Rspec.cofigure do |config|
  config.filter_run fast: true
  config.run_all_when_everything_filtered = true
end
