require_relative 'connection'
require_relative 'record'

module MyOrm
    # Configuration - модуль, инициализирующий класс-таблицу
    module Configuration
        def inherited(descendant)
            if Connection.connected?
                descendant.load_fields
            else
              raise 'do connect!!!!'
            end
        end

        def load_fields
            #В КЛАССЕ БУДЕТ ХРАНИТЬСЯ НАЗВАНИЕ ТАБЛИЦЫ, К КОТОРОЙ ОН ОТНОСИТСЯ
            class_variable_set(:@@table_name, self.to_s.underscore + 's')

            #ПОЛУЧАЕМ ИНФУ О ТАБЛИЦЕ
            table_info = Connection.execute("PRAGMA table_info(#{class_variable_get("@@table_name")})")

            #СОЗДАЕМ СЛУЖЕБНОЕ ПОЛЕ С ИНФОРМАЦИЕЙ О СТОЛБЦАХ {NAME:[INFO1,INFO2..],...}
            class_variable_set(:@@column_info,{})

            #СЛУЖЕБНОЕ ПОЛЕ С ИНФОРМАЦИЕЙ, БЫЛ ЛИ НА ЭКЗЕМПЛЯРЕ ВЫЗВАН МЕТОД SAVE
            instance_variable_set(:@is_saved,false)

            define_singleton_method :column_info do 
                class_variable_get(:@@column_info)
            end

            table_info.each do |col_info|
                col_name = '@' + col_info[1]
                column_info.merge!({col_name.to_sym => col_info})
            end

            #ВЫВОДИМ ИНФУ О ТАБЛИЦЕ ДЕБАГА РАДИ
            #puts table_info.inspect

            #ПЕРЕБИРАЕМ ИНФУ О КОЛОНКАХ ТАБЛИЦЫ
            table_info.each do |col_info|
                col_name = col_info[1]

                #ХУЯРИМ ПЕРЕМЕННЫЕ ОБЪЕКТА
                instance_variable_set("@#{col_name}", nil)

                #ХУЯРИМ ГЕТТЕРЫ
                define_method :"#{col_name}" do
                    instance_variable_get("@#{col_name}")
                end

                #ХУЯРИМ СЕТТЕРЫ
                define_method :"#{col_name}=" do |value|
                    instance_variable_set("@#{col_name}", value)
                end
            end

        end
    end
end
