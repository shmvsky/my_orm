require 'sqlite3'

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

  end
end
