# require_relative '../../my_orm'
require 'active_record'
require 'sqlite3'

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

# ActiveRecord::Base.establish_connection(:adapter => 'sqlite3', :database => ':mem:')

module MyOrm
  class Student
    @@table_name = 'students'
    @@pk = 'id'

    attr_accessor :id, :name, :surname, :yr

    def save(db)
      columns = ""
      values = ""

      instance_variables.each do |k|
        col_name = k.to_s.delete('@')
        if col_name != @@pk
          columns += "#{col_name}, "
          v = instance_variable_get(k)
          if v.is_a? String || v.is_a? == Symbol
            values += "'#{v}', "
          elsif v.is_a? Numeric
            values += "#{v}, "
          else
            raise 'Cast exception!'
          end
        end

      end

      query = "INSERT INTO #{@@table_name} (#{columns[0...-2]}) VALUES (#{values[0...-2]})"

      db.execute(query)
    end

    def self.where
      puts 'searching'
    end

    def update
      puts 'updating'
    end

    def delete
      puts 'deleting'
    end
  end
end

db = SQLite3::Database.new ':memory:'

begin
  db.transaction
  db.execute("CREATE TABLE IF NOT EXISTS students (id INTEGER PRIMARY KEY AUTOINCREMENT, name text NOT NULL, surname text NOT NULL, yr INTEGER NOT NULL);")
  db.execute("INSERT INTO students (name, surname, yr) VALUES ('Константин', 'Шумовский', 3);")
  db.execute("INSERT INTO students (name, surname, yr) VALUES ('Илья', 'Вязников', 3);")
  db.commit
rescue SQLite::Exception
  db.rollback
end


stud = MyOrm::Student.new
stud.id = 228
stud.name = 'Penis'
stud.surname = 'Cock'
stud.yr = 5

stud.save db

db.execute("SELECT * FROM students").each do |row|
  puts row.to_s
end

db.close