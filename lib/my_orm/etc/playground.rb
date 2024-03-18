require_relative '../../my_orm'

# MyOrm::Configuration.establish_connection("../../../data/test.db")
#
# class MyRecord < MyOrm::Record
#
# end
#
# myRecord = MyRecord.new
# myRecord.save
# myRecord.update
# myRecord.search
# myRecord.delete

module T

  def aboba
    @field = 228
  end

end

class C

  include T

end

c = C.new
c.aboba