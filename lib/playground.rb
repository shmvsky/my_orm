require_relative 'my_orm'

class Users < MyOrm::Record

end
MyOrm::Connection.establish_connection('test.db')

Users.initialize_the_table

puts Users.columns.inspect
