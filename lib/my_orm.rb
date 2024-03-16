require_relative 'my_orm/database.rb'
require_relative 'my_orm/version.rb'
require_relative "my_orm/class_methods.rb"



module My_Orm
  class Error < StandardError; end
  # Your code goes here...
end

My_Orm::DataBase.connection("test_db.db")

class MyClass < My_Orm::Class_Methods
 
end
MyClass.set_table_name "Users2"

MyClass.create_table({name:"varchar(30)",id:"INTEGER",age:"INTEGER"})
puts MyClass.get_attr({name:"varchar",id:"int",age:"int"})
