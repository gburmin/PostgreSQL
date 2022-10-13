# Курсовой проект для Geekbrains по курсу "Базы данных" на примере стримингового сайта Twitch

## 1. Проанализировать бизнес-логику приложения и создать структуру базы данных, которая может использоваться для хранения данных этого приложения

Для начала создадим базу данных и дадим нашему пользователю все права для работы с ней:

`postgres=# CREATE DATABASE twitch;`

`postgres=# GRANT ALL PRIVILEGES ON DATABASE twitch TO gb_user;`

После этого можно начинать создавать таблицы.
Здесь я опишу названия и столбцы, код для их создания будет в файле [1.Creating tables](1.Creating%20tables.TXT)

1. users - никнейм, почта, стримключ, статус партнерки
2. profiles - ссылка на юзера, имя, фамилия, телефон, аватар, баннер, описание, таймстемп
3. streams_statistic - ссылка на юзера, кол-во подписчиков, кол-во сабскрайберы (платных подписчиков), число простримленных часов в месяц
4. private_messages  - от кого, кому, тело сообщения, таймстемп
5. tags  - названия тегов
6. subscriptions  -  кто, на кого, статус
7. subscription_types  - типы подписок(следую/follower, платно подписан/subscriber)
8. partnerships  - обычный, affiliate, full partner
9. categories  - названия категорий
10. chats - чей, от кого, текст
11. streams  - чей, категория, теги, кол-во зрителей, таймстемп
12. photo - чье, размер, ссылка, таймстемп
13. video - чье, размер, ссылка, таймстемп

## 2. Используя генератор тестовых данных, заполнить созданную БД данными в количестве минимум сто строк для тех таблиц, где это имеет смысл

В качестве отчет приложен дамп база данных с заполненными данными [twitch.dump.sql](twitch.dump.sql)

## 3. Создать внешние ключи, если они не были созданы на шаге 1 в командах создания таблиц

Команды создания ключей в файле [3.Foreign keys](3.Foreign%20keys.TXT)

## 4. Создать диаграмму отношений

Диаграмма находится в [4.ERD](4.ERD.png) . Как мы можем видеть, у каждой таблицы есть связь, никаких бессвязных таблиц нет

## 5. Создать два сложных (многотабличных) запроса с использованием подзапросов

Первый запрос: вывести никнейм пользователей, которые стримили на русском языке

```sql
SELECT nickname FROM users WHERE users.id in (
   SELECT user_id FROM streams WHERE tags_id = (
     SELECT id FROM tags WHERE name = 'russian')
 );
 ```

Второй запрос: вывести user_id и количество простримленных часов партнеров твича, которые стримили меньше 20 часов

```sql
SELECT user_id, streamed_in_month FROM streams_statistic WHERE user_id in
(SELECT id FROM users WHERE partnership_id in
(SELECT id FROM partnerships WHERE partnership_type = 'full partner'))
AND streamed_in_month < 40
ORDER BY streamed_in_month;
```

Команды запросов в файле [5.Nested queries](5.Nested%20queries.TXT)

## 6. Создать два сложных запроса с использованием объединения JOIN и без использования подзапросов

Возьмем за основу первый запрос из прошлого пункта и преобразуем его:

```sql
SELECT nickname FROM users
    JOIN streams ON users.id = streams.user_id
    JOIN tags ON streams.tags_id = tags.id
WHERE name = 'russian';
```

Как мы можем видеть, он стал значительно проще и нагляднее. Также его гораздо легче расширить, чтобы включить дополнительную статистику. Например, подсчитаем количество стримов на русском и английском языках

```sql
SELECT  tags.name, COUNT(*) FROM users
    JOIN streams ON users.id = streams.user_id
    JOIN tags ON streams.tags_id = tags.id
WHERE name = 'russian' OR name= 'english'
GROUP BY tags.name;
```

Аналогично поступим с вторым запросом заменив вложенные запросы на JOIN

```sql
SELECT user_id,streamed_in_month FROM streams_statistic
    LEFT JOIN users ON streams_statistic.user_id = users.id
    JOIN partnerships ON users.partnership_id = partnerships.id
WHERE partnership_type = 'full partner' AND streamed_in_month < 40
ORDER BY streamed_in_month;
```

Изменим и его, выведя вместо не презентабельного user_id никнейм и имя пользователей с малым количеством часов в месяце

```sql
SELECT
    nickname,
    first_name || ' ' || last_name AS first_and_last_name,
    streamed_in_month
    FROM streams_statistic
    LEFT JOIN users ON streams_statistic.user_id = users.id
    JOIN partnerships ON users.partnership_id = partnerships.id
    JOIN profiles ON users.id = profiles.user_id
WHERE partnership_type = 'full partner' AND streamed_in_month < 40
ORDER BY streamed_in_month;
```

Команды запросов в файле [6.Join](6.Join.TXT)

## 7. Создать два представления, в основе которых лежат сложные запросы

Так как подобные запросы могут использоваться весьма часто, может быть удобно обернуть их в представления.

```sql
CREATE VIEW russian_streamers AS
SELECT nickname FROM users
    JOIN streams ON users.id = streams.user_id
    JOIN tags ON streams.tags_id = tags.id
WHERE name = 'russian';
```

Теперь мы можем легко работать с данной выборкой, например, подсчитывая количество стримеров с тегом 'russian'
```sql
SELECT COUNT(*) FROM russian_streamers;
```

Создадим второе представление:

```sql
CREATE VIEW streamed_hours_of_partners AS
SELECT user_id,streamed_in_month FROM streams_statistic
    LEFT JOIN users ON streams_statistic.user_id = users.id
    JOIN partnerships ON users.partnership_id = partnerships.id
WHERE partnership_type = 'full partner' AND streamed_in_month < 40
ORDER BY streamed_in_month;
```

Можем выбрать стримеров с худшими показателями
```sql
SELECT * FROM streamed_hours_of_partners LIMIT 3;
```

Команды запросов в файле [7.View](7.View.TXT)

## 8. Создать пользовательскую функцию

На основе первого типа запроса создадим функцию, которая будет выводить число стримов с выбранным тегом

```sql
CREATE FUNCTION count_streams_with_selected_tag(choosed_tag VARCHAR(20))
RETURNS BIGINT AS
$$
SELECT COUNT(*)
FROM users
    JOIN streams ON users.id = streams.user_id
    JOIN tags ON streams.tags_id = tags.id
WHERE name = choosed_tag;
$$
LANGUAGE SQL;
```

Проверим работу функции с разными тегами

```sql
SELECT count_streams_with_selected_tag('russian');
SELECT count_streams_with_selected_tag('english');
```

Команды запросов в файле [8.Function](8.Function.TXT)

## 9. Создать триггер

Создадим триггер, который не позволит повысить статус партнерки до full partner стримеру, который стримил меньше 20 часов в месяц

Сначала создадим функцию

```sql
CREATE OR REPLACE FUNCTION update_partnership_trigger()
RETURNS TRIGGER AS
$$
DECLARE is_found BOOLEAN;
BEGIN
is_found := EXISTS(
    SELECT user_id FROM streams_statistic
    LEFT JOIN users ON streams_statistic.user_id = users.id
    JOIN partnerships ON users.partnership_id = partnerships.id
WHERE partnership_type != 'full partner' AND streamed_in_month < 20
ORDER BY streamed_in_month);
IF is_found THEN
RAISE EXCEPTION 'User streamed less then 20 hours in month';
END IF;
RETURN NEW;
END
$$
LANGUAGE PLPGSQL;
```

Теперь можно создавать триггер

```sql
CREATE TRIGGER update_partnership BEFORE UPDATE ON users
FOR EACH ROW
EXECUTE FUNCTION update_partnership_trigger();
```

Проверим результат

```sql
UPDATE users SET partnership_id = 3 WHERE id = 1;
```
Возникает ошибка
"ERROR:  User streamed less then 20 hours in month"

Команды запросов в файле [9.Trigger](9.Trigger.TXT)

## 10. Для одного из запросов, созданных в пункте 6, провести оптимизацию

Все команды запросов и их результаты в файле [10.Optimization](10.Optimization.TXT)
