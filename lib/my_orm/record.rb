require_relative 'table_load'
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
    extend TableLoad
    extend Connection

    def initialize(**args)
    end

    class << self
      def create(**args)
        obj = new
        args.each do |col,val|
          columns = :"@#{col}"
          obj.instance_variable_set(columns,val)
        end
        obj.save
      end

      def where(condition = nil, values = [])

        query = "SELECT * FROM #{table_name}"

        if !condition.nil? && values.size > 0
          values.each do |val|
            val = "'#{val}'" if val.is_a? String
            condition.sub!(/\?/, val.to_s)
          end
          query += " WHERE #{condition};"
        end

        instances = []

        rows = Connection.execute(query)

        rows.each do |r|
          instance_args = {}
          r.each.with_index do |val, idx|
            instance_args[instance_variables[idx].to_s.delete('@')] = val
          end
          inst = new(args: instance_args)
          inst.saved = true

          inst.primary_keys.keys.each do |col|
            inst.current_primary_keys[col] = inst.instance_variable_get(col)
          end

          instances << inst
        end

        instances

      end

      def delete(**args)
        set_of_keys = Set.new(args.keys)
        set_of_primary_keys = Set.new(column_info.reject{ |_, info| info[-1].zero? }.keys.map{ |col| col.to_s.delete('@').to_sym })

        raise 'Not a primary keys' if set_of_keys != set_of_primary_keys

        where_str = ''

        set_of_primary_keys.each do |col|
          where_str += "#{col} = #{args[col]} AND "
        end

        query = "DELETE FROM #{table_name} WHERE " + where_str[0...-5]

        Connection.execute(query)
      end
    end

    define_method :delete do
      args = self.class.column_info.reject{ |_,info| info[-1].zero? }
      args = args.inject({}) { |res, hash| res.merge({ hash[0].to_s.delete('@').to_sym => instance_variable_get(hash[0]) })}
      self.class.delete(**args)
    end

    def update(**args)
        args.each do |col,val|
          columns = :"@#{col}"
          instance_variable_set(columns,val)
        end
        save
    end

    def save
      if @is_saved
        save_another_calls
      else
        save_first_call
      end
      self
    end

    def saved?
      @is_saved
    end

    def saved=(bool_val)
      @is_saved = bool_val
    end

    def save_first_call
      columns = ''
      values = ''
      necessary_fields.each do |k|
        col_name = k.to_s.delete('@')
        columns += "#{col_name}, "
        v = instance_variable_get(k)
        values += "#{prepare_value_for_query(v)}, "
      end

      query = "INSERT INTO #{self.class.table_name} (#{columns[0...-2]}) VALUES (#{values[0...-2]})"

      @is_saved = true
      Connection.execute(query)
      # повторно объявить инициализацию pk
      #row_info - метод
      primary_keys.keys.each_with_index do |col, i|
        instance_variable_set(col, row_info[0][i])
        current_primary_keys[col] = instance_variable_get(col)
      end
    end

    def save_another_calls
      where_str = ''
      columns = ''
      necessary_fields.each do |k|
          col_name = k.to_s.delete('@')
          v = instance_variable_get(k)

          where_str += "#{col_name} = #{current_primary_keys[k]} AND " if self.class.column_info[k][-1] != 0

          columns += "#{col_name} = #{prepare_value_for_query(v)}, "
        end

        query = "UPDATE #{self.class.table_name} SET #{columns[0...-2]} WHERE #{where_str[0...-5]}"
        Connection.execute(query)

        primary_keys.keys.each do |col|  
          current_primary_keys[col] = instance_variable_get(col)
        end
    end

    def prepare_value_for_query(val)
      if val.is_a?(String)
        "'#{val}'"
      elsif val.is_a? Numeric
        "#{val}"
      else
        raise 'Cast exception!'
      end
    end

    def row_info
      identification = MyOrm::Connection.execute "SELECT last_insert_rowid();"
      Connection.execute("SELECT * FROM #{self.class.table_name} WHERE rowid = #{identification[0][0]};")
    end

    def primary_keys
      self.class.column_info.reject{|_, info| info[-1].zero?}
    end

    def necessary_fields
      instance_variables.reject{|x| [:@is_saved, :@current_primary_keys].include?(x)}
    end

    def self.populate_students
      Connection.execute("CREATE TABLE IF NOT EXISTS students (id INTEGER,pp INTEGER, name text NOT NULL, surname text NOT NULL, yr INTEGER NOT NULL, PRIMARY KEY(id, pp));")
      Connection.execute("INSERT INTO students (name, surname, yr, pp,id) VALUES ('Константин', 'Шумовский', 3,5,1);")
      Connection.execute("INSERT INTO students (name, surname, yr, pp,id) VALUES ('Илья', 'Вязников', 3,5,2);")
    end

    def self.populate_penis
      Connection.execute("CREATE TABLE IF NOT EXISTS penis (name TEXT, age INTEGER);")
      Connection.execute("INSERT INTO penis (name, age) VALUES ('Константин', 20);")
      Connection.execute("INSERT INTO penis (name, age) VALUES ('Илья', 20);")
      Connection.execute("INSERT INTO penis (name, age) VALUES ('Леонид', 30);")
    end

    def self.show_students
      Connection.execute("SELECT * FROM students").each do |row|
        puts row.inspect
      end
    end
  end
end
