# Исследование информации о состоянии беспроводных сетей
Loona610@yandex.ru

## Цель работы

1.  Получить знания о методах исследования радиоэлектронной обстановки.
2.  Составить представление о механизмах работы Wi-Fi сетей на канальном
    и сетевом уровне модели OSI.
3.  Зекрепить практические навыки использования языка программирования R
    для обработки данных
4.  Закрепить знания основных функций обработки данных экосистемы
    tidyverse языка R

## Исходные данные

1.  Программное обеспечение ОС Windows 11
2.  VS Code
3.  Интерпретатор языка R 4.5.1

## План

1.  Импортируйте данные –
    https://storage.yandexcloud.net/dataset.ctfsec/P2_wifi_data.csv
    Данные были собраны с помощью анализатора беспроводного трафика
    airodump-ng
2.  Привести датасеты в вид “аккуратных данных”, преобразовать типы
    столбцов в соответствии с типом данных
3.  Просмотрите общую структуру данных с помощью функции glimpse()
4.  Произвести анализ данных.
5.  Определить небезопасные точки доступа (без шифрования – OPN)
6.  Определить производителя для каждого обнаруженного устройства
7.  Выявить устройства, использующие последнюю версию протокола
    шифрования WPA3, и названия точек доступа, реализованных на этих
    устройствах
8.  Отсортировать точки доступа по интервалу времени, в течение которого
    они находились на связи, по убыванию.
9.  Обнаружить топ-10 самых быстрых точек доступа.
10. Отсортировать точки доступа по частоте отправки запросов (beacons) в
    единицу времени по их убыванию. 11.Определить производителя для
    каждого обнаруженного устройства (пользоваться базой данных
    производителей из состава Wireshark или онлайн сервисами OUI lookup)
11. Обнаружить устройства, которые НЕ рандомизируют свой MAC адрес
12. Кластеризовать запросы от устройств к точкам доступа по их именам.
    Определить время появления устройства в зоне радиовидимости и время
    выхода его из нее.
13. Оценить стабильность уровня сигнала внури кластера во времени.
    Выявить наиболее стабильный кластер.

## Шаги:

``` r
options(repos = c(CRAN = "https://mirror.truenetwork.ru/CRAN/"))
install.packages("readr")
```

    Устанавливаю пакет в 'D:/Rlib'
    (потому что 'lib' не определено)

    пакет 'readr' успешно распакован, MD5-суммы проверены

    Warning: не могу удалить прежнюю установку пакета 'readr'

    Warning in file.copy(savedcopy, lib, recursive = TRUE): проблема с копированием
    D:\Rlib\00LOCK\readr\libs\x64\readr.dll в D:\Rlib\readr\libs\x64\readr.dll:
    Permission denied

    Warning: восстановлен 'readr'


    Скачанные бинарные пакеты находятся в
        D:\Rtemp\RtmpIRifHT\downloaded_packages

``` r
install.packages("dplyr")
```

    Устанавливаю пакет в 'D:/Rlib'
    (потому что 'lib' не определено)

    пакет 'dplyr' успешно распакован, MD5-суммы проверены

    Warning: не могу удалить прежнюю установку пакета 'dplyr'

    Warning in file.copy(savedcopy, lib, recursive = TRUE): проблема с копированием
    D:\Rlib\00LOCK\dplyr\libs\x64\dplyr.dll в D:\Rlib\dplyr\libs\x64\dplyr.dll:
    Permission denied

    Warning: восстановлен 'dplyr'


    Скачанные бинарные пакеты находятся в
        D:\Rtemp\RtmpIRifHT\downloaded_packages

``` r
install.packages("tidyr") 
```

    Устанавливаю пакет в 'D:/Rlib'
    (потому что 'lib' не определено)

    пакет 'tidyr' успешно распакован, MD5-суммы проверены

    Warning: не могу удалить прежнюю установку пакета 'tidyr'

    Warning in file.copy(savedcopy, lib, recursive = TRUE): проблема с копированием
    D:\Rlib\00LOCK\tidyr\libs\x64\tidyr.dll в D:\Rlib\tidyr\libs\x64\tidyr.dll:
    Permission denied

    Warning: восстановлен 'tidyr'


    Скачанные бинарные пакеты находятся в
        D:\Rtemp\RtmpIRifHT\downloaded_packages

``` r
install.packages("stringr") 
```

    Устанавливаю пакет в 'D:/Rlib'
    (потому что 'lib' не определено)

    пакет 'stringr' успешно распакован, MD5-суммы проверены

    Скачанные бинарные пакеты находятся в
        D:\Rtemp\RtmpIRifHT\downloaded_packages

``` r
install.packages("lubridate") 
```

    Устанавливаю пакет в 'D:/Rlib'
    (потому что 'lib' не определено)

    пакет 'lubridate' успешно распакован, MD5-суммы проверены

    Warning: не могу удалить прежнюю установку пакета 'lubridate'

    Warning in file.copy(savedcopy, lib, recursive = TRUE): проблема с копированием
    D:\Rlib\00LOCK\lubridate\libs\x64\lubridate.dll в
    D:\Rlib\lubridate\libs\x64\lubridate.dll: Permission denied

    Warning: восстановлен 'lubridate'


    Скачанные бинарные пакеты находятся в
        D:\Rtemp\RtmpIRifHT\downloaded_packages

``` r
install.packages("janitor") 
```

    Устанавливаю пакет в 'D:/Rlib'
    (потому что 'lib' не определено)

    пакет 'janitor' успешно распакован, MD5-суммы проверены

    Скачанные бинарные пакеты находятся в
        D:\Rtemp\RtmpIRifHT\downloaded_packages

``` r
install.packages("R.utils") 
```

    Устанавливаю пакет в 'D:/Rlib'
    (потому что 'lib' не определено)

    пакет 'R.utils' успешно распакован, MD5-суммы проверены

    Скачанные бинарные пакеты находятся в
        D:\Rtemp\RtmpIRifHT\downloaded_packages

``` r
install.packages("jsonlite") 
```

    Устанавливаю пакет в 'D:/Rlib'
    (потому что 'lib' не определено)

    пакет 'jsonlite' успешно распакован, MD5-суммы проверены

    Warning: не могу удалить прежнюю установку пакета 'jsonlite'

    Warning in file.copy(savedcopy, lib, recursive = TRUE): проблема с копированием
    D:\Rlib\00LOCK\jsonlite\libs\x64\jsonlite.dll в
    D:\Rlib\jsonlite\libs\x64\jsonlite.dll: Permission denied

    Warning: восстановлен 'jsonlite'


    Скачанные бинарные пакеты находятся в
        D:\Rtemp\RtmpIRifHT\downloaded_packages

``` r
install.packages("httr") 
```

    Устанавливаю пакет в 'D:/Rlib'
    (потому что 'lib' не определено)

    пакет 'httr' успешно распакован, MD5-суммы проверены

    Скачанные бинарные пакеты находятся в
        D:\Rtemp\RtmpIRifHT\downloaded_packages

``` r
install.packages("V8") 
```

    Устанавливаю пакет в 'D:/Rlib'
    (потому что 'lib' не определено)

    пакет 'V8' успешно распакован, MD5-суммы проверены

    Warning: не могу удалить прежнюю установку пакета 'V8'

    Warning in file.copy(savedcopy, lib, recursive = TRUE): проблема с копированием
    D:\Rlib\00LOCK\V8\libs\x64\V8.dll в D:\Rlib\V8\libs\x64\V8.dll: Permission
    denied

    Warning: восстановлен 'V8'


    Скачанные бинарные пакеты находятся в
        D:\Rtemp\RtmpIRifHT\downloaded_packages

``` r
install.packages("igraph") 
```

    Устанавливаю пакет в 'D:/Rlib'
    (потому что 'lib' не определено)

    пакет 'igraph' успешно распакован, MD5-суммы проверены

    Warning: не могу удалить прежнюю установку пакета 'igraph'

    Warning in file.copy(savedcopy, lib, recursive = TRUE): проблема с копированием
    D:\Rlib\00LOCK\igraph\libs\x64\igraph.dll в D:\Rlib\igraph\libs\x64\igraph.dll:
    Permission denied

    Warning: восстановлен 'igraph'


    Скачанные бинарные пакеты находятся в
        D:\Rtemp\RtmpIRifHT\downloaded_packages

``` r
install.packages("fpc") 
```

    Устанавливаю пакет в 'D:/Rlib'
    (потому что 'lib' не определено)

    пакет 'fpc' успешно распакован, MD5-суммы проверены

    Скачанные бинарные пакеты находятся в
        D:\Rtemp\RtmpIRifHT\downloaded_packages

``` r
install.packages("mclust")
```

    Устанавливаю пакет в 'D:/Rlib'
    (потому что 'lib' не определено)

    пакет 'mclust' успешно распакован, MD5-суммы проверены

    Warning: не могу удалить прежнюю установку пакета 'mclust'

    Warning in file.copy(savedcopy, lib, recursive = TRUE): проблема с копированием
    D:\Rlib\00LOCK\mclust\libs\x64\mclust.dll в D:\Rlib\mclust\libs\x64\mclust.dll:
    Permission denied

    Warning: восстановлен 'mclust'


    Скачанные бинарные пакеты находятся в
        D:\Rtemp\RtmpIRifHT\downloaded_packages

``` r
library("readr")
```

    Warning: пакет 'readr' был собран под R версии 4.5.2

``` r
library("dplyr")
```


    Присоединяю пакет: 'dplyr'

    Следующие объекты скрыты от 'package:stats':

        filter, lag

    Следующие объекты скрыты от 'package:base':

        intersect, setdiff, setequal, union

``` r
library("tidyr") 
```

    Warning: пакет 'tidyr' был собран под R версии 4.5.2

``` r
library("stringr") 
```

    Warning: пакет 'stringr' был собран под R версии 4.5.2

``` r
library("lubridate") 
```


    Присоединяю пакет: 'lubridate'

    Следующие объекты скрыты от 'package:base':

        date, intersect, setdiff, union

``` r
library("janitor") 
```

    Warning: пакет 'janitor' был собран под R версии 4.5.2


    Присоединяю пакет: 'janitor'

    Следующие объекты скрыты от 'package:stats':

        chisq.test, fisher.test

``` r
library("R.utils") 
```

    Warning: пакет 'R.utils' был собран под R версии 4.5.2

    Загрузка требуемого пакета: R.oo

    Загрузка требуемого пакета: R.methodsS3

    R.methodsS3 v1.8.2 (2022-06-13 22:00:14 UTC) successfully loaded. See ?R.methodsS3 for help.

    R.oo v1.27.1 (2025-05-02 21:00:05 UTC) successfully loaded. See ?R.oo for help.


    Присоединяю пакет: 'R.oo'

    Следующий объект скрыт от 'package:R.methodsS3':

        throw

    Следующие объекты скрыты от 'package:methods':

        getClasses, getMethods

    Следующие объекты скрыты от 'package:base':

        attach, detach, load, save

    R.utils v2.13.0 (2025-02-24 21:20:02 UTC) successfully loaded. See ?R.utils for help.


    Присоединяю пакет: 'R.utils'

    Следующий объект скрыт от 'package:tidyr':

        extract

    Следующий объект скрыт от 'package:utils':

        timestamp

    Следующие объекты скрыты от 'package:base':

        cat, commandArgs, getOption, isOpen, nullfile, parse, use, warnings

``` r
library("jsonlite") 
```


    Присоединяю пакет: 'jsonlite'

    Следующий объект скрыт от 'package:R.utils':

        validate

``` r
library("httr") 
```

    Warning: пакет 'httr' был собран под R версии 4.5.2

``` r
library("V8") 
```

    Using V8 engine 11.9.169.6

``` r
library("igraph") 
```

    Warning: пакет 'igraph' был собран под R версии 4.5.2


    Присоединяю пакет: 'igraph'

    Следующий объект скрыт от 'package:R.oo':

        hierarchy

    Следующие объекты скрыты от 'package:lubridate':

        %--%, union

    Следующий объект скрыт от 'package:tidyr':

        crossing

    Следующие объекты скрыты от 'package:dplyr':

        as_data_frame, groups, union

    Следующие объекты скрыты от 'package:stats':

        decompose, spectrum

    Следующий объект скрыт от 'package:base':

        union

``` r
library("fpc") 
```

    Warning: пакет 'fpc' был собран под R версии 4.5.2

``` r
library("mclust")
```

    Warning: пакет 'mclust' был собран под R версии 4.5.2

    Package 'mclust' version 6.1.2
    Type 'citation("mclust")' for citing this R package in publications.


    Присоединяю пакет: 'mclust'

    Следующий объект скрыт от 'package:dplyr':

        count

``` r
#Задание 1: Импорт данных
filename <- "P2_wifi_data.csv"
url <- "https://storage.yandexcloud.net/dataset.ctfsec/P2_wifi_data.csv"
if (!file.exists(filename)) {
  download.file(url, destfile = filename, mode = "wb")
}
raw_text <- read_lines(filename)
station_header <- "Station MAC, First time seen, Last time seen, Power, # packets, BSSID, Probed ESSIDs"
header_station_idx <- str_which(raw_text, paste0("^", station_header, "$"))
if (length(header_station_idx) == 0) {
  header_station_idx <- str_which(raw_text, "^Station MAC,")

  if (length(header_station_idx) == 0) {
    stop()
  }
}
all_empty_before_station <- str_which(raw_text[1:(header_station_idx - 1)], "^\\s*$")
if (length(all_empty_before_station) == 0) {
  stop()
}
separator_idx <- all_empty_before_station[length(all_empty_before_station)]
num_lines_ap <- separator_idx - 3
if (num_lines_ap > 0) {
  ap_col_types <- cols_only(
    "BSSID" = col_character(),
    "First time seen" = col_character(),
    "Last time seen" = col_character(),
    "channel" = col_number(),
    "Speed" = col_number(),
    "Privacy" = col_character(),
    "Cipher" = col_character(),
    "Authentication" = col_character(),
    "Power" = col_number(),
    "# beacons" = col_number(),
    "# IV" = col_number(),
    "LAN IP" = col_character(),
    "ID-length" = col_number(),
    "ESSID" = col_character(),
    "Key" = col_character()
  )
  wifi_ap_data <- read_csv(filename, n_max = num_lines_ap,
                           col_types = ap_col_types,
                           show_col_types = FALSE)
} else {
    stop()
}
skip_lines_station <- header_station_idx - 1
station_col_types <- cols_only(
  "Station MAC" = col_character(),
  "First time seen" = col_character(),
  "Last time seen" = col_character(),
  "Power" = col_number(),
  "# packets" = col_number(),
  "BSSID" = col_character(),
  "Probed ESSIDs" = col_character()
)
wifi_station_data <- read_csv(filename, skip = skip_lines_station,
                              col_types = station_col_types,
                              show_col_types = FALSE)
```

    Warning: One or more parsing issues, call `problems()` on your data frame for details,
    e.g.:
      dat <- vroom(...)
      problems(dat)

``` r
#Задание 2-3: Приведение даннных к виду "аккуратных" и просмотр
names(wifi_ap_data) <- janitor::make_clean_names(names(wifi_ap_data))
wifi_ap_data <- wifi_ap_data %>%
  mutate(
    first_time_seen = lubridate::ymd_hms(first_time_seen, tz = "UTC"), # Преобразуем в POSIXct
    last_time_seen = lubridate::ymd_hms(last_time_seen, tz = "UTC")
  )
wifi_ap_data <- wifi_ap_data %>%
  mutate_if(is.character, ~trimws(.x))
names(wifi_station_data) <- janitor::make_clean_names(names(wifi_station_data))
wifi_station_data <- wifi_station_data %>%
  mutate(
    first_time_seen = lubridate::ymd_hms(first_time_seen, tz = "UTC"),
    last_time_seen = lubridate::ymd_hms(last_time_seen, tz = "UTC")
  )
wifi_station_data <- wifi_station_data %>%
  mutate_if(is.character, ~trimws(.x))
cat("\n--- Типы столбцов AP (после преобразований) ---\n")
```


    --- Типы столбцов AP (после преобразований) ---

``` r
glimpse(wifi_ap_data)
```

    Rows: 167
    Columns: 15
    $ bssid           <chr> "BE:F1:71:D5:17:8B", "6E:C7:EC:16:DA:1A", "9A:75:A8:B9…
    $ first_time_seen <dttm> 2023-07-28 09:13:03, 2023-07-28 09:13:03, 2023-07-28 …
    $ last_time_seen  <dttm> 2023-07-28 11:50:50, 2023-07-28 11:55:12, 2023-07-28 …
    $ channel         <dbl> 1, 1, 1, 7, 6, 6, 11, 11, 11, 1, 6, 14, 11, 11, 6, 6, …
    $ speed           <dbl> 195, 130, 360, 360, 130, 130, 195, 130, 130, 195, 180,…
    $ privacy         <chr> "WPA2", "WPA2", "WPA2", "WPA2", "WPA2", "OPN", "WPA2",…
    $ cipher          <chr> "CCMP", "CCMP", "CCMP", "CCMP", "CCMP", NA, "CCMP", "C…
    $ authentication  <chr> "PSK", "PSK", "PSK", "PSK", "PSK", NA, "PSK", "PSK", "…
    $ power           <dbl> -30, -30, -68, -37, -57, -63, -27, -38, -38, -66, -42,…
    $ number_beacons  <dbl> 846, 750, 694, 510, 647, 251, 1647, 1251, 704, 617, 13…
    $ number_iv       <dbl> 504, 116, 26, 21, 6, 3430, 80, 11, 0, 0, 86, 0, 0, 0, …
    $ lan_ip          <chr> "0.  0.  0.  0", "0.  0.  0.  0", "0.  0.  0.  0", "0.…
    $ id_length       <dbl> 12, 4, 2, 14, 25, 13, 12, 13, 24, 12, 10, 0, 24, 24, 1…
    $ essid           <chr> "C322U13 3965", "Cnet", "KC", "POCO X5 Pro 5G", NA, "M…
    $ key             <chr> NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA…

``` r
cat("\n--- Типы столбцов Station (после преобразований) ---\n")
```


    --- Типы столбцов Station (после преобразований) ---

``` r
glimpse(wifi_station_data)
```

    Rows: 12,081
    Columns: 7
    $ station_mac     <chr> "CA:66:3B:8F:56:DD", "96:35:2D:3D:85:E6", "5C:3A:45:9E…
    $ first_time_seen <dttm> 2023-07-28 09:13:03, 2023-07-28 09:13:03, 2023-07-28 …
    $ last_time_seen  <dttm> 2023-07-28 10:59:44, 2023-07-28 09:13:03, 2023-07-28 …
    $ power           <dbl> -33, -65, -39, -61, -53, -43, -31, -71, -74, -65, -45,…
    $ number_packets  <dbl> 858, 4, 432, 958, 1, 344, 163, 3, 115, 437, 265, 77, 7…
    $ bssid           <chr> "BE:F1:71:D5:17:8B", "(not associated)", "BE:F1:71:D6:…
    $ probed_essi_ds  <chr> "C322U13 3965", "IT2 Wireless", "C322U21 0566", "C322U…

``` r
#Задание 5: Определение небезопасных точек доступа
unsafe_aps <- wifi_ap_data %>%
  filter(privacy == "OPN")

print(unsafe_aps)
```

    # A tibble: 42 × 15
       bssid    first_time_seen     last_time_seen      channel speed privacy cipher
       <chr>    <dttm>              <dttm>                <dbl> <dbl> <chr>   <chr> 
     1 E8:28:C… 2023-07-28 09:13:03 2023-07-28 11:55:38       6   130 OPN     <NA>  
     2 E8:28:C… 2023-07-28 09:13:06 2023-07-28 11:55:12       6   130 OPN     <NA>  
     3 E8:28:C… 2023-07-28 09:13:06 2023-07-28 11:55:11       6   130 OPN     <NA>  
     4 E8:28:C… 2023-07-28 09:13:06 2023-07-28 11:55:10       6    -1 OPN     <NA>  
     5 00:25:0… 2023-07-28 09:13:06 2023-07-28 11:56:21      44    -1 OPN     <NA>  
     6 E8:28:C… 2023-07-28 09:13:09 2023-07-28 11:56:05      11   130 OPN     <NA>  
     7 E8:28:C… 2023-07-28 09:13:13 2023-07-28 10:27:06       6   130 OPN     <NA>  
     8 E8:28:C… 2023-07-28 09:13:13 2023-07-28 10:39:43       6   130 OPN     <NA>  
     9 E8:28:C… 2023-07-28 09:13:17 2023-07-28 11:52:32       1   130 OPN     <NA>  
    10 E8:28:C… 2023-07-28 09:13:50 2023-07-28 11:43:39      11   130 OPN     <NA>  
    # ℹ 32 more rows
    # ℹ 8 more variables: authentication <chr>, power <dbl>, number_beacons <dbl>,
    #   number_iv <dbl>, lan_ip <chr>, id_length <dbl>, essid <chr>, key <chr>

``` r
#Задание 6: Определение производителя по OUI
get_manufacturer_oui <- function(oui) {
  if (is.na(oui) || oui == "") {
    return(NA_character_)
  }
  url <- paste0("https://api.macvendors.com/", oui)
  response <- GET(url)
  if (status_code(response) == 200) {
    manufacturer <- content(response, "text", encoding = "UTF-8")
    if (is.na(manufacturer) || manufacturer == "" || grepl("Not Found|Vendor not found|Unknown", manufacturer, ignore.case = TRUE)) {
      return(NA_character_)
    }
    return(manufacturer)
  } else if (status_code(response) == 404) {
      return(NA_character_)
  } else if (status_code(response) == 429) {
      Sys.sleep(5)
      return(NA_character_)
  } else {
    return(NA_character_)
  }
}
all_ap_macs <- wifi_ap_data$bssid
all_ap_macs_clean <- all_ap_macs[!is.na(all_ap_macs)]
unique_ouis_ap <- unique(substr(all_ap_macs_clean, 1, 8))
manufacturers_ap <- character(length(unique_ouis_ap))
names(manufacturers_ap) <- unique_ouis_ap
for (oui in unique_ouis_ap) {
  if (is.na(oui) || oui == "") {
    manufacturers_ap[oui] <- NA_character_
    next
  }
  manufacturer <- get_manufacturer_oui(oui)
  manufacturers_ap[oui] <- manufacturer
  Sys.sleep(1.5)
}
manufacturer_lookup_table <- tibble(
  oui = names(manufacturers_ap),
  manufacturer = manufacturers_ap
)
wifi_ap_data_with_manuf <- wifi_ap_data %>%
  mutate(
    oui = ifelse(is.na(bssid) | bssid == "", NA_character_, substr(bssid, 1, 8))
  ) %>%
  left_join(
    manufacturer_lookup_table,
    by = c("oui" = "oui")
  ) %>%
  select(-oui) %>%
  relocate(manufacturer, .after = bssid)
wifi_ap_data <- wifi_ap_data_with_manuf
print(wifi_ap_data)
```

    # A tibble: 167 × 16
       bssid      manufacturer first_time_seen     last_time_seen      channel speed
       <chr>      <chr>        <dttm>              <dttm>                <dbl> <dbl>
     1 BE:F1:71:… <NA>         2023-07-28 09:13:03 2023-07-28 11:50:50       1   195
     2 6E:C7:EC:… <NA>         2023-07-28 09:13:03 2023-07-28 11:55:12       1   130
     3 9A:75:A8:… <NA>         2023-07-28 09:13:03 2023-07-28 11:53:31       1   360
     4 4A:EC:1E:… <NA>         2023-07-28 09:13:03 2023-07-28 11:04:01       7   360
     5 D2:6D:52:… <NA>         2023-07-28 09:13:03 2023-07-28 10:30:19       6   130
     6 E8:28:C1:… Eltex Enter… 2023-07-28 09:13:03 2023-07-28 11:55:38       6   130
     7 BE:F1:71:… <NA>         2023-07-28 09:13:03 2023-07-28 11:50:44      11   195
     8 0A:C5:E1:… <NA>         2023-07-28 09:13:03 2023-07-28 11:36:31      11   130
     9 38:1A:52:… Seiko Epson… 2023-07-28 09:13:03 2023-07-28 10:25:02      11   130
    10 BE:F1:71:… <NA>         2023-07-28 09:13:03 2023-07-28 10:29:21       1   195
    # ℹ 157 more rows
    # ℹ 10 more variables: privacy <chr>, cipher <chr>, authentication <chr>,
    #   power <dbl>, number_beacons <dbl>, number_iv <dbl>, lan_ip <chr>,
    #   id_length <dbl>, essid <chr>, key <chr>

``` r
#Задание 7: Выявить устройства, использующие последнюю версию протокола шифрования WPA3
wpa3_aps <- wifi_ap_data %>%
  filter(grepl("WPA3", authentication, ignore.case = TRUE) | grepl("WPA3", privacy, ignore.case = TRUE))
print(wpa3_aps %>% select (bssid,privacy,essid))
```

    # A tibble: 8 × 3
      bssid             privacy   essid                                         
      <chr>             <chr>     <chr>                                         
    1 26:20:53:0C:98:E8 WPA3 WPA2  <NA>                                         
    2 A2:FE:FF:B8:9B:C9 WPA3 WPA2 "Christie’s"                                  
    3 96:FF:FC:91:EF:64 WPA3 WPA2  <NA>                                         
    4 CE:48:E7:86:4E:33 WPA3 WPA2 "iPhone (Анастасия)"                          
    5 8E:1F:94:96:DA:FD WPA3 WPA2 "iPhone (Анастасия)"                          
    6 BE:FD:EF:18:92:44 WPA3 WPA2 "Димасик"                                     
    7 3A:DA:00:F9:0C:02 WPA3 WPA2 "iPhone XS Max \U0001f98a\U0001f431\U0001f98a"
    8 76:C5:A0:70:08:96 WPA3 WPA2  <NA>                                         

``` r
#Задание 8: Сортировка точек доступа по интервалу времени на связи (с учётом сессий)
join_sessions <- function(ap_data_single_bssid, threshold_seconds = 2700) {
  ap_data_single_bssid <- ap_data_single_bssid %>% filter(!is.na(first_time_seen) & !is.na(last_time_seen))
  if (nrow(ap_data_single_bssid) == 0) return(tibble(bssid = character(), total_duration_seconds = numeric()))
  ap_data_sorted <- ap_data_single_bssid %>% arrange(first_time_seen)
  first_times <- ap_data_sorted$first_time_seen
  last_times <- ap_data_sorted$last_time_seen
  session_starts <- first_times[1]
  session_ends <- last_times[1]
  for (i in 2:nrow(ap_data_sorted)) {
    current_start <- first_times[i]
    current_end <- last_times[i]
    last_end <- session_ends[length(session_ends)] # Последнее известное время окончания сессии
    time_diff <- as.numeric(current_start - last_end, units = "secs")
    if (is.na(time_diff) || time_diff > threshold_seconds) {
      session_starts <- c(session_starts, current_start)
      session_ends <- c(session_ends, current_end)
    } else {
      session_ends[length(session_ends)] <- max(session_ends[length(session_ends)], current_end)
    }
  }
  durations <- as.numeric(session_ends - session_starts, units = "secs")
  result <- tibble(
    bssid = rep(ap_data_sorted$bssid[1], length(durations)), # Повторяем BSSID для каждой сессии
    total_duration_seconds = durations
  )

  return(result)
}
wifi_ap_sorted_by_duration <- wifi_ap_data %>%
  filter(!is.na(first_time_seen) & !is.na(last_time_seen)) %>%
  group_by(bssid) %>%
  summarise(
    sessions_data = list(join_sessions(cur_data())),
    .groups = 'drop'
  ) %>%
  unnest(sessions_data) %>%
  group_by(bssid) %>%
  summarise(
    total_time_on_channel_seconds = sum(total_duration_seconds, na.rm = TRUE),
    .groups = 'drop'
  ) %>%
  arrange(desc(total_time_on_channel_seconds))
```

    Warning: There were 168 warnings in `summarise()`.
    The first warning was:
    ℹ In argument: `sessions_data = list(join_sessions(cur_data()))`.
    ℹ In group 1: `bssid = "00:00:00:00:00:00"`.
    Caused by warning:
    ! `cur_data()` was deprecated in dplyr 1.1.0.
    ℹ Please use `pick()` instead.
    ℹ Run `dplyr::last_dplyr_warnings()` to see the 167 remaining warnings.

``` r
print(wifi_ap_sorted_by_duration)
```

    # A tibble: 167 × 2
       bssid             total_time_on_channel_seconds
       <chr>                                     <dbl>
     1 00:25:00:FF:94:73                         19590
     2 E8:28:C1:DD:04:52                         19552
     3 E8:28:C1:DC:B2:52                         19510
     4 08:3A:2F:56:35:FE                         19492
     5 6E:C7:EC:16:DA:1A                         19458
     6 E8:28:C1:DC:B2:50                         19452
     7 48:5B:39:F9:7A:48                         19450
     8 E8:28:C1:DC:B2:51                         19450
     9 E8:28:C1:DC:FF:F2                         19448
    10 8E:55:4A:85:5B:01                         19446
    # ℹ 157 more rows

``` r
#Задание 9: Обнаружить топ-10 самых быстрых точек доступа

top_10_fastest_aps <- wifi_ap_data %>%
  filter(!is.na(speed)) %>%
  arrange(desc(speed)) %>%
  slice_head(n = 10)
print(select(top_10_fastest_aps, bssid, essid, speed, manufacturer))
```

    # A tibble: 10 × 4
       bssid             essid              speed manufacturer         
       <chr>             <chr>              <dbl> <chr>                
     1 26:20:53:0C:98:E8 <NA>                 866 <NA>                 
     2 96:FF:FC:91:EF:64 <NA>                 866 <NA>                 
     3 CE:48:E7:86:4E:33 iPhone (Анастасия)   866 <NA>                 
     4 8E:1F:94:96:DA:FD iPhone (Анастасия)   866 <NA>                 
     5 9A:75:A8:B9:04:1E KC                   360 <NA>                 
     6 4A:EC:1E:DB:BF:95 POCO X5 Pro 5G       360 <NA>                 
     7 56:C5:2B:9F:84:90 OnePlus 6T           360 <NA>                 
     8 E8:28:C1:DC:B2:41 MIREA_GUESTS         360 Eltex Enterprise Ltd.
     9 E8:28:C1:DC:B2:40 MIREA_HOTSPOT        360 Eltex Enterprise Ltd.
    10 E8:28:C1:DC:B2:42 <NA>                 360 Eltex Enterprise Ltd.

``` r
#Задание 10: Сортировка точек доступа по частоте beacon-пакетов
wifi_ap_with_beacon_freq <- wifi_ap_data %>%
  mutate(
    time_diff_seconds = as.numeric(difftime(last_time_seen, first_time_seen, units = "secs")),
    beacon_frequency = ifelse(
      is.na(time_diff_seconds) | time_diff_seconds == 0,
      NA_real_,
      number_beacons / time_diff_seconds
    )
  ) %>%
  filter(!is.na(beacon_frequency))
wifi_ap_sorted_by_beacon_freq <- wifi_ap_with_beacon_freq %>%
  arrange(desc(beacon_frequency))
print(select(wifi_ap_sorted_by_beacon_freq, bssid, essid, number_beacons, time_diff_seconds, beacon_frequency))
```

    # A tibble: 124 × 5
       bssid             essid     number_beacons time_diff_seconds beacon_frequency
       <chr>             <chr>              <dbl>             <dbl>            <dbl>
     1 F2:30:AB:E9:03:ED "iPhone …              6                 7            0.857
     2 B2:CF:C0:00:4A:60 "Михаил'…              4                 5            0.8  
     3 3A:DA:00:F9:0C:02 "iPhone …              5                 9            0.556
     4 02:BC:15:7E:D5:DC "MT_FREE"              1                 2            0.5  
     5 00:3E:1A:5D:14:45 "MT_FREE"              1                 2            0.5  
     6 76:C5:A0:70:08:96  <NA>                  1                 2            0.5  
     7 D2:25:91:F6:6C:D8 "Саня"                 5                13            0.385
     8 BE:F1:71:D6:10:D7 "C322U21…           1647              9461            0.174
     9 00:03:7A:1A:03:56 "MT_FREE"              1                 6            0.167
    10 38:1A:52:0D:84:D7 "EBFCD57…            704              4319            0.163
    # ℹ 114 more rows

``` r
#Задание 11: Определение производителя для клиентских устройств
#get_manufacturer_oui <- function(oui) {
#  if (is.na(oui) || oui == "") {
#    return(NA_character_)
#  }
#  url <- paste0("https://api.macvendors.com/", oui)
#  response <- GET(url)
#  if (status_code(response) == 200) {
#    manufacturer <- content(response, "text", encoding = "UTF-8")
#    if (is.na(manufacturer) || manufacturer == "" || grepl("Not Found|Vendor not found|Unknown", manufacturer, #ignore.case = TRUE)) {
#      return(NA_character_)
#    }
#    return(manufacturer)
#  } else if (status_code(response) == 404) {
#      return(NA_character_)
#  } else if (status_code(response) == 429) {
#      Sys.sleep(5)
#      return(NA_character_)
#  } else {
#    return(NA_character_)
#  }
#}
#
#all_station_macs <- wifi_station_data$station_mac
#all_station_macs_clean <- all_station_macs[!is.na(all_station_macs)]
#unique_ouis_station <- unique(substr(all_station_macs_clean, 1, 8))
#
#cat("Найдено уникальных OUI для клиентских устройств:", length(unique_ouis_station), "\n")
#manufacturers_station <- character(length(unique_ouis_station))
#names(manufacturers_station) <- unique_ouis_station
#for (oui in unique_ouis_station) {
#  if (is.na(oui) || oui == "") {
#    manufacturers_station[oui] <- NA_character_
#    next
#  }
#  manufacturer <- get_manufacturer_oui(oui)
#  manufacturers_station[oui] <- manufacturer
#  Sys.sleep(1.5)
#}
#manufacturer_lookup_table_station <- tibble(
#  oui = names(manufacturers_station),
#  manufacturer = manufacturers_station
#)
#wifi_station_data_with_manuf <- wifi_station_data %>%
#  mutate(
#    oui = ifelse(is.na(station_mac) | station_mac == "", NA_character_, substr(station_mac, 1, 8))
#  ) %>%
#  left_join(
#    manufacturer_lookup_table_station,
#    by = c("oui" = "oui")
#  ) %>%
#  select(-oui) %>%
#  relocate(manufacturer, .after = station_mac)
#wifi_station_data <- wifi_station_data_with_manuf
#cat("\n--- Таблица клиентов (Station) после объединения с производителями ---\n")
#print(wifi_station_data)
```

``` r
#Задание 12: Обнаружить устройства, которые НЕ рандомизируют свой MAC адрес
is_not_randomized_vectorized <- function(mac_addresses) {
  is_na_or_empty <- is.na(mac_addresses) | (mac_addresses == "")
  result <- rep(NA, length(mac_addresses))
  valid_indices <- !is_na_or_empty
  valid_macs <- mac_addresses[valid_indices]

  if (length(valid_macs) > 0) {
    first_bytes_hex <- substr(valid_macs, 1, 2)
    first_bytes_decimal <- strtoi(first_bytes_hex, base = 16)
    ul_bits_set <- (first_bytes_decimal & 0x02) != 0
    result[valid_indices] <- !ul_bits_set
  }

  return(result)
}

wifi_station_with_check <- wifi_station_data %>%
  mutate(
    does_not_randomize = is_not_randomized_vectorized(station_mac)
  )

devices_not_randomizing <- wifi_station_with_check %>%
  filter(does_not_randomize == TRUE)
wifi_station_data <- wifi_station_with_check
print(wifi_station_data%>%
        filter(does_not_randomize == TRUE))
```

    # A tibble: 10 × 8
       station_mac      first_time_seen     last_time_seen      power number_packets
       <chr>            <dttm>              <dttm>              <dbl>          <dbl>
     1 00:95:69:E7:7F:… 2023-07-28 09:13:11 2023-07-28 11:56:07   -69           2245
     2 00:95:69:E7:7C:… 2023-07-28 09:13:11 2023-07-28 11:56:13   -55           4096
     3 00:95:69:E7:7D:… 2023-07-28 09:13:15 2023-07-28 11:56:17   -33           8171
     4 00:90:4C:E6:54:… 2023-07-28 09:16:59 2023-07-28 10:21:15   -65             16
     5 00:04:35:22:4F:… 2023-07-28 09:46:33 2023-07-28 11:15:49   -83             20
     6 00:E9:3A:67:93:… 2023-07-28 10:15:18 2023-07-28 11:55:11   -73             22
     7 00:E9:3A:F8:10:… 2023-07-28 10:20:19 2023-07-28 10:20:19   -73              1
     8 00:0C:E7:A8:D6:… 2023-07-28 10:22:07 2023-07-28 10:22:08   -67              3
     9 00:98:8C:CE:8E:… 2023-07-28 10:34:53 2023-07-28 10:35:13   -65              4
    10 00:F4:8D:F7:C5:… 2023-07-28 10:45:04 2023-07-28 11:43:26   -73              8
    # ℹ 3 more variables: bssid <chr>, probed_essi_ds <chr>,
    #   does_not_randomize <lgl>

``` r
#Задание 13: Кластеризовать запросы от устройств к точкам доступа по их именам (BSSID)
wifi_station_clustered <- wifi_station_data %>%
  filter(bssid != "(not associated)") %>%
  group_by(bssid) %>%
  summarise(
    cluster_appeared = min(first_time_seen, na.rm = TRUE),
    cluster_disappeared = max(last_time_seen, na.rm = TRUE),
    unique_clients_count = n_distinct(station_mac),
    total_observations = n(),
    .groups = 'drop'
  ) %>%
  arrange(cluster_appeared)
print(wifi_station_clustered)
```

    # A tibble: 74 × 5
       bssid            cluster_appeared    cluster_disappeared unique_clients_count
       <chr>            <dttm>              <dttm>                             <int>
     1 BE:F1:71:D5:17:… 2023-07-28 09:13:03 2023-07-28 11:53:16                    2
     2 BE:F1:71:D6:10:… 2023-07-28 09:13:03 2023-07-28 11:51:54                    1
     3 00:25:00:FF:94:… 2023-07-28 09:13:06 2023-07-28 11:56:21                   45
     4 00:26:99:F2:7A:… 2023-07-28 09:13:06 2023-07-28 11:55:30                    8
     5 1E:93:E3:1B:3C:… 2023-07-28 09:13:06 2023-07-28 11:50:50                    3
     6 E8:28:C1:DC:FF:… 2023-07-28 09:13:06 2023-07-28 11:55:10                    3
     7 0C:80:63:A9:6E:… 2023-07-28 09:13:08 2023-07-28 11:53:36                    2
     8 0A:C5:E1:DB:17:… 2023-07-28 09:13:09 2023-07-28 11:34:42                    1
     9 E8:28:C1:DD:04:… 2023-07-28 09:13:09 2023-07-28 11:55:51                    4
    10 9A:75:A8:B9:04:… 2023-07-28 09:13:14 2023-07-28 11:51:50                    1
    # ℹ 64 more rows
    # ℹ 1 more variable: total_observations <int>

``` r
#Задание 14: Оценка стабильности уровня сигнала внутри кластеров

wifi_station_for_stability <- wifi_station_data %>%
  filter(bssid != "(not associated)", !is.na(power))
cluster_stability_raw <- wifi_station_for_stability %>%
  group_by(bssid) %>%
  summarise(
    mean_power = mean(power, na.rm = TRUE),
    sd_power = sd(power, na.rm = TRUE),
    observation_count = n(),
    .groups = 'drop'
  )
cluster_stability_sorted <- cluster_stability_raw %>%
  arrange(sd_power) %>%
  mutate(
    stability_measure = 1 / (1 + sd_power)
  ) %>%
  select(bssid, everything())
print(cluster_stability_sorted)
```

    # A tibble: 74 × 5
       bssid             mean_power sd_power observation_count stability_measure
       <chr>                  <dbl>    <dbl>             <int>             <dbl>
     1 86:DF:BF:E4:2F:23      -71       0                    2             1    
     2 E8:28:C1:DC:C8:32       -1       0                    2             1    
     3 E8:28:C1:DC:FF:F2      -73       2                    3             0.333
     4 CE:B3:FF:84:45:FC      -85       2.83                 2             0.261
     5 E8:28:C1:DD:04:40      -61       2.83                 2             0.261
     6 8E:55:4A:85:5B:01      -50.3     4.13                 6             0.195
     7 00:26:99:F2:7A:E2      -64.2     4.40                 8             0.185
     8 E8:28:C1:DC:B2:50      -59.8     5.22                 5             0.161
     9 E8:28:C1:DC:F0:90      -63.7     6.11                 3             0.141
    10 00:25:00:FF:94:73      -71.2     6.51                45             0.133
    # ℹ 64 more rows

## Оценка результата

В рамках практческой работы была исследована радиоэлектронная обстановка
и составлено представление о механизмах работы Wi-Fi сетей на канальном
и сетевом уровне модели OSI.

## Вывод

В практической работе мы использовали навыки написания кода на языке
программирования R для обработки данных и закрепили знания основных
функций обработки данных экосистемы tidyverse языка R.