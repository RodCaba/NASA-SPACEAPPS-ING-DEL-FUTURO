library(tidyverse)
library(readxl)
library(lubridate)
library(caret)
library(stats)


dataset_raw = read.csv("ldex_20161118/data_calibrated/mass/DATASET.tab",
                       sep = " ")

dataset_raw = dataset_raw[,c(1,2,9)]
dataset_raw = set_names(dataset_raw, nm = c('time-stamp', 'value', 'saturated'))

dataset_raw = dataset_raw %>% 
  separate(`time-stamp`, into = c("year", "hour"), 
           sep = "-")
dataset_raw = dataset_raw %>% 
  separate(hour, into = c("day", "time"),
           sep = "T")

dataset_raw
dataset_raw = dataset_raw %>% 
  filter(saturated == 0)

dataset13 = dataset_raw %>% 
  filter(year == "2013") %>% 
  mutate(day = as.integer(day)) %>% 
  mutate(day = as.Date(day, "2012-12-31"))

dataset14 = dataset_raw %>% 
  filter(year == "2014") %>% 
  mutate(day = as.integer(day)) %>% 
  mutate(day = as.Date(day, "2013-12-31"))

dataset_tidy = bind_rows(dataset13, dataset14)

sum_dat = dataset_tidy %>% 
  group_by(day) %>% 
  summarize(mean(value))


sum_dat %>% 
  ggplot(aes(day, `mean(value)`)) +
  geom_point()


plot(sum_dat)

sum_dat %>% 
  ggplot(aes(day, `mean(value)`)) +
  geom_line()

min(sum_dat$day)

write_csv(sum_dat, "dataset.csv")

l_model = lm(sum_dat$`mean(value)` ~ sum_dat$day)
summary(l_model)
p <- 0.8
set.seed(1)

test_index = sample.int(n = nrow(sum_dat),
                        size = floor(p*nrow(sum_dat)),
                        replace = FALSE)
train = sum_dat[test_index,]
test = sum_dat[-test_index,]

model = lm(`mean(value)` ~ day, data = train)
valuepred = predict(model, test)

actual_preds <- data.frame(cbind(actuals = test$`mean(value)`,
                                 predicted = valuepred))
actual_preds['error'] = actual_preds$actuals - actual_preds$predicted
actual_preds %>% 
  summarize(RMSE = (sum(error)^2)/n())
