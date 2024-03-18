require 'sqlite3'

module MyOrm
  module Connection

    def establish_connection(file)
      raise TypeError, 'String expected.' unless file.kind_of?(String)

      @db = SQLite3::Database.new(file)
    end
  end
end
