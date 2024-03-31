# frozen_string_literal: true

require 'sqlite3'
require_relative 'table_load'
require_relative 'record'

module MyOrm
  module Connection
    @@db = nil

    def self.db
      @@db
    end

    def self.close_db
      @@db = nil
    end

    def self.establish_connection(file)
      raise TypeError, 'String expected!' unless file.is_a? String

      @@db = SQLite3::Database.new(file)
    end

    def self.connected?
      !@@db.nil?
    end

    def self.execute(query)
      raise ConnectionException, 'Do connect!' unless connected?

      @@db.execute(query)
    end
  end
end
