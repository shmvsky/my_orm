module MyOrm
    class ClassMethods
        attr_accessor :table_name

         def self.read_the_table
            info_about_columns = DataBase.request("PRAGMA table_info(#{self.to_s})")
            info_about_rows = DataBase.request("select * from #{self}")
            meta_create(self,info_about_columns,info_about_rows)
         end

         def self.add_field(table_name,field_name)
            class_eval do
                attr_accessor field_name.to_sym
            end
         end

         def self.meta_create(table_name,info_about_columns,info_about_rows)
            columns = []
            info_about_columns.each do |column|
                columns << column[1]
                add_field(table_name,column[1])
            end

            create_the_instances(columns,info_about_rows)
         end

         def self.create_the_instances(field_names,info_about_instance)
            info_about_instance.each do |row|
                create_the_instance(row,field_names)
            end
         end

         def self.create_the_instance(row,field_names)
            instance = new
            row.length.times do |i|
                instance.instance_variable_set("@#{field_names[i]}",row[i])
            end
         end
         
    end

end

