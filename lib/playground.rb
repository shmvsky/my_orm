require_relative 'my_orm'

MyOrm::Database.connection("test_db.db")
class User < MyOrm::Record
end
User.read_the_table
a = User.new
puts User.instances.inspect