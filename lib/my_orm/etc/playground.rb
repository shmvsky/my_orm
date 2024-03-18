require_relative '../../my_orm'

#================1=================
module M
  @@f = "1"
  def self.foo
    @@f = "2"
  end

  def self.bar
    puts @@f
  end

end

M.bar
M.foo
M.bar
#==================================



#================2=================
module ClashOfClans
  module GoldMine
    def self.mine_some_gold
      puts 'do mining'
    end
  end
  class Village

    def self.collect_gold
      GoldMine.mine_some_gold
    end
  end
end

ClashOfClans::Village.collect_gold
#==================================

#================3=================
puts MyOrm::Connection.connected?
MyOrm::Connection.establish_connection("test.db")
puts MyOrm::Connection.connected?
#==================================