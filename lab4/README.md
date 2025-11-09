# Исследование метаданных DNS трафика
Lona610@yandex.ru

## Цель работы

1.  Зекрепить практические навыки использования языка программирования R
    для обработки данных
2.  Закрепить знания основных функций обработки данных экосистемы
    tidyverse языка R
3.  Закрепить навыки исследования метаданных DNS трафика

## Исходные данные

1.  Программное обеспечение ОС Windows 11
2.  VS Code
3.  Интерпретатор языка R 4.5.1

## Задания

1.  Импортируйте данные DNS –
    https://storage.yandexcloud.net/dataset.ctfsec/dns.zip Данные были
    собраны с помощью сетевого анализатора zeek
2.  Добавьте пропущенные данные о структуре данных (назначении столбцов)
3.  Преобразуйте данные в столбцах в нужный формат,просмотрите общую
    структуру данных с помощью функции glimpse()
4.  Сколько участников информационного обмена всети Доброй Организации?
5.  Какое соотношение участников обмена внутрисети и участников
    обращений к внешним ресурсам?
6.  Найдите топ-10 участников сети, проявляющих наибольшую сетевую
    активность.
7.  Найдите топ-10 доменов, к которым обращаются пользователи сети и
    соответственное количество обращений
8.  Опеределите базовые статистические характеристики (функция summary()
    ) интервала времени между последовательными обращениями к топ-10
    доменам.
9.  Часто вредоносное программное обеспечение использует DNS канал в
    качестве канала управления, периодически отправляя запросы на
    подконтрольный злоумышленникам DNS сервер. По периодическим запросам
    на один и тот же домен можно выявить скрытый DNS канал. Есть ли
    такие IP адреса в исследуемом датасете?
10. Определите местоположение (страну, город) и организацию-провайдера
    для топ-10 доменов. Для этого можно использовать сторонние
    сервисы,например http://ip-api.com (API-эндпоинт –
    http://ip-api.com/json).

## Шаги:

1 Импортируйте данные DNS

``` r
library(tidyverse)
```

    Warning: пакет 'tidyverse' был собран под R версии 4.5.2

    Warning: пакет 'ggplot2' был собран под R версии 4.5.2

    Warning: пакет 'tidyr' был собран под R версии 4.5.2

    Warning: пакет 'readr' был собран под R версии 4.5.2

    Warning: пакет 'forcats' был собран под R версии 4.5.2

    Warning: пакет 'lubridate' был собран под R версии 4.5.2

    ── Attaching core tidyverse packages ──────────────────────── tidyverse 2.0.0 ──
    ✔ dplyr     1.1.4     ✔ readr     2.1.5
    ✔ forcats   1.0.1     ✔ stringr   1.5.2
    ✔ ggplot2   4.0.0     ✔ tibble    3.3.0
    ✔ lubridate 1.9.4     ✔ tidyr     1.3.1
    ✔ purrr     1.1.0     
    ── Conflicts ────────────────────────────────────────── tidyverse_conflicts() ──
    ✖ dplyr::filter() masks stats::filter()
    ✖ dplyr::lag()    masks stats::lag()
    ℹ Use the conflicted package (<http://conflicted.r-lib.org/>) to force all conflicts to become errors

``` r
library(lubridate)
library(jsonlite)
```


    Присоединяю пакет: 'jsonlite'

    Следующий объект скрыт от 'package:purrr':

        flatten

``` r
url <- "https://storage.yandexcloud.net/dataset.ctfsec/dns.zip"
download.file(url, "dns.zip")
unzip("dns.zip")
dns <- read_tsv("dns.log", comment = "#", col_names = FALSE)
```

    Rows: 427935 Columns: 23
    ── Column specification ────────────────────────────────────────────────────────
    Delimiter: "\t"
    chr (13): X2, X3, X5, X7, X9, X10, X11, X12, X13, X14, X15, X21, X22
    dbl  (5): X1, X4, X6, X8, X20
    lgl  (5): X16, X17, X18, X19, X23

    ℹ Use `spec()` to retrieve the full column specification for this data.
    ℹ Specify the column types or set `show_col_types = FALSE` to quiet this message.

2 Добавьте пропущенные данные о структуре данных (назначении столбцов)

``` r
colnames(dns) <- c(
  "ts", "uid", "id.orig_h", "id.orig_p", "id.resp_h", "id.resp_p",
  "proto", "trans_id", "rtt", "query", "qclass", "qclass_name",
  "qtype", "qtype_name", "rcode", "rcode_name", "AA", "TC",
  "RD", "RA", "Z", "answers", "TTLs", "rejected"
)
```

3 Преобразуйте данные в столбцах в нужный формат

``` r
dns <- dns %>%
  mutate(
    ts = as_datetime(ts),
    id.orig_p = as.integer(id.orig_p),
    id.resp_p = as.integer(id.resp_p),
    rtt = as.numeric(rtt)
  )
```

    Warning: There was 1 warning in `mutate()`.
    ℹ In argument: `rtt = as.numeric(rtt)`.
    Caused by warning:
    ! в результате преобразования созданы NA

4 Просмотрите общую структуру данных с помощью функции glimpse()

``` r
glimpse(dns)
```

    Rows: 427,935
    Columns: 23
    $ ts          <dttm> 2012-03-16 12:30:05, 2012-03-16 12:30:15, 2012-03-16 12:3…
    $ uid         <chr> "CWGtK431H9XuaTN4fi", "C36a282Jljz7BsbGH", "C36a282Jljz7Bs…
    $ id.orig_h   <chr> "192.168.202.100", "192.168.202.76", "192.168.202.76", "19…
    $ id.orig_p   <int> 45658, 137, 137, 137, 137, 137, 137, 137, 137, 137, 137, 1…
    $ id.resp_h   <chr> "192.168.27.203", "192.168.202.255", "192.168.202.255", "1…
    $ id.resp_p   <int> 137, 137, 137, 137, 137, 137, 137, 137, 137, 137, 137, 137…
    $ proto       <chr> "udp", "udp", "udp", "udp", "udp", "udp", "udp", "udp", "u…
    $ trans_id    <dbl> 33008, 57402, 57402, 57402, 57398, 57398, 57398, 62187, 62…
    $ rtt         <dbl> NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA…
    $ query       <chr> "1", "1", "1", "1", "1", "1", "1", "1", "1", "1", "1", "1"…
    $ qclass      <chr> "C_INTERNET", "C_INTERNET", "C_INTERNET", "C_INTERNET", "C…
    $ qclass_name <chr> "33", "32", "32", "32", "32", "32", "32", "32", "32", "32"…
    $ qtype       <chr> "SRV", "NB", "NB", "NB", "NB", "NB", "NB", "NB", "NB", "NB…
    $ qtype_name  <chr> "0", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-"…
    $ rcode       <chr> "NOERROR", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-…
    $ rcode_name  <lgl> FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FA…
    $ AA          <lgl> FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FA…
    $ TC          <lgl> FALSE, TRUE, TRUE, TRUE, TRUE, TRUE, TRUE, TRUE, TRUE, TRU…
    $ RD          <lgl> FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FA…
    $ RA          <dbl> 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0, 0, 1, 1, 1, 1, 0…
    $ Z           <chr> "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-"…
    $ answers     <chr> "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-"…
    $ TTLs        <lgl> FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FA…

5 Сколько участников информационного обмена в сети Доброй Организации?

``` r
participants <- unique(c(dns$id.orig_h, dns$id.resp_h))
cat("Участников обмена:", length(participants), "\n")
```

    Участников обмена: 1359 

6 Какое соотношение участников обмена внутри сети и участников обращений
к внешним ресурсам?

``` r
internal_ips <- dns %>% filter(str_detect(id.orig_h, "^192\\.168|^10\\.|^172\\.(1[6-9]|2[0-9]|3[0-1])"))
external_ips <- dns %>% filter(!str_detect(id.orig_h, "^192\\.168|^10\\.|^172\\.(1[6-9]|2[0-9]|3[0-1])"))

cat("Внутренние участники:", nrow(internal_ips), "\n")
```

    Внутренние участники: 407249 

``` r
cat("Внешние участники:", nrow(external_ips), "\n")
```

    Внешние участники: 20686 

7 Найдите топ-10 участников сети, проявляющих наибольшую сетевую
активность.

``` r
top_active <- dns %>%
  count(id.orig_h, sort = TRUE) %>%
  head(10)
print("Топ-10 активных участников:")
```

    [1] "Топ-10 активных участников:"

``` r
print(top_active)
```

    # A tibble: 10 × 2
       id.orig_h           n
       <chr>           <int>
     1 10.10.117.210   75943
     2 192.168.202.93  26522
     3 192.168.202.103 18121
     4 192.168.202.76  16978
     5 192.168.202.97  16176
     6 192.168.202.141 14967
     7 10.10.117.209   14222
     8 192.168.202.110 13372
     9 192.168.203.63  12148
    10 192.168.202.106 10784

8 Найдите топ-10 доменов, к которым обращаются пользователи сети и
соответственное количество обращений

``` r
top_domains <- dns %>%
  count(query, sort = TRUE) %>%
  head(10)
print("Топ-10 доменов:")
```

    [1] "Топ-10 доменов:"

``` r
print(top_domains)
```

    # A tibble: 4 × 2
      query      n
      <chr>  <int>
    1 1     422339
    2 -       3648
    3 3       1016
    4 32769    932

    Топ доменов:

``` r
print(top_domains)
```

    # A tibble: 4 × 2
      query      n
      <chr>  <int>
    1 1     422339
    2 -       3648
    3 3       1016
    4 32769    932

9 Опеределите базовые статистические характеристики (функция summary())
интервала времени между последовательными обращениями к топ-10 доменам

``` r
top_domains_list <- top_domains$query
dns_top <- dns %>% filter(query %in% top_domains_list) %>% arrange(ts)

time_diffs <- dns_top %>%
  group_by(query) %>%
  mutate(diff = as.numeric(ts - lag(ts), units = "secs")) %>%
  summarise(
    min = min(diff, na.rm = TRUE),
    q1 = quantile(diff, 0.25, na.rm = TRUE),
    median = median(diff, na.rm = TRUE),
    mean = mean(diff, na.rm = TRUE),
    q3 = quantile(diff, 0.75, na.rm = TRUE),
    max = max(diff, na.rm = TRUE)
  )
print("Статистика интервалов запросов:")
```

    [1] "Статистика интервалов запросов:"

``` r
print(time_diffs)
```

    # A tibble: 4 × 7
      query   min     q1  median    mean    q3    max
      <chr> <dbl>  <dbl>   <dbl>   <dbl> <dbl>  <dbl>
    1 -         0 0.0700 0.990    32.0   3.80  49787.
    2 1         0 0      0.01000   0.277 0.150 49669.
    3 3         0 0      0.0200  106.    1.99  58363.
    4 32769     0 0.115  1.12    119.    2.01  52833.

10 Часто вредоносное программное обеспечение использует DNS канал в
качестве канала управления, периодически отправляя запросы на
подконтрольный злоумышленникам DNS сервер. По периодическим запросам на
один и тот же домен можно выявить скрытый DNS канал. Есть ли такие IP
адреса в исследуемом датасете?

``` r
periodic_ips <- dns %>%
  filter(query %in% top_domains_list) %>%
  group_by(id.orig_h, query) %>%
  summarise(
    request_count = n(),
    time_span = as.numeric(max(ts) - min(ts), units = "secs"),
    avg_interval = time_span / (request_count - 1)
  ) %>%
  filter(request_count > 5, avg_interval < 3600) %>%  # более 5 запросов, средний интервал < 1 часа
  arrange(avg_interval)
```

    `summarise()` has grouped output by 'id.orig_h'. You can override using the
    `.groups` argument.

``` r
print("Подозрительные IP с периодическими запросами:")
```

    [1] "Подозрительные IP с периодическими запросами:"

``` r
print(periodic_ips)
```

    # A tibble: 238 × 5
    # Groups:   id.orig_h [197]
       id.orig_h                          query request_count time_span avg_interval
       <chr>                              <chr>         <int>     <dbl>        <dbl>
     1 192.168.202.148                    1                 8  1.000e-2      0.00143
     2 192.168.95.166                     1                18  1.51 e+0      0.0888 
     3 192.168.202.108                    -               235  2.54 e+1      0.108  
     4 2001:dbb:c18:202:d4bc:e39f:84ad:5… 1                63  9.46 e+0      0.153  
     5 169.254.228.26                     1                24  3.75 e+0      0.163  
     6 10.10.117.210                      1             75943  1.26 e+4      0.166  
     7 192.168.100.130                    1                 6  1.35 e+0      0.270  
     8 192.168.202.146                    1                28  8.27 e+0      0.306  
     9 192.168.202.157                    1              1491  5.41 e+2      0.363  
    10 192.168.202.128                    1                94  3.43 e+1      0.368  
    # ℹ 228 more rows

11 Определите местоположение (страну, город) и организацию-провайдера
для топ-10 доменов. Для этого можно использовать сторонние сервисы,
например http://ip-api.com (API-эндпоинт – http://ip-api.com/json).

``` r
get_ip_info <- function(ip) {
  url <- paste0("http://ip-api.com/json/", ip)
  response <- fromJSON(url)
  if (response$status == "success") {
    return(tibble(
      ip = ip,
      country = response$country,
      city = response$city,
      isp = response$isp
    ))
  } else {
    return(tibble(ip = ip, country = NA, city = NA, isp = NA))
  }
}
```

## Оценка результата

В результате практической работы мы поняли как анализировать данные DNS
с помощью языка R.

## Вывод

Таким образом, мы научились, используя язык r, скачивать и анализировать
данные DNS.
