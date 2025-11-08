# Основы обработки данных с помощью R и Dplyr
Lona610@yandex.ru

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
    ```

        Warning: пакет 'nycflights13' был собран под R версии 4.5.2

    ``` r
    library(dplyr)
    ```


        Присоединяю пакет: 'dplyr'

        Следующие объекты скрыты от 'package:stats':

            filter, lag

        Следующие объекты скрыты от 'package:base':

            intersect, setdiff, setequal, union

2.  Сколько встроенных в пакет nycflights13 датафреймов? (Ответ - 5)

    ``` r
    data(package = "nycflights13")
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

              year          month             day           dep_time    sched_dep_time
         Min.   :2013   Min.   : 1.000   Min.   : 1.00   Min.   :   1   Min.   : 106  
         1st Qu.:2013   1st Qu.: 4.000   1st Qu.: 8.00   1st Qu.: 907   1st Qu.: 906  
         Median :2013   Median : 7.000   Median :16.00   Median :1401   Median :1359  
         Mean   :2013   Mean   : 6.549   Mean   :15.71   Mean   :1349   Mean   :1344  
         3rd Qu.:2013   3rd Qu.:10.000   3rd Qu.:23.00   3rd Qu.:1744   3rd Qu.:1729  
         Max.   :2013   Max.   :12.000   Max.   :31.00   Max.   :2400   Max.   :2359  
                                                         NA's   :8255                 
           dep_delay          arr_time    sched_arr_time   arr_delay       
         Min.   : -43.00   Min.   :   1   Min.   :   1   Min.   : -86.000  
         1st Qu.:  -5.00   1st Qu.:1104   1st Qu.:1124   1st Qu.: -17.000  
         Median :  -2.00   Median :1535   Median :1556   Median :  -5.000  
         Mean   :  12.64   Mean   :1502   Mean   :1536   Mean   :   6.895  
         3rd Qu.:  11.00   3rd Qu.:1940   3rd Qu.:1945   3rd Qu.:  14.000  
         Max.   :1301.00   Max.   :2400   Max.   :2359   Max.   :1272.000  
         NA's   :8255      NA's   :8713                  NA's   :9430      
           carrier              flight       tailnum             origin         
         Length:336776      Min.   :   1   Length:336776      Length:336776     
         Class :character   1st Qu.: 553   Class :character   Class :character  
         Mode  :character   Median :1496   Mode  :character   Mode  :character  
                            Mean   :1972                                        
                            3rd Qu.:3465                                        
                            Max.   :8500                                        

             dest              air_time        distance         hour      
         Length:336776      Min.   : 20.0   Min.   :  17   Min.   : 1.00  
         Class :character   1st Qu.: 82.0   1st Qu.: 502   1st Qu.: 9.00  
         Mode  :character   Median :129.0   Median : 872   Median :13.00  
                            Mean   :150.7   Mean   :1040   Mean   :13.18  
                            3rd Qu.:192.0   3rd Qu.:1389   3rd Qu.:17.00  
                            Max.   :695.0   Max.   :4983   Max.   :23.00  
                            NA's   :9430                                  
             minute        time_hour                  
         Min.   : 0.00   Min.   :2013-01-01 05:00:00  
         1st Qu.: 8.00   1st Qu.:2013-04-04 13:00:00  
         Median :29.00   Median :2013-07-03 10:00:00  
         Mean   :26.23   Mean   :2013-07-03 05:22:54  
         3rd Qu.:44.00   3rd Qu.:2013-10-01 07:00:00  
         Max.   :59.00   Max.   :2013-12-31 23:00:00  

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

        # A tibble: 1 × 1
              n
          <int>
        1     0

8.  Какой самый северный аэропорт?

    ``` r
    airports %>%
        arrange(desc(lat)) %>%
        head(1) %>%
        pull(name)
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
