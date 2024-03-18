require 'sqlite3'
require_relative 'configuration.rb'
require_relative 'record.rb'

module MyOrm
  module Connection
    @@db = nil

    def self.establish_connection(file)
      raise TypeError, 'String expected.' unless file.kind_of?(String)
      @@db = SQLite3::Database.new(file)
    end

    def self.connected?
      !@@db.nil?
    end


    def self.execute(querry)
      @@db.execute(querry)
    end

  end
end
