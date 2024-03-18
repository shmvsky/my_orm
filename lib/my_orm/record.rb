module MyOrm
  class Record

    class << self
      def create
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
