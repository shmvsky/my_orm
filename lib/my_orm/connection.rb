require 'sqlite3'
require_relative 'table_load.rb'
require_relative 'record.rb'

module MyOrm
  module Connection

    def self.db
      @@db
    end

    def self.establish_connection(file)
      raise TypeError, 'String expected!' unless file.kind_of? String
      @@db = SQLite3::Database.new(file)
    end

    def self.connected?
      !(defined? @@db).nil?
    end

    def self.execute(query)
      raise ConnectionException, 'Do connect!' unless connected?
      @@db.execute(query)
    end

  end
end
