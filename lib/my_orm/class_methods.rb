module My_Orm

    class Class_Methods
        attr_accessor :table_name

        def self.set_table_name(table_name)
            @table_name = table_name
        end

        def self.create_table(attr)
            structure = get_attr(attr)
            puts "create table #{@table_name} (#{structure} );"
            DataBase.request("create table #{@table_name} (
                #{structure} );"
            )
            meta_column_to_properties(attr,self)
        end
        #attr - HASH {COLUMN: TYPE}
        def self.get_attr(attr)
            str = ''
            commas = Array.new(attr.length,', ')
            commas[-1] = ' '
            i = 0
            attr.each do |key,value|
                str+= "#{key} #{value}" + commas[i]
                i+=1
            end
            str
        end


        def meta_column_to_properties(attr,class_name)
            attr.each do |key,_|
                class_name.class_eval do
                    attr_accessor "#{key}"
                end
            end
        end
    end

end

