library(dplyr)
library(gapminder)

# Statistics of Europe countries for 2007
eu_stats <- gapminder %>%
  filter(
    continent == "Europe",
    year == 2007
  ) %>%
  group_by(country) %>%
  summarise(
    AvgLifeExp = mean(lifeExp),
    AvgGdpPercap = mean(gdpPercap)
  )

# Save the file as CSV
write.csv(eu_stats, "home/r-environment/eu_stats.csv", row.names = FALSE)
