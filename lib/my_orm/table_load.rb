require_relative 'connection'
require_relative 'record'

module MyOrm
    # Configuration - модуль, инициализирующий класс-таблицу
    module TableLoad
        def inherited(descendant)
            if Connection.connected?
                descendant.load_fields
            else
              raise 'do connect!!!!'
            end
        end

        def load_fields
            # В КЛАССЕ БУДЕТ ХРАНИТЬСЯ НАЗВАНИЕ ТАБЛИЦЫ, К КОТОРОЙ ОН ОТНОСИТСЯ
            class_variable_set(:@@table_name, self.to_s.underscore + 's')

            define_singleton_method :table_name do 
                class_variable_get(:@@table_name)
            end

            
            class_eval do 
                attr_reader :current_primary_keys,:is_saved

                def initialize(args: {})
                    # СОЗДАНИЕ ПОЛЯ, ДЛЯ ХРАНЕНИЯ ТЕКУЩИХ ЗНАЧЕНИЙ PRIMARY КЛЮЧЕЙ (ИСПОЛЬЗУЕТСЯ ПРИ ИЗМЕНЕНИИ PRIMARY КЛЮЧЕЙ)
                    @current_primary_keys = {}
                    # СЛУЖЕБНОЕ ПОЛЕ С ИНФОРМАЦИЕЙ, БЫЛ ЛИ НА ЭКЗЕМПЛЯРЕ ВЫЗВАН МЕТОД SAVE
                    @is_saved = false

                    if args.size > 0
                        args.each do |col,val|
                            col_name = :"@#{col}"
                            self.instance_variable_set(col_name, val)
                        end
                    end

                end

            end

            # ПОЛУЧАЕМ ИНФУ О ТАБЛИЦЕ
            table_info = Connection.execute("PRAGMA table_info(#{table_name})")

            # СОЗДАЕМ СЛУЖЕБНОЕ ПОЛЕ С ИНФОРМАЦИЕЙ О СТОЛБЦАХ {NAME:[INFO1,INFO2..],...}
            class_variable_set(:@@column_info, {})

            define_singleton_method :column_info do 
                class_variable_get(:@@column_info)
            end

            table_info.each do |col_info|
                col_name = '@' + col_info[1]
                column_info.merge!({col_name.to_sym => col_info})
            end

            # ПЕРЕБИРАЕМ ИНФУ О КОЛОНКАХ ТАБЛИЦЫ
            table_info.each do |col_info|
                col_name = col_info[1]

                # ХУЯРИМ ПЕРЕМЕННЫЕ ОБЪЕКТА
                instance_variable_set("@#{col_name}", nil)

                # ХУЯРИМ ГЕТТЕРЫ
                define_method :"#{col_name}" do
                    instance_variable_get("@#{col_name}")
                end

                # ХУЯРИМ СЕТТЕРЫ
                define_method :"#{col_name}=" do |value|
                    instance_variable_set("@#{col_name}", value)
                end
            end



        end
    end
end
