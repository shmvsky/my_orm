# require_relative '../../my_orm'
require 'active_record'
require 'sqlite3'

require_relative 'student'

MyOrm::Student.connect_to_database
MyOrm::Student.populate_table

stud = MyOrm::Student.new
stud.id = 228
stud.name = 'Penis'
stud.surname = 'Cock'
stud.yr = 5

stud.save

stud.name = 'Suka'
stud.surname = 'Pidor'
stud.yr = 1

stud.save

MyOrm::Student.show_table_data

#================1=================
# module M
#   @@f = "1"
#   def self.foo
#     @@f = "2"
#   end
#
#   def self.bar
#     puts @@f
#   end
#
# end
#
# M.bar
# M.foo
# M.bar
#==================================



#================2=================
# module ClashOfClans
#   module GoldMine
#     def self.mine_some_gold
#       puts 'do mining'
#     end
#   end
#   class Village
#
#     def self.collect_gold
#       GoldMine.mine_some_gold
#     end
#   end
# end
#
# ClashOfClans::Village.collect_gold
#==================================


#================3=================
# puts MyOrm::Connection.connected?
# MyOrm::Connection.establish_connection("test.db")
# puts MyOrm::Connection.connected?
#==================================


#================4=================
# MyOrm::Connection.establish_connection('test.db')
#
# class Users < MyOrm::Record
#
# end
#
# Users.initialize_the_table
#
# puts Users.columns.inspect
#==================================
