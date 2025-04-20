# Скрипт для импорта Stack Exchange Data Dump в БД Postgres

## Установка и использование

Скачайте и разархивируйте дамп из [архива дампов данных](https://archive.org/download/stackexchange) сайта dba.stackexchange.org<br>
- [dba.stackexchange.com.7z](https://archive.org/download/stackexchange/dba.stackexchange.com.7z)
- [dba.meta.stackexchange.com.7z](https://archive.org/download/stackexchange/dba.meta.stackexchange.com.7z)
<br>Для работы необходимы установленная PostgreSQL, желательно версии 17, а также Python 3.11+

### Создание схемы

Создайте базу данных с произвольным названием<br>
```
$ createdb StackExchangeDB
```
Создайте схему и таблицы, запустив SQL-скрипт<br>
```
$ psql -d StackExchangeDB -f schema.sql
```

### Импорт

Установите зависимости для Python-скрипта
```
$ pip install -r requirements.txt
```
Запустите скрипт с помощью командной строки
```
usage: import_from_xml.py [-h] --xml XML --table TABLE [--schema SCHEMA] [--dbname DBNAME] [--user USER] [--host HOST] [--port PORT] [--batch-size BATCH_SIZE] [--log-level {debug,info,warning}]
import_from_xml.py: error: the following arguments are required: --xml, --table
```
```
$ import_from_xml.py --xml Posts.xml --table posts --schema stackexchange --dbname StackExchangeDB --user postgres
```
## Запросы
В качестве примеров представлены запросы Q1 и Q2

### Возможности в оптимизации
- Для Q1: временные таблицы (?)
- Для Q2: возможно добавить индекс на Posts.AcceptedAnswerId

## TODO
- Мастер-скрипт, запускающий import_from_xml.py поочерёдно для всех XML-файлов в дампе
  - Автоматическая разархивация дампа
- Удобное изменение названия генерируемой схемы
- Улучшение обработки ограничений на внешние ключи при импорте
