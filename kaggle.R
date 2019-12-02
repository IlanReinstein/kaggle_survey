library(tidyverse)

multiple_choice <- read_csv("data/raw/multiple_choice_responses.csv", skip = 1)
text_responses <- read_csv("data/raw/other_text_responses.csv", skip = 1)
questions <- read_csv("data/raw/questions_only.csv")
survey <- read_csv("data/raw/survey_schema.csv")

latam <- multiple_choice %>%
  filter(`In which country do you currently reside?` %in% c("Colombia", "Peru", "Brazil", "Chile", "Mexico", 
                                                            "Argentina"))

N <- nrow(latam)
names(latam)
plot(table(latam$`What is your age (# years)?`))

latam %>%
  select(contains("programming languages")) -> prog_lang

names(prog_lang) <- gsub(".* - ", "", names(prog_lang))

prog_lang %>%
  select(Python, R) %>% 
  mutate_all(function(x) if_else(!is.na(x), 1, 0))

latam %>%
  select(country = `In which country do you currently reside?`,
         ml_years = `For how many years have you used machine learning methods?`,
         age =`What is your age (# years)?`,
         gender =`What is your gender? - Selected Choice`,
         salary = `What is your current yearly compensation (approximate $USD)?`,
         company_size = `What is the size of the company where you are employed?`) %>%
  bind_cols(prog_lang) %>% filter(!is.na(salary)) -> latam_clean




salary100_500 <- c("100,000-124,999", "125,000-149,999", "150,000-199,999", "200,000-249,999",
                   "250,000-299,999", "300,000-500,000")

salary50_100 <- c("50,000-59,999", "60,000-69,999", "70,000-79,999", 
                  "80,000-89,999", "90,000-99,999")

latam_clean$salary_new <- if_else(latam_clean$salary %in% salary100_500, "100,000-500,000",
                                  if_else(latam_clean$salary %in% salary50_100, "50,000-99,999", 
                                          latam_clean$salary))

latam_clean$salary_new <- as.integer(factor(latam_clean$salary_new, ordered = T,
                                            levels = c("$0-999", "1,000-1,999","2,000-2,999", "3,000-3,999",
                                                       "4,000-4,999", "5,000-7,499","7,500-9,999", "10,000-14,999",
                                                       "15,000-19,999", "20,000-24,999", "25,000-29,999","30,000-39,999",  
                                                       "40,000-49,999", "50,000-99,999", "100,000-500,000","> $500,000")))

latam_clean$company_size <- gsub(" employees", "", latam_clean$company_size)

latam_clean %>% 
  select(salary_new, country)

library(brms)

brm(salary ~ 1, family = cumulative("logit"), data = latam_clean)
file.edit("~/.R/Makevars")


