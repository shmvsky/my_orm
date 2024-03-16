# frozen_string_literal: true

require_relative "test_helper"

class TestMyOrm < Minitest::Test
  def test_that_it_has_a_version_number
    refute_nil ::MyOrm::VERSION
  end

  def test_it_does_something_useful
    assert true
  end


  # def test_that_it_creats_a_database
  #   obj = SQlite3::Database.new
  #   obj1 = MyOrm::DataBase.connection(test_db.db)
  #
  #   assert obj.class,obj1.class
  #
  # end
end
