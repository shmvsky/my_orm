require_relative 'my_orm'

# MyOrm::Database.connection("test_db.db")
# class User < MyOrm::Record
# end
# User.read_the_table
# a = User.new
# puts User.instances.inspect

MyOrm::Configuration.establish_connection()

class MyRecord < MyOrm::Record

end

myRecord = MyRecord.new
myRecord.save
myRecord.update
myRecord.search
myRecord.delete