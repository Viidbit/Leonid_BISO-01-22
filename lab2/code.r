library(dplyr)

starwars %>% ncol()

starwars %>% glimpse()

starwars %>%
    select(species) %>%
    unique() %>%
    nrow()

starwars %>%
    filter(!is.na(height)) %>%
    arrange(desc(height)) %>%
    head(1)

starwars[starwars$height < 170, ]

starwars %>%
    mutate(BMI = mass / (height^2)) %>%
    select(name, height, mass, BMI)

starwars %>%
    filter(!is.na(mass), !is.na(height), height > 0) %>%
    mutate(stretchiness = mass / height) %>%
    slice_max(stretchiness, n = 10)

starwars %>%
    mutate(age = 100 + birth_year) %>%
    group_by(species) %>%
    summarise(Avg_age = median(age, na.rm = TRUE))

starwars %>%
    group_by(eye_color) %>%
    summarise(n = n()) %>%
    arrange(desc(n)) %>%
    head(1)

starwars %>%
    filter(!is.na(species), !is.na(name)) %>%
    mutate(name_length = nchar(name)) %>%
    group_by(species) %>%
    summarise(avg_name_length = mean(name_length))