# Основы обработки данных с помощью R и Dplyr
Loona610@yandex.ru

## Цель работы

1.  Развить практические навыки использования языка программирования R
    для обработки данных
2.  Закрепить знания базовых типов данных языка R
3.  Развить практические навыки использования функций обработки данных
    пакета dplyr – функции select(), filter(), mutate(), arrange(),
    group_by()

## Исходные данные

1.  Программное обеспечение Windows 11
2.  Visual Studio Code
3.  Интерпретатор языка R 4.5.1

## План

Проанализировать встроенные в пакет nycflights13 наборы данных с помощью
языка R и ответить на вопросы

## Шаги:

1.  Загрузка библиотек

    ``` r
    library(nycflights13)
    library(dplyr)
    ```


        Attaching package: 'dplyr'

        The following objects are masked from 'package:stats':

            filter, lag

        The following objects are masked from 'package:base':

            intersect, setdiff, setequal, union

2.  Сколько встроенных в пакет nycflights13 датафреймов? (Ответ - 5)

    ``` r
    ata(package = "nycflights13")
    ```

3.  Сколько строк в каждом датафрейме?

    ``` r
    unlist(lapply(list(flights, airlines, airports, planes, weather), nrow))
    ```

        [1] 336776     16   1458   3322  26115

4.  Сколько столбцов в каждом датафрейме?

    ``` r
    unlist(lapply(list(flights, airlines, airports, planes, weather), ncol))
    ```

        [1] 19  2  8  9 15

5.  Как просмотреть примерный вид датафрейма?

    ``` r
    summary(flights)
    ```

        Rows: 336,776
        Columns: 19
        $ year           <int> 2013, 2013, 2013, 2013, 2013, 2013, 2013, 2013, 2013, 2…
        $ month          <int> 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1…
        $ day            <int> 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1…
        $ dep_time       <int> 517, 533, 542, 544, 554, 554, 555, 557, 557, 558, 558, …
        $ sched_dep_time <int> 515, 529, 540, 545, 600, 558, 600, 600, 600, 600, 600, …
        $ dep_delay      <dbl> 2, 4, 2, -1, -6, -4, -5, -3, -3, -2, -2, -2, -2, -2, -1…
        $ arr_time       <int> 830, 850, 923, 1004, 812, 740, 913, 709, 838, 753, 849,…
        $ sched_arr_time <int> 819, 830, 850, 1022, 837, 728, 854, 723, 846, 745, 851,…
        $ arr_delay      <dbl> 11, 20, 33, -18, -25, 12, 19, -14, -8, 8, -2, -3, 7, -1…
        $ carrier        <chr> "UA", "UA", "AA", "B6", "DL", "UA", "B6", "EV", "B6", "…
        $ flight         <int> 1545, 1714, 1141, 725, 461, 1696, 507, 5708, 79, 301, 4…
        $ tailnum        <chr> "N14228", "N24211", "N619AA", "N804JB", "N668DN", "N394…
        $ origin         <chr> "EWR", "LGA", "JFK", "JFK", "LGA", "EWR", "EWR", "LGA",…
        $ dest           <chr> "IAH", "IAH", "MIA", "BQN", "ATL", "ORD", "FLL", "IAD",…
        $ air_time       <dbl> 227, 227, 160, 183, 116, 150, 158, 53, 140, 138, 149, 1…
        $ distance       <dbl> 1400, 1416, 1089, 1576, 762, 719, 1065, 229, 944, 733, …
        $ hour           <dbl> 5, 5, 5, 5, 6, 5, 6, 6, 6, 6, 6, 6, 6, 6, 6, 5, 6, 6, 6…
        $ minute         <dbl> 15, 29, 40, 45, 0, 58, 0, 0, 0, 0, 0, 0, 0, 0, 0, 59, 0…
        $ time_hour      <dttm> 2013-01-01 05:00:00, 2013-01-01 05:00:00, 2013-01-01 0…

    ``` r
    head(airports)
    ```

        # A tibble: 6 × 8
          faa   name                             lat   lon   alt    tz dst   tzone      
          <chr> <chr>                          <dbl> <dbl> <dbl> <dbl> <chr> <chr>      
        1 04G   Lansdowne Airport               41.1 -80.6  1044    -5 A     America/Ne…
        2 06A   Moton Field Municipal Airport   32.5 -85.7   264    -6 A     America/Ch…
        3 06C   Schaumburg Regional             42.0 -88.1   801    -6 A     America/Ch…
        4 06N   Randall Airport                 41.4 -74.4   523    -5 A     America/Ne…
        5 09J   Jekyll Island Airport           31.1 -81.4    11    -5 A     America/Ne…
        6 0A9   Elizabethton Municipal Airport  36.4 -82.2  1593    -5 A     America/Ne…

6.  Сколько компаний-перевозчиков (carrier) учитывают эти наборы данных
    (представлено в наборах данных)?

    ``` r
    flights %>%
        summarise(n_carriers = n_distinct(carrier)) %>%
        pull(n_carriers)
    ```

        [1] 16

7.  Сколько рейсов принял аэропорт John F Kennedy Intl в мае?

    ``` r
    flights %>%
        filter(dest == "JFK", month == 5) %>%
        tally()
    ```

        [1] 0

8.  Какой самый северный аэропорт?

    ``` r
    airports %>%
        arrange(desc(lat)) %>%
        head(1) %>%
        pull(name)
    ```
    ```

        [1] "Dillant Hopkins Airport"

9.  Какой аэропорт самый высокогорный (находится выше всех над уровнем
    моря)?

    ``` r
    airports %>%
        slice_max(alt, n = 1) %>%
        pull(name)
    ```

        [1] "Telluride"

10. Какие бортовые номера у самых старых самолетов?

    ``` r
    planes %>%
        filter(!is.na(year)) %>%
        slice_min(year, n = 5) %>%
        pull(tailnum)
    ```

        [1] "N381AA" "N201AA" "N567AA" "N378AA" "N575AA"

11. Какая средняя температура воздуха была в сентябре в аэропорту John F
    Kennedy Intl (в градусах Цельсия)?

    ``` r
    weather %>%
        filter(origin == "JFK", month == 9) %>%
        summarise(avg_temp_C = mean((temp - 32) * 5/9, na.rm = TRUE)) %>%
        .$avg_temp_C
    ```

        [1] 19.38764

12. Самолеты какой авиакомпании совершили больше всего вылетов в июне?

    ``` r
    flights %>%
        filter(month == 6) %>%
        count(carrier) %>%
        slice_max(n, n = 1) %>%
        pull(carrier)
    ```

        [1] "UA"

13. Самолеты какой авиакомпании задерживались чаще других в 2013 году?

    ``` r
    flights %>%
        filter(!is.na(dep_delay)) %>%
        mutate(delayed = dep_delay > 0) %>%
        group_by(carrier) %>%
        summarise(delay_rate = mean(delayed)) %>%
        filter(delay_rate == max(delay_rate)) %>%
        pull(carrier)
    ```

        [1] "WN"

## Оценка результата

В результате лабораторной работы мы развили практические навыки
использования языка программирования R для обработки данных и закрепили
знания базовых типов данных языка R

## Вывод

Таким образом, мы научились использовать функции обработки данных пакета
dplyr – функции select(), filter(), mutate(), arrange(), group_by()