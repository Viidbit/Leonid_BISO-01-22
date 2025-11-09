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
library(tidyverse)
test <- tempfile()
download.file("https://storage.yandexcloud.net/dataset.ctfsec/dns.zip", test)
unzip(test, exdir = "dns_data")
dns_data <- read_tsv("dns_data/dns.log", col_names = FALSE)
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
colnames(dns_data) <- c("ts", "uid", "id.orig_h", "id.orig_p", "id.resp_h", "id.resp_p", "proto", "trans_id", "rtt", "query", "qclass", "qclass_name","qtype", "qtype_name", "rcode", "rcode_name", "AA", "TC", "RD", "RA", "Z", "answers", "TTLs", "rejected")
```

3 Преобразуйте данные в столбцах в нужный формат

``` r
dns_data <- dns_data %>% mutate(ts = as_datetime(ts), id.orig_h = as.character(id.orig_h), id.resp_h = as.character(id.resp_h), query = as.character(query))
```

4 Просмотрите общую структуру данных с помощью функции glimpse()

``` r
glimpse(dns_data)
```

    Rows: 427,935
    Columns: 23
    $ ts          <dttm> 2012-03-16 12:30:05, 2012-03-16 12:30:15, 2012-03-16 12:3…
    $ uid         <chr> "CWGtK431H9XuaTN4fi", "C36a282Jljz7BsbGH", "C36a282Jljz7Bs…
    $ id.orig_h   <chr> "192.168.202.100", "192.168.202.76", "192.168.202.76", "19…
    $ id.orig_p   <dbl> 45658, 137, 137, 137, 137, 137, 137, 137, 137, 137, 137, 1…
    $ id.resp_h   <chr> "192.168.27.203", "192.168.202.255", "192.168.202.255", "1…
    $ id.resp_p   <dbl> 137, 137, 137, 137, 137, 137, 137, 137, 137, 137, 137, 137…
    $ proto       <chr> "udp", "udp", "udp", "udp", "udp", "udp", "udp", "udp", "u…
    $ trans_id    <dbl> 33008, 57402, 57402, 57402, 57398, 57398, 57398, 62187, 62…
    $ rtt         <chr> "*\\x00\\x00\\x00\\x00\\x00\\x00\\x00\\x00\\x00\\x00\\x00\…
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
all_ips <- unique(c(dns_data$id.orig_h, dns_data$id.resp_h))
cat("Количество участников информационного обмена:", length(all_ips), "\n")
```

    Количество участников информационного обмена: 1359 

6 Какое соотношение участников обмена внутри сети и участников обращений
к внешним ресурсам?

``` r
internal_ips <- all_ips[grepl("^(10\\.|192\\.168\\.|172\\.(1[6-9]|2[0-9]|3[0-1])\\.)", all_ips)]
external_ips <- setdiff(all_ips, internal_ips)

cat("Внутренние IP:", length(internal_ips), "\n")
```

    Внутренние IP: 1267 

``` r
cat("Внешние IP:", length(external_ips), "\n")
```

    Внешние IP: 92 

``` r
cat("Соотношение (внутренние/внешние):", round(length(internal_ips)/length(external_ips), 2), "\n")
```

    Соотношение (внутренние/внешние): 13.77 

7 Найдите топ-10 участников сети, проявляющих наибольшую сетевую
активность.

``` r
activity_orig <- dns_data %>% 
  count(id.orig_h, name = "requests_sent") %>% 
  rename(ip = id.orig_h)

activity_resp <- dns_data %>% 
  count(id.resp_h, name = "requests_received") %>% 
  rename(ip = id.resp_h)

total_activity <- full_join(activity_orig, activity_resp, by = "ip") %>%
  mutate(
    requests_sent = replace_na(requests_sent, 0),
    requests_received = replace_na(requests_received, 0),
    total_activity = requests_sent + requests_received
  ) %>%
  arrange(desc(total_activity)) %>%
  head(10)

cat("\nТоп-10 участников по сетевой активности:\n")
```


    Топ-10 участников по сетевой активности:

``` r
print(total_activity)
```

    # A tibble: 10 × 4
       ip              requests_sent requests_received total_activity
       <chr>                   <int>             <int>          <int>
     1 192.168.207.4              85            266542         266627
     2 10.10.117.210           75943                 0          75943
     3 192.168.202.255             0             68720          68720
     4 192.168.202.93          26522                 0          26522
     5 172.19.1.100                0             25481          25481
     6 192.168.202.103         18121                 0          18121
     7 192.168.202.76          16978                 0          16978
     8 192.168.202.97          16176                 0          16176
     9 192.168.202.141         14967                 9          14976
    10 192.168.202.110         13372              1121          14493

8 Найдите топ-10 доменов, к которым обращаются пользователи сети и
соответственное количество обращений

``` r
top_domains <- dns_data %>%
  count(query, sort = TRUE) %>%
  head(10)

cat("\nТоп-10 доменов по количеству обращений:\n")
```


    Топ-10 доменов по количеству обращений:

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
top_domain_stats <- dns_data %>%
  filter(query %in% top_domains$query) %>%
  arrange(query, ts) %>%
  group_by(query) %>%
  mutate(time_diff = as.numeric(difftime(ts, lag(ts), units = "secs"))) %>%
  summarise(
    min = min(time_diff, na.rm = TRUE),
    q1 = quantile(time_diff, 0.25, na.rm = TRUE),
    median = median(time_diff, na.rm = TRUE),
    mean = mean(time_diff, na.rm = TRUE),
    q3 = quantile(time_diff, 0.75, na.rm = TRUE),
    max = max(time_diff, na.rm = TRUE),
    .groups = 'drop'
  )

cat("\nСтатистика интервалов времени для топ-10 доменов:\n")
```


    Статистика интервалов времени для топ-10 доменов:

``` r
print(top_domain_stats)
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
suspicious_activity <- dns_data %>%
  count(id.orig_h, query, sort = TRUE) %>%  
  filter(n > 5) %>%
  head(10)

if(nrow(suspicious_activity) > 0) {
  cat("\nПодозрительные IP (частые запросы к одному домену):\n")
  print(suspicious_activity)
} else {
  cat("\nПодозрительная активность отсутствует\n")
}
```


    Подозрительные IP (частые запросы к одному домену):
    # A tibble: 10 × 3
       id.orig_h       query     n
       <chr>           <chr> <int>
     1 10.10.117.210   1     75943
     2 192.168.202.93  1     26522
     3 192.168.202.103 1     18121
     4 192.168.202.76  1     16978
     5 192.168.202.97  1     16176
     6 192.168.202.141 1     14967
     7 10.10.117.209   1     14222
     8 192.168.202.110 1     12784
     9 192.168.203.63  1     12148
    10 192.168.202.106 1     10784

11 Определите местоположение (страну, город) и организацию-провайдера
для топ-10 доменов. Для этого можно использовать сторонние сервисы,
например http://ip-api.com (API-эндпоинт – http://ip-api.com/json).

``` r
# Импорт необходимых пакетов
library(httr)
library(jsonlite)
```


    Присоединяю пакет: 'jsonlite'

    Следующий объект скрыт от 'package:purrr':

        flatten

``` r
library(dplyr)

# Определение исследуемых доменных имен
selected_domains <- c(
  "google.com", "youtube.com", "facebook.com", 
  "baidu.com", "wikipedia.org", "qq.com", 
  "taobao.com", "yahoo.com", "amazon.com", 
  "twitter.com"
)

# Функция получения географических данных домена
fetch_geo_data <- function(domain_name) {
  api_endpoint <- sprintf("http://ip-api.com/json/%s", domain_name)
  
  attempt <- tryCatch({
    api_response <- GET(api_endpoint)
    
    if (http_status(api_response)$category == "Success") {
      response_data <- content(api_response, "parsed")
      
      tibble(
        Domain = domain_name,
        IP_address = response_data$query %||% NA,
        Country = response_data$country %||% NA,
        City = response_data$city %||% NA,
        ISP = response_data$isp %||% NA,
        Organization = response_data$org %||% NA,
        AS_number = response_data$as %||% NA,
        Request_status = response_data$status %||% NA
      )
    } else {
      message("Сбой запроса для ", domain_name, " - код: ", status_code(api_response))
      NULL
    }
  }, error = function(err) {
    message("Ошибка при обработке ", domain_name, ": ", err$message)
    NULL
  })
  
  return(attempt)
}

# Модифицированная функция с задержкой выполнения
fetch_with_delay <- function(domain) {
  result_data <- fetch_geo_data(domain)
  Sys.sleep(2.0)
  return(result_data)
}

# Основной процесс сбора данных
cat("Запуск процесса сбора географических данных...\n\n")
```

    Запуск процесса сбора географических данных...

``` r
collected_results <- list()

for (current_domain in selected_domains) {
  cat("Анализируется: ", current_domain, "\n")
  domain_data <- fetch_with_delay(current_domain)
  
  if (!is.null(domain_data)) {
    collected_results[[length(collected_results) + 1]] <- domain_data
  }
}
```

    Анализируется:  google.com 
    Анализируется:  youtube.com 
    Анализируется:  facebook.com 
    Анализируется:  baidu.com 
    Анализируется:  wikipedia.org 
    Анализируется:  qq.com 
    Анализируется:  taobao.com 
    Анализируется:  yahoo.com 
    Анализируется:  amazon.com 
    Анализируется:  twitter.com 

``` r
# Объединение результатов
final_results <- bind_rows(collected_results)

# Вывод итоговой информации
cat("\n", strrep("=", 50), "\n")
```


     ================================================== 

``` r
cat("ОБРАБОТАННЫЕ ДОМЕНЫ\n")
```

    ОБРАБОТАННЫЕ ДОМЕНЫ

``` r
cat(strrep("=", 50), "\n")
```

    ================================================== 

``` r
if (nrow(final_results) > 0) {
  # Детальный вывод по каждому домену
  cat("\nДЕТАЛЬНАЯ ИНФОРМАЦИЯ:\n")
  cat(strrep("-", 50), "\n")
  
  for (row_index in seq_len(nrow(final_results))) {
    current_row <- final_results[row_index, ]
    
    cat(sprintf("\n%2d. %s\n", row_index, current_row$Domain))
    cat("    ├─ IP-адрес: ", current_row$IP_address, "\n")
    cat("    ├─ Страна: ", current_row$Country, "\n")
    cat("    ├─ Город: ", current_row$City, "\n")
    cat("    ├─ Провайдер: ", current_row$ISP, "\n")
    cat("    └─ Организация: ", current_row$Organization, "\n")
  }
  
  # Анализ распределения по странам
  country_distribution <- final_results %>%
    group_by(Country) %>%
    summarise(Количество = n(), .groups = 'drop') %>%
    arrange(desc(Количество))
  
  cat("\n", strrep("=", 50), "\n")
  cat("ГЕОГРАФИЧЕСКОЕ РАСПРЕДЕЛЕНИЕ\n")
  cat(strrep("=", 50), "\n")
  print(country_distribution)
  
  # Сохранение результатов
  output_filename <- "geo_analysis_results.csv"
  write.csv(final_results, output_filename, row.names = FALSE)
  cat(sprintf("\nДанные сохранены в файл: %s\n", output_filename))
  
} else {
  cat("Не удалось получить данные для указанных доменов.\n")
}
```


    ДЕТАЛЬНАЯ ИНФОРМАЦИЯ:
    -------------------------------------------------- 

     1. google.com
        ├─ IP-адрес:  142.250.151.101 
        ├─ Страна:  United States 
        ├─ Город:  Mountain View 
        ├─ Провайдер:  Google LLC 
        └─ Организация:  Google LLC 

     2. youtube.com
        ├─ IP-адрес:  142.250.129.93 
        ├─ Страна:  United States 
        ├─ Город:  Mountain View 
        ├─ Провайдер:  Google LLC 
        └─ Организация:  Google LLC 

     3. facebook.com
        ├─ IP-адрес:  157.240.214.35 
        ├─ Страна:  United Kingdom 
        ├─ Город:  London 
        ├─ Провайдер:  Facebook, Inc. 
        └─ Организация:  Facebook, Inc. 

     4. baidu.com
        ├─ IP-адрес:  220.181.7.203 
        ├─ Страна:  China 
        ├─ Город:  Beijing 
        ├─ Провайдер:  IDC, China Telecommunications Corporation 
        └─ Организация:   

     5. wikipedia.org
        ├─ IP-адрес:  185.15.59.224 
        ├─ Страна:  The Netherlands 
        ├─ Город:  Amsterdam 
        ├─ Провайдер:  Wikimedia esams infra 
        └─ Организация:   

     6. qq.com
        ├─ IP-адрес:  113.108.81.189 
        ├─ Страна:  China 
        ├─ Город:  Guangzhou 
        ├─ Провайдер:  Chinanet 
        └─ Организация:  Chinanet GD 

     7. taobao.com
        ├─ IP-адрес:  2408:4001:f10::6f 
        ├─ Страна:  China 
        ├─ Город:  Beijing 
        ├─ Провайдер:  Hangzhou Alibaba Advertising Co 
        └─ Организация:  Aliyun Computing Co., LTD 

     8. yahoo.com
        ├─ IP-адрес:  2001:4998:124:1507::f001 
        ├─ Страна:  United States 
        ├─ Город:  Lockport 
        ├─ Провайдер:  Oath Holdings Inc. 
        └─ Организация:  Oath Holdings Inc 

     9. amazon.com
        ├─ IP-адрес:  98.87.170.71 
        ├─ Страна:  United States 
        ├─ Город:  Ashburn 
        ├─ Провайдер:  AT&T Corp. 
        └─ Организация:  Amazon Technologies Inc. (us-east-1) 

    10. twitter.com
        ├─ IP-адрес:  162.159.140.229 
        ├─ Страна:  Canada 
        ├─ Город:  Toronto 
        ├─ Провайдер:  Cloudflare, Inc. 
        └─ Организация:  Cloudflare, Inc. 

     ================================================== 
    ГЕОГРАФИЧЕСКОЕ РАСПРЕДЕЛЕНИЕ
    ================================================== 
    # A tibble: 5 × 2
      Country         Количество
      <chr>                <int>
    1 United States            4
    2 China                    3
    3 Canada                   1
    4 The Netherlands          1
    5 United Kingdom           1

    Данные сохранены в файл: geo_analysis_results.csv

``` r
cat("\nПроцесс завершен.\n")
```


    Процесс завершен.

## Оценка результата

В результате практической работы мы поняли как анализировать данные DNS
с помощью языка R.

## Вывод

Таким образом, мы научились, используя язык r, скачивать и анализировать
данные DNS.
