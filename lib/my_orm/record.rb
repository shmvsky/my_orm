require_relative 'configuration'
require_relative 'connection'

class String
  # ruby mutation methods have the expectation to return self if a mutation occurred, nil otherwise. (see http://www.ruby-doc.org/core-1.9.3/String.html#method-i-gsub-21)
  def underscore!
    gsub!(/(.)([A-Z])/,'\1_\2')
    downcase!
  end

  def underscore
    dup.tap { |s| s.underscore! }
  end
end

module MyOrm
  class Record

    def self.establish_connection db
      @@db = SQLite3::Database.new db
    end

    def initialize
      if Record.connected?
        load_fields
      else
        raise 'do connect!!!!'
      end
    end

    def self.connected?
      if defined? @@db
        true
      end
    end

    def load_fields
      #В КЛАССЕ БУДЕТ ХРАНИТЬСЯ НАЗВАНИЕ ТАБЛИЦЫ, К КОТОРОЙ ОН ОТНОСИТСЯ
      self.class.class_variable_set("@@table_name", self.class.to_s.underscore + 's')

      #ПОЛУЧАЕМ ИНФУ О ТАБЛИЦЕ
      table_info = @@db.execute("PRAGMA table_info(#{self.class.class_variable_get("@@table_name")})")

      #ВЫВОДИМ ИНФУ О ТАБЛИЦЕ ДЕБАГА РАДИ
      puts table_info.to_s

      #ПЕРЕБИРАЕМ ИНФУ О КОЛОНКАХ ТАБЛИЦЫ
      table_info.each do |col_info|
        col_name = col_info[1]
        not_pk = col_info[3]

        #ОПРЕДЕЛЯЕМ НАШ ПЕРВИЧНЫЙ КЛЮЧИК КАК ПЕРЕМЕННУЮ КЛАССА
        if not_pk.zero?
          self.class.class_variable_set("@@primary_key", col_name)
        end

        #ХУЯРИМ ПЕРЕМЕННЫЕ ОБЪЕКТА
        self.instance_variable_set("@#{col_name}", nil)

        #ХУЯРИМ ГЕТТЕРЫ
        self.define_singleton_method :"#{col_name}" do ||
          self.instance_variable_get("@#{col_name}")
        end

        #ХУЯРИМ СЕТТЕРЫ
        self.define_singleton_method :"#{col_name}=" do |value|
          self.instance_variable_set("@#{col_name}", value)
        end

      end

      #ОПЯТЬ ДЕБАГ. ВЫВОДИМ СПИСОК ПЕРЕМЕННЫХ И МЕТДОВ ОБЪЕКТА И КЛАССА
      puts self.instance_variables.to_s
      puts self.singleton_methods.to_s
      puts self.class.class_variables.to_s
      puts self.class.methods.to_s

    end

    def save
      columns = ""
      values = ""

      instance_variables.each do |k|
        col_name = k.to_s.delete('@')
        if col_name != self.class.class_variable_get("@@primary_key")
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

      query = "INSERT INTO #{self.class.class_variable_get("@@table_name")} (#{columns[0...-2]}) VALUES (#{values[0...-2]})"

      puts query

      @@db.execute(query)
    end

    def self.populate_students
      @@db.execute("CREATE TABLE IF NOT EXISTS students (id INTEGER PRIMARY KEY AUTOINCREMENT, name text NOT NULL, surname text NOT NULL, yr INTEGER NOT NULL);")
      @@db.execute("INSERT INTO students (name, surname, yr) VALUES ('Константин', 'Шумовский', 3);")
      @@db.execute("INSERT INTO students (name, surname, yr) VALUES ('Илья', 'Вязников', 3);")
    end

    def self.show_students
      @@db.execute("SELECT * FROM students").each do |row|
        puts row.to_s
      end
    end

  end
end
