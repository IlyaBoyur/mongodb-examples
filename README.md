# Шпоргалка Mongo DB
Примечание. Все комментарии относятся к базе данных MongoDB v 7.0.4

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

## Функции базы данных
`db.help()` - показать справку для методов базы данных.  
Некоторые полезные методы:  
`db.getCollectionInfos()` - показать массив с информацией о коллекциях в текущей базе данных  
`db.dropDatabase()` - удалить текущую базу данных со всем ассоциированными файлами  
`db.getUsers()` - показать информацию обо всех пользователях в текущей базе данных  
`db.isMaster()` - показать стутусную информацию текущего узла-мастера  
`db.serverBuildInfo()` - показать информацию о версии и окружении сборки  
`db.serverStatus()` - показать статистику сервера  


## Функции коллекций
`db.collections.help()` - показать справку для методов коллекций БД (базы данных). Обычно эти методы вызываются через синтаксис `db.<имя коллекции>.<имя метода>`. Частые примеры использования приведены ниже.  
Некоторые необычные полезные методы:  
`db.<имя коллекции>.isCapped()` - показать, является ли коллекция циклическим буффером  
`db.<имя коллекции>.getIndexes()` - показать все индексы БД
`db.<имя коллекции>.totalSize()` - показать сколько байт занимает БД и её индексы  
`db.<имя коллекции>.exists()` - показать статистику или `null` если коллекции не существует  
`db.<имя коллекции>.<метод>().explain()` - **показать план запроса**  
`db.<имя коллекции>.hideIndex()` - 
`db.<имя коллекции>.unhideIndex()` - 

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
 
В отличие от реляционных СУБД, Mongo не поддерживает соединения на стороне сервера. Один вызов JavaScript-функции извлекает документ и все вложенные в него данные. 

Поле `_id` типа `ObjectId` -  занимает 12 байтов и состоит из временной метки, идентификатора клиентской машины, идентификатора клиентского процесса и 3-байтового инкрементируемого счетчика.


#### Java Script

##### Объекты
```javascript
> typeof db
object
> typeof db.towns
object
> typeof db.towns.insertOne
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


### Чтение коллекций
`show collections` - показать все коллекции в текущей БД  
`db.towns.find()` - просмотреть содержимое коллекции `towns`  


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

#### Фильтрация $regex
```javascript
{ <field>: { $regex: /pattern/, $options: '<options>' } }
{ "<field>": { "$regex": "pattern", "$options": "<options>" } }
{ <field>: { $regex: /pattern/<options> } }
```
##### Популярные опции
Подготовим данные
```javascript
db.towns.updateOne( { _id: ObjectId("658ae56f1dd32f4b00991dde") }, { $set: { "description": "It is a big city with great recreation area.\nSmall town houses occupies the living zone.\nIt is best for healty life." } } );
db.towns.updateOne( { _id: ObjectId("658ae5321dd32f4b00991ddd") }, { $set: { "description": "It is unknown small city.\nMysterious city." } } );
db.towns.updateOne( { _id: ObjectId("658ab4781dd32f4b00991ddc") }, { $set: { "description": "It is a crowded huge megapolis.\nSkyscrappers are all over the city." } } );
```

Опция ```i``` позволяет выполять запросы для строк без учета регистра:
```javascript
db.towns.find( { "mayor.name": { $regex: /^sam/i } } )
```

Опция ```m``` позволяет находить префиксные и постфиксные строки в мультистроковых полях.
Для шаблонов, которые включают якори (`^` для начала, `$` для конца шаблона), находит подходящую подстроку под шаблон в начале или конце каждой строки мультистрокового значения:
```javascript
db.towns.find({ "description": { $regex: /^M/, $options: "m" } })
```
Без этой опции шаблон совпадет только для начала или конца всей строки.


Больше примеров [тут](https://www.mongodb.com/docs/manual/reference/operator/query/regex/)



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


##### Фильтр по нескольким условиям: оператор И
Подготовка данных
```javascript
db.countries.insert({
_id : "us",
name : "United States",
exports : {
    foods : [{ name : "bacon", tasty : true },
             { name : "burgers" }]
}
})
db.countries.insert({
_id : "ca",
name : "Canada",
exports : {
    foods : [{ name : "bacon", tasty : false },
             { name : "syrup", tasty : true }]
}
})
db.countries.insert({
_id : "mx",
name : "Mexico",
exports : {
    foods : [{ name : "salsa",
               tasty : true,
               condiment : true }]
}
})
```


Фильтр выдаст все города, где экспортируется бекон и то, что эскортируется - вкусное:  
```javascript
db.countries.find(
    { 'exports.foods.name' : 'bacon', 'exports.foods.tasty' : true },
    { _id : 0, name : 1 }
)
```


##### Фильтр по нескольким условиям с оператором И: $elemMatch
Фильтр `$elemMatch` использует точное соответствие параметрам запроса
```javascript
db.countries.find(
    {
        'exports.foods' : { $elemMatch : {name : 'bacon', tasty : true} }
    },
    { _id : 0, name : 1 }
)
```
Все страны, которые экспортируют вкусную еду, приправленную к тому же специями (condiment):
```javascript
db.countries.find(
{
'exports.foods' : {
$elemMatch : {
tasty : true,
condiment : { $exists : true }
}
}
},
{ _id : 0, name : 1 }
```


##### Фильтр по нескольким условиям с оператором ИЛИ: $or
Такой запрос ничего не вернет - по умолчанию подразумевается условие И:
```javascript
db.countries.find(
{ _id : "mx", name : "United States" },
{ _id : 1 }
)
```
Оператор `$or` используется в префиксной нотации: `OR A B`
```javascript
db.countries.find(
{
$or : [
{ _id : "mx" },
{ name : "United States" }
]
},
{ _id:1 }
)
```
##### Фильтр по функциональным критериям
**Предупреждение**  
Код функций выполняется медленно, не использует индексы, лучше обойтись стандартными фильтрами.

```javascript
db.towns.find( function() {
return this.population > 6000 && this.population < 600000;
} )
```
Сокращенная форма
```javascript
db.towns.find("this.population > 6000 && this.population < 600000")
```

Функциональный критерий фильтра в директиве $where
```javascript
db.towns.find( {
$where : "this.population > 6000 && this.population < 600000",
famous_for : /groundhog/
} )
```
**Предупреждение**  
Mongo будет тупо вычислять эту функцию для каждого документа, хотя нет никакой гарантии, что упоминаемое в ней поле вообще существует. Например, если вы предполагаете, что
поле population существует, а хотя бы в одном документе оно отсутствует, то весь запрос завершится ошибкой, потому что написанный на JavaScript код невозможно будет правильно выполнить.

#### Перечень наиболее частых операторов
| Команда | Описание |
|----------|----------|
|$regex | Соответствие строки регулярному выражению, совместимому с синтаксисом PCRE (можно также использовать ограничители //, как было показано выше) |
| $ne | Не равно |
| $lt | Меньше |
| $lte | Меньше или равно |
| $gt | Больше |
| $gte | Больше или равно |
| $exists | Проверяет существование поля |
| $all | Соответствие всем элементам массива |
| $in | Соответствие хотя бы одному элементу массива |
| $nin | Несоответствие ни одному элементу массива |
| $elemMatch | Соответствие всех полей вложенного документа |
| $or | Или |
| $nor | Не или |
| $size | Соответствие размеру массива |
| $mod | Деление по модулю |
| $type | Соответствие, если поле имеет указанный тип |
| $not | Отрицание |


### Обновление элемента коллекций
Функция `updateOne(criteria,operation)` принимает два обязательных параметра. Первый – критерий отбора – такой же, как для функции `find()`. Второй – либо объект, поля которого заменяют поля отобранных документов, либо модификатор.
#### Оператор $set
В данном случае модификатор `$set` записывает в поле state строку `OR`.

```javascript
db.towns.updateOne(
{ _id : ObjectId("4d0ada87bb30773266f39fe5") },
{ $set : { "state" : "OR" } }
);
```
Может возникнуть вопрос, зачем вообще нужна операция `$set`. **Будьте осторожны** - если нет оператора `set`, то в этом случае весь подходящий документ был бы заменен переданным вами документом `({ state : "OR" })`. Раз вы не указали команду, например $set, Mongo считает, что вы просто хотите целиком заменить документ.

db.towns.findOne({ _id : ObjectId("4d0ada87bb30773266f39fe5") })


#### Оператор $inc
Увеличить население Портленда на 1000:
```javascript
db.towns.update(
{ _id : ObjectId("4d0ada87bb30773266f39fe5") },
{ $inc : { population : 1000} }
)
```


| Команда | Описание |
|----------|----------|
| $set |Записывает указанное значение в указанное поле |
| $unset |Удаляет поле |
| $inc |Прибавляет указанное число к указанному полю |
| $pop |Удаляет последний (или первый) элемент из массива |
| $push |Помещает новый элемент в массив |
| $pushAll | Помещает все указанные элементы в массив |
| $addToSet | Аналогичен push, но дубликаты не добавляются |
| $pull | Удаляет из массива подходящее значение, если оно в нем есть |
| $pullAll | Удаляет из массива все подходящие значения |


### Cсылки DBRef
Добавить ссылку
```javascript
db.towns.update(
{ _id : ObjectId("658ae56f1dd32f4b00991dde") },
{ $set : { country: { $ref: "countries", $id: "us" } } }
)
```
```javascript
var portland = db.towns.findOne(
{ _id : ObjectId("658ae56f1dd32f4b00991dde") })
```
Использовать ссылку
```javascript
db.countries.findOne({ _id: portland.country.$id })
```
```javascript
db[ portland.country.$ref ].findOne({ _id: portland.country.$id })
```

### Удаление объектов коллекций
Важно отметить, что удаляется документ целиком, а не только совпавший элемент или
поддокумент.  

#### Рекомендация по порядку действий
1) Найти элементы - проверить правильность условия

```javascript
var bad_bacon = {
    'exports.foods' : { $elemMatch : { name : 'bacon',
                                       tasty : false } }
}
db.countries.find( bad_bacon )
```

2) Удалить
```javascript
db.countries.deleteOne( bad_bacon )
```
(Опция) Удалить все документы в коллекции
```javascript
db.countries.deleteMany( {} )
```

3) Убедиться, что осталось ожидаемое число элементов коллекции
```javascript
db.countries.count()
```


### Агрегатные функции
Подсчитать число элементов коллекции
```javascript
db.towns.countDocuments()
```

## Резюме
MongoDB - документная база данных:
- позволяет хранить вложенные документы в виде JSON-объектов; 
- позволяет опрашивать их по полям, расположенным на любом уровне вложенности. 

Документ можно рассматривать как бессхемную строку в реляционной модели со сгенерированным ключом `_id`.  
Набор документов, который в Mongo называется коллекцией, – аналог таблицы в PostgreSQL.   
В Mongo хранятся сложные денормализованные документы, представленные в виде коллекций произвольных JSON-объектов.   
Mongo дополняет гибкую стратегию хранения мощным механизмом запросов, не ограниченным предопределенной схемой.  
Благодаря денормализации документное хранилище является отличным выбором для хранения **данных с заранее неизвестными свойствами**, тогда как в других СУБД (реляционных или столбцовых) типы данных нужно знать заранее, а для добавления или изменения полей необходима _миграция_ схемы.


