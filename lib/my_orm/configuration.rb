require_relative 'connection'
require_relative 'record'

module MyOrm
    # Configuration - модуль, инициализирующий класс-таблицу
    module Configuration
        # initialize_the_table - метод, инициализирующий класс-таблицу
        def initialize_the_table
            initialize_the_fields
            initialize_the_getter
            create_the_fields
        end

        # initialize_the_fields - метод, инициализирующий статическое поле columns классе-таблице
        private
        def initialize_the_fields
            class_variable_set(:@@columns, {})
        end
        # initialize_the_getter - метод, создающией геттер для статического поля columns
        def initialize_the_getter
            define_singleton_method :columns do
                class_variable_get(:@@columns)
            end
        end

        # set_attr - метод, создающий поля класса-таблицы по столбцам таблицы
        def create_the_fields
            table_info = Connection.execute("PRAGMA table_info(#{self})")
            table_info.each{ |column| columns.merge!(primary_key_helper(column)) }

            columns.each do |column, descrip|
                class_eval do
                    attr_accessor descrip.is_a?(Hash) ? descrip.keys[0] : column
                end
            end
        end
        # primary_key_helper - метод, возвращающий нужный хэш, в зависимости от primary_key столбца
        def primary_key_helper(column)
            # column - [rowid,name,type,..,primary_key?]
            column[-1] == 1 ? {primary_key: { column[1].to_s => column[2]}} : { column[1].to_s => column[2]}
        end
    end
end
