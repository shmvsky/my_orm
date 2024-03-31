# frozen_string_literal: true

require 'sqlite3'

module MyOrm
  class Database
    def self.connection(db_name)
      @db = SQLite3::Database.new db_name
    end

    # req - String -SQL ..request.. SQL
    def self.request(req)
      @db.execute(req)
    end
  end
end
