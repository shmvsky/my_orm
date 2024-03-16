require_relative 'my_orm/database.rb'
require_relative 'my_orm/version.rb'
require_relative "my_orm/class_methods.rb"



module MyOrm
  class Error < StandardError; end
  # Your code goes here...
end

# My_Orm::DataBase.connection("test_db.db")


# class Users < My_Orm::Class_Methods
#
# end

# Users.read_the_table
# a = Users.new
# puts Users.instances.inspect

