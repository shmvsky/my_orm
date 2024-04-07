# frozen_string_literal: true

require_relative 'table_load'
require_relative 'connection'
require_relative 'associations'

class String
  # ruby mutation methods have the expectation to return self if a mutation occurred, nil otherwise. (see http://www.ruby-doc.org/core-1.9.3/String.html#method-i-gsub-21)
  def underscore!
    gsub!(/(.)([A-Z])/, '\1_\2')
    downcase!
  end

  def underscore
    dup.tap(&:underscore!)
  end
end

module MyOrm
  class Record
    extend TableLoad
    extend Connection
    extend Associations
    include Associations

    def initialize(**args); end

    class << self
      def create(**args)
        obj = new
        args.each do |col, val|
          columns = :"@#{col}"
          obj.instance_variable_set(columns, val)
        end
        obj.save
      end

      def where(condition = nil, *values)
        query = "SELECT * FROM #{table_name}"
        # puts condition.frozen?
        condition = condition.dup
        if !condition.nil? && values.size.positive?
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

          inst = new(**instance_args)

          inst.is_saved = true

          inst.set_current_primary_keys

          instances << inst
        end

        instances
      end

      def delete(**args)
        set_of_keys = Set.new(args.keys)
        set_of_primary_keys = Set.new(column_info.reject do |_, info|
                                        info[-1].zero?
                                      end.keys.map { |col| col.to_s.delete('@').to_sym })

        raise 'Not a primary keys' if set_of_keys != set_of_primary_keys

        where_str = ''

        set_of_primary_keys.each do |col|
          where_str += "#{col} = #{args[col]} AND "
        end

        query = "DELETE FROM #{table_name} WHERE " + where_str[0...-5]

        Connection.execute(query)

        return if associated_tables.empty?

        associated_tables.each do |table_name, dependent|
          associated_delete(table_name, dependent, args)
        end

      end
    end

    def delete
      args = self.class.column_info.reject { |_, info| info[-1].zero? }
      args = args.inject({}) do |res, hash|
        res.merge({ hash[0].to_s.delete('@').to_sym => instance_variable_get(hash[0]) })
      end

      self.class.delete(**args)
    end

    def update(**args)
      args.each do |col, val|
        columns = :"@#{col}"
        instance_variable_set(columns, val)
      end
      save
    end

    def save
      query = if @is_saved
                save_another_calls
              else
                save_first_call
              end

      Connection.execute(query)

      # повторно объявить инициализацию pk
      # row_info - метод
      set_current_primary_keys

      @is_saved = true
      self
    end

    def set_current_primary_keys
      primary_keys.keys.each_with_index do |col, i|
        instance_variable_set(col, row_info[0][i]) unless is_saved
        current_primary_keys[col] = instance_variable_get(col)
      end
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

      "INSERT INTO #{self.class.table_name} (#{columns[0...-2]}) VALUES (#{values[0...-2]})"
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

      "UPDATE #{self.class.table_name} SET #{columns[0...-2]} WHERE #{where_str[0...-5]}"
    end

    def prepare_value_for_query(val)
      case val
      when String
        "'#{val}'"
      when Numeric
        val.to_s
      when NilClass
        'NULL'
      else
        raise 'Cast exception!'
      end
    end

    def row_info
      identification = MyOrm::Connection.execute 'SELECT last_insert_rowid();'
      Connection.execute("SELECT * FROM #{self.class.table_name} WHERE rowid = #{identification[0][0]};")
    end

    def primary_keys
      self.class.column_info.reject { |_, info| info[-1].zero? }
    end

    def necessary_fields
      instance_variables.reject { |x| %i[@is_saved @current_primary_keys].include?(x) }
    end

    def self.populate_students
      Connection.execute('CREATE TABLE IF NOT EXISTS students (id INTEGER,pp INTEGER, name text NOT NULL, surname text NOT NULL, yr INTEGER NOT NULL, PRIMARY KEY(id, pp));')
      Connection.execute("INSERT INTO students (name, surname, yr, pp,id) VALUES ('Константин', 'Шумовский', 3,5,1);")
      Connection.execute("INSERT INTO students (name, surname, yr, pp,id) VALUES ('Илья', 'Вязников', 3,5,2);")

      Connection.execute('CREATE TABLE IF NOT EXISTS marks (
        marks_id INTEGER,
        students_id INTEGER,
        students_pp INTEGER,
        mark INTEGER,
        PRIMARY KEY(marks_id));')

      Connection.execute("INSERT INTO marks (marks_id, students_id, students_pp, mark) VALUES (1,1,5,2);")
      Connection.execute("INSERT INTO marks (marks_id, students_id, students_pp, mark) VALUES (2,1,5,3);")

      # scholarships

      Connection.execute('CREATE TABLE IF NOT EXISTS scholarships (
        scholar_id INTEGER,
        students_id INTEGER,
        students_pp INTEGER,
        scholarship INTEGER,
        PRIMARY KEY(scholar_id));')

      Connection.execute("INSERT INTO scholarships (scholar_id, students_id, students_pp, scholarship) VALUES (1,1,5,2000);")
      Connection.execute("INSERT INTO scholarships (scholar_id, students_id, students_pp, scholarship) VALUES (2,1,5,3000);")
    end


    def self.show_students
      Connection.execute('SELECT * FROM students').each do |row|
        puts row.inspect
      end
    end

    def self.show_marks
      Connection.execute('SELECT * FROM marks').each do |row|
        puts row.inspect
      end
    end

    def self.show_scholarships
      Connection.execute('SELECT * FROM scholarships').each do |row|
        puts row.inspect
      end
    end
  end
end
