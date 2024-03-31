# frozen_string_literal: true

require_relative '../../my_orm'
# require 'active_record'
# require 'sqlite3'

#==================================

MyOrm::Connection.establish_connection ':memory:'

MyOrm::Record.populate_students

# MyOrm::Record.show_students

class Student < MyOrm::Record
end

# MyOrm::Record.populate_penis

# class Peni < MyOrm::Record
# end

# Peni.create(name: 'Aboba', age: 228)
#
# p = Peni.new(age: 17, name: "Писюнкин")
# p.save

# Peni.where.each do |p|
#   puts p.inspect
# end

# Student.where.each do |s|
#   s.save
# end


# puts Peni.where(20, condition: "age = ?")[0].inspect

# puts p.instance_variables.inspect

# def foo(**args)
#   args.each do |k, v|
#     puts "#{k}: #{v}"
#   end
# end
#
# foo(name: "awd", age: 228)

# Peni.where("NAME = ? AND AGE = ?", 'Константин', 20)

# stud = Student.new
# stud.id = 2
# stud.pp = 6
# stud.name = "NIK"
# stud.surname = "POK"
# stud.yr = 52
# stud.save


# MyOrm::Record.show_students

# Student.where('? >= 2', 'id')


# stud = Student.new


# stud.name = "gon"
# stud.surname = "don"
# stud.yr = 52

# stud.save

# stud.name = "ppp"

# stud.save

# stud1 = Student.new

# stud1.name = "PEPO"
# stud1.surname = "PEPO"
# stud1.yr = 51
# stud1.id = 11

# stud1.save

# stud2 = Student.new

# stud2.name = "KEKO"
# stud2.surname = "KEKO"
# stud2.yr = 51
# stud2.id = 32

# stud2.save

# puts "======================="
# MyOrm::Record.show_students

# stud1.name ="andruha"
# stud1.surname = "kosygin"
# stud1.save







# puts "======================="
# MyOrm::Record.show_students

# student.instance_variable_set(:@id, 228)
# student.instance_variable_set(:@name, 'Попка')
# student.instance_variable_set(:@surname, 'Крутая')
# student.instance_variable_set(:@yr, 4)
#
# student.instance_variables.each do |var|
#   puts "#{var}: #{student.instance_variable_get(var)}"
# end

# class B
#
#   def self.benis
#     @@b = 'hello'
#   end
#
#   def b
#     @@b
#   end
#
#   def k
#     B.benis
#   end
#
# end
#
# bb = B.new
# bb.k
# puts bb.b

# #================7=================
# require_relative 'student'
#
# MyOrm::Student.connect_to_database
# MyOrm::Student.populate_table
#
# stud = MyOrm::Student.new
# stud.id = 228
# stud.name = 'Penis'
# stud.surname = 'Cock'
# stud.yr = 5
#
# stud.save
#
# stud.name = 'Suka'
# stud.surname = 'Pidor'
# stud.yr = 1
#
# stud.save
#
# MyOrm::Student.show_table_data
# #==================================

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
