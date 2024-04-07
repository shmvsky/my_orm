# Что такое my_orm
my_orm упрощает создание и использование бизнес-объектов, данные которых требуют персистентного хранения в базе данных.

# API:

Чтобы ваш класс взаимодействовал с таблицей из бд,название таблицы должно быть в кемел кейсе, название класса должно быть написанео в снейк кейсе в единственном числе, т.е
если таблица в бд называется students, то название класса - Student.

Для подлкоючение к бд надо использовать MyOrm::Connection.establish_connection(path_to_database)

Для взаимодействия с бд используются следующие методы: save, update, delete, where, create

Для связки бд с классом-таблицей, класс нужно унаследовать от MyOrm::Record

class Student < MyOrm::Record

## Save - сохранение текущего экземпляра в бд.

stud = Student.new

stud.id = 5

stud.save # В бд добавлен студент с id = 5

stud.id = 2

stud.save # id обновлен у stud в бд

## Update - Обновляет атрибуты строки в бд

stud = Student.new(id:5, name: 'ilya')

stud.save

stud.update(id: 7, name: 'Kostyan') # строка в бд обновлена

## Create - создает строку в бд, с заданными параметрами

stud = Student.create(id: 5, name: 'ilya') # в бд появилась строка с соотв. стоблцами

## Delete - Удаляет строку из бд

stud = Student.create(id: 5, name: 'ilya')

stud.delete # строка из бд удалена

либо

Student.delete(id: 5) # Удаление происходит по primary_keys

## Where - Возвращает список экземпляров класса-таблицы по условию, соответствующие строкам из бд, удовлетворяющим условию

Student.where('id > ? AND name = ?', 2, 'Ilya') - массив экземпляров где id > 2 и name = 'Ilya'

## Ассоциации - Устанавливает связь между таблицами

class Student < MyOrm::Record
  has_many :Mark, dependent: :destroy - удаление всех зависимостей в таблице marks, при удалении родительского объекта

  has_many :Scholarship, dependent: :nullify - зануление внешних ключей, при удалении родительского объекта
  
  has_many :SomeTable, dependent: :restrict_with_exception - будет выкидываться исключение,если существуют зависимости в таблице
                                                              some_tables, при удалении родительского объекта
end

class Mark < MyOrm::Record
end

class Scholarship < MyOrm::Record
end

class SomeTable < MyOrm::Record
end


