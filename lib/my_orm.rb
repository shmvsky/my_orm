require_relative 'my_orm/database.rb'
require_relative 'my_orm/version.rb'
require_relative "my_orm/class_methods.rb"



My_Orm::DataBase.connection("test_db.db")


class Users < My_Orm::Class_Methods

end

Users.read_the_table
a = Users.new
puts Users.instances.inspect

