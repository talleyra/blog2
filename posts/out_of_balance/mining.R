library(tidyverse)
library(ospowertrader)



time_intervals <- timetk::tk_make_timeseries("2023-06-01", "2023-12-01", by = "month")
intervals <- tibble(date_from = time_intervals) %>%
  mutate(date_to = lead(date_from)) %>%
  drop_na() %>% 
  mutate(daily = TRUE, quartorario = TRUE, macrozone = "NORD")


# download terna data from API ----

terna_prices <- pmap_df(intervals, terna_imbalance_prices)

terna_prices %>% 
  filter(macrozone == "NORD") %>% 
  arrow::write_parquet("./data/terna_imbalance_prices.parquet")

terna_volumes <- pmap_df(intervals, terna_imbalance_volumes)

terna_volumes %>% 
  filter(macrozone == "NORD") %>% 
  arrow::write_parquet("./data/terna_imbalance_volumes.parquet")

# define days -----

days <- timetk::tk_make_timeseries("2023-06-01", "2023-12-01", by = "day")

# download data from apg API ----


safe_agp_imbalance_prices <- possibly(apg_imbalance_prices, otherwise = NULL)

apg_imbalance_prices_df <- map_df(days, ~ safe_agp_imbalance_prices(date = .x))

apg_imbalance_prices_df %>% 
  arrow::write_parquet("./data/apg_imbalance_prices.parquet")

safe_agp_control_area_imbalance <- possibly(apg_control_area_imbalance, otherwise = NULL)

apg_control_area_imbalance_df <- map_df(days, ~safe_agp_control_area_imbalance(date = .x))

apg_control_area_imbalance_df %>% 
  arrow::write_parquet("./data/apg_control_area_imbalance.parquet")


### enbw section -----

fs::dir_ls("./posts/post-with-code/data/picasso/prices")

walk(days, ~ enbw_picasso_data(date = .x, type = "prices") %>% arrow::write_parquet(glue::glue("./posts/post-with-code/data/picasso/prices/", "prices", .x, ".parquet")))

walk(days, ~ enbw_picasso_data(date = .x, type = "volumes") %>% arrow::write_parquet(glue::glue("./posts/post-with-code/data/picasso/volumes/", "volumes", .x, ".parquet")))
