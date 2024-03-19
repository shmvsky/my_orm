require_relative 'configuration'
require_relative 'connection'

module MyOrm
  # Record - содержит реализации основных методов для работы с бд: create, where, update, delete
  class Record
    extend Configuration
    # Класс, делающий методы create_where
    class << self
      # create - метод, создающий строку в бд с задаными параметрами
      def create(**params)
        # params - {param1: => val1,param2: => val2....} - хэш из параметров и их значений
        querry = "insert into #{self} ()"

      end

      def where
        puts 'do search'
      end
    end

    def update()
      puts 'do update'
    end

    def delete()
      puts 'do delete'
    end

  end
end
