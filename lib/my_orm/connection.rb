require 'sqlite3'
require_relative 'configuration.rb'
require_relative 'record.rb'

module MyOrm
  module Connection

    @@db = nil

    def self.db
      @@db
    end

    def self.establish_connection(file)
      raise TypeError, 'String expected.' unless file.kind_of? String
      @@db = SQLite3::Database.new(file)
    end

    def self.connected?
      !@@db.nil?
    end

    def self.execute(query)
      @@db.execute(query)
    end

    # def self.populate_db_with_test_data
    #
    #   raise PopulateException, "No database connected" unless connected?
    #
    #   data = TestData.new
    #
    #   begin
    #     @@db.transaction
    #     @@db.execute("CREATE TABLE IF NOT EXISTS #{data.table_name} (#{data.columns.join(', ')})")
    #     data.values.each.with_index do |row, idx|
    #       @@db.query("INSERT INTO #{data.table_name} (#{data.columns.join(', ')}) VALUES (#{idx+1}, #{"'" + row.join("', '") + "'"})")
    #     end
    #     @@db.commit
    #   rescue SQLite3::Exception => e
    #     @@db.rollback
    #     puts e
    #     raise PopulateException.new "Unexpected behavior while db populating"
    #   end
    #
    #   return proc{@@db.execute("DROP TABLE IF EXISTS #{data.table_name}")}
    #
    # end
    #
    # class TestData
    #   attr_reader :table_name, :columns, :values
    #   def initialize
    #     @table_name = 'students'
    #     @columns = %w[id name surname yr]
    #     @values = [
    #       ['Константин', 'Шумовский', 3],
    #       [ 'Илья', 'Вязников', 3],
    #       ['Василий', 'Алферов', 2],
    #       ['Роман', 'Зудин', 2],
    #       ['Илья', 'Иванов', 3],
    #       ['Леонид', 'Крупнов', 3],
    #       ['Эдуард', 'Очиров', 2]
    #     ]
    #   end
    # end

    # def self.do_transaction(&block)
    #
    #   begin
    #     @@db.transaction
    #     block.call
    #     @@db.commit
    #   rescue SQLite3::Exception => e
    #
    #     puts "Exception occurred"
    #     puts e
    #     @@db.rollback
    #
    #   ensure
    #     @@db.close if db
    #   end
    #
    # end

  end
end
