# Load libs
library(here)
library(dplyr)
library(tidyr)
library(lubridate)


# Import event log form csv
event_log_df <-
  read.csv(here::here("Data", "event_log.csv"),
           stringsAsFactors = FALSE,
           sep = ";")

# Select life prod, add activity_instance_id, add lifecycle_id
event_log_df_life <- event_log_df %>%
  filter(PRODLINE == "life") %>%
  select(-PRODLINE) %>%
  mutate(ACTIVITY_INST_ID = as.numeric(row.names(.))) %>%
  gather(LIFECYCLE_ID,
         TIMESTAMP,
         -PROPOSALID,-USERID,
         -ACTIVITY_INST_ID,
         -EVENT) %>%
  mutate(TIMESTAMP = ymd_hms(TIMESTAMP)) %>%
  arrange(PROPOSALID, TIMESTAMP) %>%
  mutate(LIFECYCLE_ID = case_when(.$LIFECYCLE_ID == 'STARTTIMESTAMP' ~ 'START',
                                  TRUE ~ 'END'))

# Transform df into bupaR eventlog
library(bupaR)
library(processmapR)


event_log_life <- event_log_df_life %>%
  eventlog(
    case_id = "PROPOSALID",
    activity_id = "EVENT",
    activity_instance_id = "ACTIVITY_INST_ID",
    lifecycle_id = "LIFECYCLE_ID",
    timestamp = "TIMESTAMP",
    resource_id = "USERID"
  )


event_log_life_filt <- event_log_life %>%
  filter_activity_frequency(percentage = 0.9, reverse = F) 
  

event_log_life_filt %>% 
  process_map()

