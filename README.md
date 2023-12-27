# Шпоргалка Mongo DB
MongoDB (от _«humongous»_,  _«huge»_ (гигантский) и _«monstrous»_ (чудовищный))- это документная база данных, которая позволяет хранить и опрашивать вложенные данные, предъявляя произвольные запросы.  
Если вы работаете в стартапе, который лелеет грандиозные планы или уже накопил столько данных, что возникла потребность в горизонтальном масштабировании, то присмотритесь к MongoDB.  

## Установка и подключение
```bash
$ docker compose up -d --remove-orphans
$ docker compose exec -it mongo bash -c "mongosh -u root -p example"
> use <имя коллекции>
```

## Навигация
`help` - показать справку  
`show dbs` - показать все базы данных  
`use <db>` - переключиться на другую базу данных  


## CRUD

### Создание коллекций, добавление в неё данных
```bash
db.towns.insertOne({
    name: "New York",
    population: 22200000,
    last_census: ISODate("2009-07-31"),
    famous_for: [ "statue of liberty", "food" ],
    mayor : {
        name : "Michael Bloomberg",
        party : "I"
    }
})
```
Документы хранятся в формате JSON (точнее, BSON), поэтому в таком формате мы их и добавляем.  
**{...}** - объект (аналог ассоциативного массива или хеш-таблицы), содержащий ключи и значения  
**[...]** - линейный массив  


### Чтение коллекций
`show collections` - показать все коллекции  
`db.towns.find()` - просмотреть содержимое коллекции  
В отличие от реляционных СУБД, Mongo не поддерживает соединения на стороне сервера. Один вызов JavaScript-функции извлекает документ и все вложенные в него данные. 

Поле `_id` типа `ObjectId` -  занимает 12 байтов и состоит из временной метки, идентификатора клиентской машины, идентификатора клиентского процесса и 3-байтового
инкрементируемого счетчика.

#### Java Script

##### Объекты
```javascript
> typeof db
object
> typeof db.towns
object
> typeof db.towns.insert
function
```


##### Функции
Определение
```javascript
function insertCity(
    name, population, last_census,
    famous_for, mayor_info
) {
    db.towns.insertOne({
    name: name,
    population: population,
    last_census: ISODate(last_census),
    famous_for: famous_for,
    mayor: mayor_info
    });
}
```
Использование
```javascript
> insertCity("Punxsutawney", 6200, '2008-01-31',
    ["phil the groundhog"], { name : "Jim Wehrle" }
)
```


### Чтение элемента коллекций
#### Получить объект целиком  
```javascript
> db.towns.find({ "_id" : ObjectId("658ae5321dd32f4b00991ddd") })
```
#### Получить определенные поля в объекте  
```javascript
> db.towns.find({ "_id" : ObjectId("658ae5321dd32f4b00991ddd") }, {name : 1})
```
#### Получить все поля в объекте кроме определенных  
```javascript
> db.towns.find({ "_id" : ObjectId("658ae5321dd32f4b00991ddd") }, {name : 0})
```
#### Фильтрация вывода по регулярным выражениям PCRE и операторам диапазона  
```javascript
> db.towns.find(
{ name : /^P/, population : { $lt : 10000 } },
{ name : 1, population : 1 }
)
```
Условные операторы в Mongo  
```field : { $op : value }```,  
где `$op` – операция, например `$ne` (не равно).

#### Конструирование условия как объекта
```javascript
var population_range = {}
population_range['$lt'] = 1000000
population_range['$gt'] = 10000
db.towns.find(
    { name : /^P/, population : population_range },
    { name: 1 }
)
```
С диапазоном дат
```javascript
db.towns.find(
{ last_census : { $lte : ISODate('2008-01-31') } },
{ _id : 0, name: 1 }
)
```


#### Запрос для фильтра по вложенному массиву
##### Сравнение с конкретным значением
```javascript
db.towns.find(
{ famous_for : 'food' },
{ _id : 0, name : 1, famous_for : 1 }
)
```


##### Сравнение с подстрокой
```javascript
db.towns.find(
{ famous_for : /statue/ },
{ _id : 0, name : 1, famous_for : 1 }
)
```

##### Совпадение каждого из нескольких значений
```javascript
db.towns.find(
{ famous_for : { $all : ['food', 'beer'] } },
{ _id : 0, name:1, famous_for:1 }
)
```

##### Несовпадение ни с одним из указанных значений
```javascript
db.towns.find(
{ famous_for : { $nin : ['food', 'beer'] } },
{ _id : 0, name : 1, famous_for : 1 }
)
```

##### Фильтр по глубоко вложенным структурам
```javascript
db.towns.find(
{ 'mayor.party' : 'I' },
{ _id : 0, name : 1, mayor : 1 }
)
```
```javascript
db.towns.find(
{ 'mayor.party' : { $exists : false } },
{ _id : 0, name : 1, mayor : 1 }
)
```
