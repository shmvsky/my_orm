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
    extend Configuration
    extend Connection

    class << self
      def create(**args)
        obj = new
        args.each do |col,val|
          columns = :"@#{col}"
          obj.instance_variable_set(columns,val)
        end
        obj.save
      end


      def delete(**args)
        set_of_keys = Set.new args.map{|col,val| col}
        set_of_primary_keys = Set.new column_info.select{|col,info| info[-1] != 0}.keys.map{|col| col.to_s.delete('@').to_sym}

        if set_of_keys != set_of_primary_keys
          raise 'Not a primary keys'
        end

        where_str = ''

        set_of_primary_keys.each do |col|
          where_str += "#{col} = #{args[col]} AND "
        end

        query = "DELETE FROM #{table_name} WHERE " + where_str[0...-5]

        Connection.execute(query)

      end
    end

    define_method :delete do
      args = self.class.column_info.select{|col,info| info[-1] != 0}.inject({}){|res,hash| res.merge({hash[0].to_s.delete('@').to_sym => instance_variable_get(hash[0])})}
      puts args.inspect
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
      columns = ""
      values = ""
      unless @is_saved
        instance_variables.each do |k|
          col_name = k.to_s.delete('@')
          columns += "#{col_name}, "
          v = instance_variable_get(k)
          if v.is_a?(String) || v.is_a?(Symbol)
            values += "'#{v}', "
          elsif v.is_a? Numeric
            values += "#{v}, "
          else
            raise 'Cast exception!'
          end
        end

        query = "INSERT INTO #{self.class.class_variable_get("@@table_name")} (#{columns[0...-2]}) VALUES (#{values[0...-2]})"
        @is_saved = true
      else
        where_str = ''
        instance_variables.reject{|x| x == :@is_saved}.each do |k|
          col_name = k.to_s.delete('@')
          v = instance_variable_get(k)
          if self.class.column_info[k][-1] != 0
            where_str += "#{col_name} = #{instance_variable_get(k)} AND "
          elsif v.is_a?(String)
            columns += "#{col_name} = '#{v}', "
          elsif v.is_a?(Numeric)
           # puts "VVV #{v}"
            columns += "#{col_name} = #{v}, "
          else 
            puts "ERROR #{k} VAL: #{v}"
            raise 'Cast exception!'
          end
          #puts columns
   
        end
        query = "UPDATE #{self.class.class_variable_get("@@table_name")} SET #{columns[0...-2]} WHERE #{where_str[0...-5]}"
      end

      puts query

      Connection.execute(query)
      if @is_saved
        # повторно объявить инициализацию pk
        identification = MyOrm::Connection.execute "SELECT last_insert_rowid();"
        row_info = Connection.execute("SELECT * FROM #{self.class.class_variable_get(:@@table_name)} WHERE rowid = #{identification[0][0]};")
        pks = self.class.column_info.select{|col,info| info[-1] != 0}
        #puts "PKS :#{pks}"
        pks.each_key do |col| i = 0
          instance_variable_set(col,row_info[0][i])
          i += 1
        end
      end
      self
    end

    def self.populate_students
      Connection.execute("CREATE TABLE IF NOT EXISTS students (id INTEGER PRIMARY KEY AUTOINCREMENT, name text NOT NULL, surname text NOT NULL, yr INTEGER NOT NULL);")
      Connection.execute("INSERT INTO students (name, surname, yr) VALUES ('Константин', 'Шумовский', 3);")
      Connection.execute("INSERT INTO students (name, surname, yr) VALUES ('Илья', 'Вязников', 3);")
    end

    def self.show_students
      Connection.execute("SELECT * FROM students").each do |row|
        puts row.inspect
      end
    end

  end
end
