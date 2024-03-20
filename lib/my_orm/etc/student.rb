module MyOrm

  class Student
    @@table_name = 'students'
    @@pk = 'id'

    attr_accessor :id, :name, :surname, :yr

    def save
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

      @@db.execute(query)
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

    def self.connect_to_database
      @@db = SQLite3::Database.new ':memory:'
    end

    def self.populate_table
      begin
        @@db.transaction
        @@db.execute("CREATE TABLE IF NOT EXISTS students (id INTEGER PRIMARY KEY AUTOINCREMENT, name text NOT NULL, surname text NOT NULL, yr INTEGER NOT NULL);")
        @@db.execute("INSERT INTO students (name, surname, yr) VALUES ('Константин', 'Шумовский', 3);")
        @@db.execute("INSERT INTO students (name, surname, yr) VALUES ('Илья', 'Вязников', 3);")
        @@db.commit
      rescue SQLite::Exception
        @@db.rollback
      end
    end

    def self.show_table_data
      @@db.execute("SELECT * FROM students").each do |row|
        puts row.to_s
      end
    end

  end

end
