# Исследование информации о состоянии беспроводных сетей
Lona610@yandex.ru

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
library(stringr)
library(readr)
library(httr)
library(dplyr)
```

# 1 Импортируйте данные.

# 2 Привести датасеты в вид “аккуратных данных”, преобразовать типы столбцов в соответствии с типом данных

``` r
library(lubridate)
library(stringr)
library(readr)

lines <- readLines("P2_wifi_data.csv")
header_lines <- grep("BSSID, First time seen", lines)
client_header_line <- grep("Station MAC, First time seen", lines)

ap_data <- read_csv("P2_wifi_data.csv", skip = header_lines[1] - 1, 
                    col_names = c("BSSID", "First_time_seen", "Last_time_seen", 
                                  "channel", "Speed", "Privacy", "Cipher", 
                                  "Authentication", "Power", "beacons", 
                                  "IV", "LAN_IP", "ID_length", "ESSID", "Key"),
                    col_types = cols(
                      BSSID = col_character(),
                      First_time_seen = col_datetime(format = "%Y-%m-%d %H:%M:%S"),
                      Last_time_seen = col_datetime(format = "%Y-%m-%d %H:%M:%S"),
                      channel = col_integer(),
                      Speed = col_integer(),
                      Privacy = col_character(),
                      Cipher = col_character(),
                      Authentication = col_character(),
                      Power = col_integer(),
                      beacons = col_integer(),
                      IV = col_integer(),
                      LAN_IP = col_character(),
                      ID_length = col_integer(),
                      ESSID = col_character(),
                      Key = col_character()
                    ))
```

    Warning: One or more parsing issues, call `problems()` on your data frame for details,
    e.g.:
      dat <- vroom(...)
      problems(dat)

``` r
client_data <- read_csv("P2_wifi_data.csv", skip = client_header_line - 1,
                        col_names = c("Station_MAC", "First_time_seen", "Last_time_seen",
                                      "Power", "packets", "BSSID", "Probed_ESSIDs"),
                        col_types = cols(
                          Station_MAC = col_character(),
                          First_time_seen = col_datetime(format = "%Y-%m-%d %H:%M:%S"),
                          Last_time_seen = col_datetime(format = "%Y-%m-%d %H:%M:%S"),
                          Power = col_integer(),
                          packets = col_integer(),
                          BSSID = col_character(),
                          Probed_ESSIDs = col_character()
                        ))
```

    Warning: One or more parsing issues, call `problems()` on your data frame for details,
    e.g.:
      dat <- vroom(...)
      problems(dat)

``` r
ap_data_clean <- ap_data %>%
  filter(!is.na(First_time_seen), !is.na(Last_time_seen)) %>%
  mutate(ESSID = ifelse(ESSID == "<length: 0>", "Hidden", ESSID)) %>%
  mutate(session_duration = as.numeric(difftime(Last_time_seen, First_time_seen, units = "mins")))

client_data_clean <- client_data %>%
  filter(!is.na(First_time_seen), !is.na(Last_time_seen), 
         BSSID != "(not associated)") %>%
  mutate(session_duration = as.numeric(difftime(Last_time_seen, First_time_seen, units = "mins")))
```

# 3 Просмотрите общую структуру данных с помощью функции glimpse()

``` r
cat("=== СТРУКТУРА ДАННЫХ ТОЧЕК ДОСТУПА ===\n")
```

    === СТРУКТУРА ДАННЫХ ТОЧЕК ДОСТУПА ===

``` r
glimpse(ap_data_clean)
```

    Rows: 12,248
    Columns: 16
    $ BSSID            <chr> "BE:F1:71:D5:17:8B", "6E:C7:EC:16:DA:1A", "9A:75:A8:B…
    $ First_time_seen  <dttm> 2023-07-28 09:13:03, 2023-07-28 09:13:03, 2023-07-28…
    $ Last_time_seen   <dttm> 2023-07-28 11:50:50, 2023-07-28 11:55:12, 2023-07-28…
    $ channel          <int> 1, 1, 1, 7, 6, 6, 11, 11, 11, 1, 6, 14, 11, 11, 6, 6,…
    $ Speed            <int> 195, 130, 360, 360, 130, 130, 195, 130, 130, 195, 180…
    $ Privacy          <chr> "WPA2", "WPA2", "WPA2", "WPA2", "WPA2", "OPN", "WPA2"…
    $ Cipher           <chr> "CCMP", "CCMP", "CCMP", "CCMP", "CCMP", NA, "CCMP", "…
    $ Authentication   <chr> "PSK", "PSK", "PSK", "PSK", "PSK", NA, "PSK", "PSK", …
    $ Power            <int> -30, -30, -68, -37, -57, -63, -27, -38, -38, -66, -42…
    $ beacons          <int> 846, 750, 694, 510, 647, 251, 1647, 1251, 704, 617, 1…
    $ IV               <int> 504, 116, 26, 21, 6, 3430, 80, 11, 0, 0, 86, 0, 0, 0,…
    $ LAN_IP           <chr> "0.  0.  0.  0", "0.  0.  0.  0", "0.  0.  0.  0", "0…
    $ ID_length        <int> 12, 4, 2, 14, 25, 13, 12, 13, 24, 12, 10, 0, 24, 24, …
    $ ESSID            <chr> "C322U13 3965", "Cnet", "KC", "POCO X5 Pro 5G", NA, "…
    $ Key              <chr> NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, N…
    $ session_duration <dbl> 157.78333, 162.15000, 160.46667, 110.96667, 77.26667,…

``` r
cat("\n=== СТРУКТУРА ДАННЫХ КЛИЕНТОВ ===\n")
```


    === СТРУКТУРА ДАННЫХ КЛИЕНТОВ ===

``` r
glimpse(client_data_clean)
```

    Rows: 186
    Columns: 8
    $ Station_MAC      <chr> "CA:66:3B:8F:56:DD", "5C:3A:45:9E:1A:7B", "C0:E4:34:D…
    $ First_time_seen  <dttm> 2023-07-28 09:13:03, 2023-07-28 09:13:03, 2023-07-28…
    $ Last_time_seen   <dttm> 2023-07-28 10:59:44, 2023-07-28 11:51:54, 2023-07-28…
    $ Power            <int> -33, -39, -61, -31, -71, -74, -65, -65, -1, -37, -48,…
    $ packets          <int> 858, 432, 958, 163, 3, 115, 437, 77, 71, 125, 122, 15…
    $ BSSID            <chr> "BE:F1:71:D5:17:8B", "BE:F1:71:D6:10:D7", "BE:F1:71:D…
    $ Probed_ESSIDs    <chr> "C322U13 3965", "C322U21 0566", "C322U13 3965", "C322…
    $ session_duration <dbl> 106.683333, 158.850000, 160.216667, 157.733333, 6.916…

# 4 Определить небезопасные точки доступа (без шифрования – OPN)

``` r
insecure_ap <- ap_data_clean %>% filter(Privacy == "OPN")
cat("\n=== НЕБЕЗОПАСНЫЕ ТОЧКИ ДОСТУПА (OPN) ===\n")
```


    === НЕБЕЗОПАСНЫЕ ТОЧКИ ДОСТУПА (OPN) ===

``` r
print(insecure_ap %>% select(BSSID, ESSID, Privacy))
```

    # A tibble: 42 × 3
       BSSID             ESSID         Privacy
       <chr>             <chr>         <chr>  
     1 E8:28:C1:DC:B2:52 MIREA_HOTSPOT OPN    
     2 E8:28:C1:DC:B2:50 MIREA_GUESTS  OPN    
     3 E8:28:C1:DC:B2:51 <NA>          OPN    
     4 E8:28:C1:DC:FF:F2 <NA>          OPN    
     5 00:25:00:FF:94:73 <NA>          OPN    
     6 E8:28:C1:DD:04:52 MIREA_HOTSPOT OPN    
     7 E8:28:C1:DE:74:31 <NA>          OPN    
     8 E8:28:C1:DE:74:32 MIREA_HOTSPOT OPN    
     9 E8:28:C1:DC:C8:32 MIREA_HOTSPOT OPN    
    10 E8:28:C1:DD:04:50 MIREA_GUESTS  OPN    
    # ℹ 32 more rows

``` r
cat("Количество небезопасных точек доступа:", nrow(insecure_ap), "\n")
```

    Количество небезопасных точек доступа: 42 

# 5 Определить производителя для каждого обнаруженного устройства

``` r
get_manufacturer <- function(mac) {
  oui <- substr(mac, 1, 8)
  manufacturers <- list(
    "00:14:22" = "D-Link", "00:1B:FC" = "Nokia", "00:23:69" = "Apple",
    "00:26:BB" = "Cisco", "08:00:27" = "VirtualBox", "00:50:F2" = "Microsoft",
    "00:1A:11" = "Google", "00:1D:0F" = "Samsung", "00:24:2C" = "HTC",
    "00:1E:65" = "LG", "00:21:6A" = "Intel", "00:25:00" = "Dell"
  )
  return(ifelse(!is.null(manufacturers[[oui]]), manufacturers[[oui]], "Unknown"))
}

ap_data_clean <- ap_data_clean %>%
  mutate(Manufacturer = map_chr(BSSID, get_manufacturer))

cat("\n=== ПРОИЗВОДИТЕЛИ ТОЧЕК ДОСТУПА ===\n")
```


    === ПРОИЗВОДИТЕЛИ ТОЧЕК ДОСТУПА ===

``` r
print(table(ap_data_clean$Manufacturer))
```


       Dell Unknown 
          1   12247 

# 6 Выявить устройства, использующие последнюю версию протокола шифрования WPA3, и названия точек доступа, реализованных на этих устройствах

``` r
wpa3_devices <- ap_data_clean %>% 
  filter(str_detect(Privacy, "WPA3") | str_detect(Authentication, "WPA3"))
cat("\n=== УСТРОЙСТВА С WPA3 ===\n")
```


    === УСТРОЙСТВА С WPA3 ===

``` r
if(nrow(wpa3_devices) > 0) {
  print(wpa3_devices %>% select(BSSID, ESSID, Privacy, Authentication))
} else {
  cat("Устройства с WPA3 не обнаружены\n")
}
```

    # A tibble: 8 × 4
      BSSID             ESSID                                 Privacy Authentication
      <chr>             <chr>                                 <chr>   <chr>         
    1 26:20:53:0C:98:E8  <NA>                                 WPA3 W… SAE PSK       
    2 A2:FE:FF:B8:9B:C9 "Christie’s"                          WPA3 W… SAE PSK       
    3 96:FF:FC:91:EF:64  <NA>                                 WPA3 W… SAE PSK       
    4 CE:48:E7:86:4E:33 "iPhone (Анастасия)"                  WPA3 W… SAE PSK       
    5 8E:1F:94:96:DA:FD "iPhone (Анастасия)"                  WPA3 W… SAE PSK       
    6 BE:FD:EF:18:92:44 "Димасик"                             WPA3 W… SAE PSK       
    7 3A:DA:00:F9:0C:02 "iPhone XS Max \U0001f98a\U0001f431\… WPA3 W… SAE PSK       
    8 76:C5:A0:70:08:96  <NA>                                 WPA3 W… SAE PSK       

# 7 Отсортировать точки доступа по интервалу времени, в течение которого они находились на связи, по убыванию.

``` r
ap_sessions <- ap_data_clean %>%
  arrange(BSSID, First_time_seen) %>%
  group_by(BSSID) %>%
  mutate(
    time_gap = as.numeric(difftime(First_time_seen, lag(Last_time_seen), units = "mins")),
    new_session = time_gap > 45 | is.na(time_gap)
  ) %>%
  mutate(session_id = cumsum(new_session)) %>%
  group_by(BSSID, session_id) %>%
  summarise(
    ESSID = first(ESSID),
    First_time_seen = min(First_time_seen),
    Last_time_seen = max(Last_time_seen),
    Total_duration = as.numeric(difftime(max(Last_time_seen), min(First_time_seen), units = "mins")),
    .groups = "drop"
  ) %>%
  arrange(desc(Total_duration))
  glimpse(ap_sessions)
```

    Rows: 12,240
    Columns: 6
    $ BSSID           <chr> "00:25:00:FF:94:73", "10:51:07:CB:33:BF", "00:95:69:E7…
    $ session_id      <int> 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, …
    $ ESSID           <chr> NA, NA, NA, NA, NA, NA, NA, "MIREA_HOTSPOT", NA, "MIRE…
    $ First_time_seen <dttm> 2023-07-28 09:13:06, 2023-07-28 09:13:13, 2023-07-28 …
    $ Last_time_seen  <dttm> 2023-07-28 11:56:21, 2023-07-28 11:56:17, 2023-07-28 …
    $ Total_duration  <dbl> 163.2500, 163.0667, 163.0333, 163.0333, 163.0167, 162.…

# 8 Обнаружить топ-10 самых быстрых точек доступа.

``` r
top10_fastest <- ap_data_clean %>%
  filter(!is.na(Speed)) %>%
  arrange(desc(Speed)) %>%
  head(10)

cat("\n=== ТОП-10 САМЫХ БЫСТРЫХ ТОЧЕК ДОСТУПА ===\n")
```


    === ТОП-10 САМЫХ БЫСТРЫХ ТОЧЕК ДОСТУПА ===

``` r
print(top10_fastest %>% select(BSSID, ESSID, Speed))
```

    # A tibble: 10 × 3
       BSSID             ESSID Speed
       <chr>             <chr> <int>
     1 00:95:69:E7:7D:21 <NA>   8171
     2 00:95:69:E7:7C:ED <NA>   4096
     3 00:95:69:E7:7F:35 <NA>   2245
     4 98:F6:21:72:9E:D6 <NA>   2143
     5 F6:4D:98:98:18:C3 <NA>   1062
     6 52:FE:C5:8B:DF:D3 <NA>   1037
     7 C0:E4:34:D8:E7:E5 <NA>    958
     8 74:DF:BF:7B:00:19 <NA>    911
     9 26:20:53:0C:98:E8 <NA>    866
    10 96:FF:FC:91:EF:64 <NA>    866

# 9 Отсортировать точки доступа по частоте отправки запросов (beacons) в единицу

времени по их убыванию

``` r
ap_beacon_rate <- ap_data_clean %>%
  mutate(
    beacon_rate = ifelse(session_duration > 0, beacons / session_duration, NA)
  ) %>%
  filter(!is.na(beacon_rate)) %>%
  arrange(desc(beacon_rate)) %>%
  select(BSSID, ESSID, beacons, session_duration, beacon_rate)

glimpse(ap_beacon_rate)
```

    Rows: 124
    Columns: 5
    $ BSSID            <chr> "F2:30:AB:E9:03:ED", "B2:CF:C0:00:4A:60", "3A:DA:00:F…
    $ ESSID            <chr> "iPhone (Uliana)", "Михаил's Galaxy M32", "iPhone XS …
    $ beacons          <int> 6, 4, 5, 1, 1, 1, 5, 1647, 1, 704, 1251, 1390, 647, 6…
    $ session_duration <dbl> 0.11666667, 0.08333333, 0.15000000, 0.03333333, 0.033…
    $ beacon_rate      <dbl> 51.428571, 48.000000, 33.333333, 30.000000, 30.000000…

# 10 Определить производителя для каждого обнаруженного устройства

``` r
client_data_clean <- client_data_clean %>%
  mutate(Manufacturer = map_chr(Station_MAC, get_manufacturer))

cat("\n=== ПРОИЗВОДИТЕЛИ КЛИЕНТСКИХ УСТРОЙСТВ ===\n")
```


    === ПРОИЗВОДИТЕЛИ КЛИЕНТСКИХ УСТРОЙСТВ ===

``` r
print(table(client_data_clean$Manufacturer))
```


    Unknown 
        186 

# 11 Обнаружить устройства, которые НЕ рандомизируют свой MAC адрес

``` r
is_randomized_mac <- function(mac) {
  if(is.na(mac) || mac == "") return(NA)
  first_byte <- as.hexmode(substr(mac, 1, 2))
  return(bitwAnd(first_byte, 0x02) == 0x02)
}

client_data_clean <- client_data_clean %>%
  mutate(
    is_randomized = sapply(Station_MAC, is_randomized_mac)
  )

non_random_clients <- client_data_clean %>%
  filter(!is_randomized) %>%
  select(Station_MAC, Manufacturer, Power, packets)

glimpse(non_random_clients)
```

    Rows: 59
    Columns: 4
    $ Station_MAC  <chr> "5C:3A:45:9E:1A:7B", "C0:E4:34:D8:E7:E5", "68:54:5A:40:35…
    $ Manufacturer <chr> "Unknown", "Unknown", "Unknown", "Unknown", "Unknown", "U…
    $ Power        <int> -39, -61, -31, -71, -1, -37, -48, -37, -65, -29, -43, -59…
    $ packets      <int> 432, 958, 163, 3, 71, 125, 122, 156, 117, 240, 76, 580, 4…

# 12 Кластеризовать запросы от устройств к точкам доступа по их именам. Определить время появления устройства в зоне радиовидимости и время выхода его из нее.

``` r
 client_clusters <- client_data_clean %>%
  group_by(Station_MAC, Probed_ESSIDs) %>%
  summarise(
    first_appearance = min(First_time_seen),
    last_appearance = max(Last_time_seen),
    cluster_duration = as.numeric(difftime(last_appearance, first_appearance, units = "mins")),
    avg_power = mean(Power, na.rm = TRUE),
    total_packets = sum(packets, na.rm = TRUE),
    .groups = "drop"
  ) %>%
  filter(!is.na(Probed_ESSIDs) & Probed_ESSIDs != "")

cat("\n=== КЛАСТЕРЫ ЗАПРОСОВ К ТОЧКАМ ДОСТУПА ===\n")
```


    === КЛАСТЕРЫ ЗАПРОСОВ К ТОЧКАМ ДОСТУПА ===

``` r
cat("Количество кластеров:", nrow(client_clusters), "\n")
```

    Количество кластеров: 85 

``` r
print(head(client_clusters, 10))
```

    # A tibble: 10 × 7
       Station_MAC       Probed_ESSIDs       first_appearance    last_appearance    
       <chr>             <chr>               <dttm>              <dttm>             
     1 00:F4:8D:F7:C5:19 Redmi 12,Hornet24   2023-07-28 10:45:04 2023-07-28 11:43:26
     2 02:69:A5:29:F1:3E Galaxy A71          2023-07-28 10:52:35 2023-07-28 11:24:51
     3 04:8C:9A:0B:40:EA MIREA_HOTSPOT       2023-07-28 10:27:47 2023-07-28 11:55:51
     4 06:15:2E:12:C8:A6 MIREA_HOTSPOT,MT_F… 2023-07-28 10:27:47 2023-07-28 10:30:41
     5 06:F2:A9:C1:8D:09 MIREA_HOTSPOT       2023-07-28 09:31:40 2023-07-28 11:50:58
     6 0A:AB:49:39:BB:29 MIREA_HOTSPOT       2023-07-28 10:32:39 2023-07-28 11:39:44
     7 0A:C2:C3:08:9E:F8 MIREA_HOTSPOT       2023-07-28 10:14:39 2023-07-28 10:14:47
     8 0C:E4:41:E8:C3:6E MIREA_GUESTS        2023-07-28 09:32:07 2023-07-28 10:21:40
     9 0E:AD:54:09:04:37 GIVC                2023-07-28 09:13:51 2023-07-28 09:43:22
    10 12:49:27:AA:B0:A5 GIVC                2023-07-28 11:02:12 2023-07-28 11:49:02
    # ℹ 3 more variables: cluster_duration <dbl>, avg_power <dbl>,
    #   total_packets <int>

# 13 Оценить стабильность уровня сигнала внури кластера во времени. Выявить наиболее стабильный кластер

``` r
cluster_stability <- client_data_clean %>%
  filter(!is.na(Probed_ESSIDs), Probed_ESSIDs != "Not Probed") %>%
  group_by(Probed_ESSIDs) %>%
  summarise(
    device_count = n_distinct(Station_MAC),
    mean_power = mean(Power, na.rm = TRUE),
    sd_power = sd(Power, na.rm = TRUE),
    cv_power = ifelse(mean_power != 0, sd_power / abs(mean_power), NA),
    .groups = "drop"
  ) %>%
  filter(!is.na(sd_power)) %>%
  arrange(sd_power) 

glimpse(cluster_stability)
```

    Rows: 11
    Columns: 5
    $ Probed_ESSIDs <chr> "Galaxy A71", "MT_FREE", "Vladimir", "IKB", "GIVC", "Red…
    $ device_count  <int> 2, 2, 4, 2, 13, 2, 20, 8, 2, 2, 2
    $ mean_power    <dbl> -48.50000, -68.00000, -51.50000, -56.00000, -62.69231, -…
    $ sd_power      <dbl> 0.7071068, 1.4142136, 4.1231056, 4.2426407, 5.2183110, 8…
    $ cv_power      <dbl> 0.01457952, 0.02079726, 0.08006030, 0.07576144, 0.083236…

## Оценка результата

В рамках практческой работы была исследована радиоэлектронная обстановка
и составлено представление о механизмах работы Wi-Fi сетей на канальном
и сетевом уровне модели OSI.

## Вывод

В практической работе мы использовали навыки написания кода на языке
программирования R для обработки данных и закрепили знания основных
функций обработки данных экосистемы tidyverse языка R.
