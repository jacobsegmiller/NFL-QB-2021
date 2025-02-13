#Installing the packages necessary for creating plots
library(nflfastR)
library(tidyverse)
library(ggplot2)
library(magrittr)
library(dplyr)
library(ggrepel)
library(ggimage)

#Creating a data frame of all of the play by play data from the 2021 NFL season
pbp <- load_pbp(2021)

#Creating a data frame for 2021 NFL regular season data for only QBs with over 200 pass attempts
#The statistics including are epa, cpoe, wpa, passing yards, passing tds, interceptions, td%, int%, completion % and pass attempts
df <- pbp %>%
  filter(season_type == "REG", !is.na(epa)) %>%
  group_by(id, name) %>%
  summarize(
    team = last(posteam),
    epa = mean(epa, na.rm = T),
    cpoe = mean(cpoe, na.rm = T),
    wpa = sum(wpa, na.rm = T),
    passyds = sum(passing_yards, na.rm = T),
    passtds = sum(pass_touchdown, na.rm = T),
    int = sum(interception, na.rm =T),
    tdprct = ((sum(pass_touchdown, na.rm = T)) / sum((complete_pass + incomplete_pass + interception), na.rm = T)),
    intprct = ((sum(interception, na.rm = T)) / sum((complete_pass + incomplete_pass + interception), na.rm = T)),
    comp = ((sum(complete_pass, na.rm = T)) / sum((complete_pass + incomplete_pass + interception), na.rm = T)),
    attempts = sum((complete_pass + incomplete_pass + interception), na.rm = T)
  ) %>%
  ungroup() %>%
  filter(attempts > 200)
  
#Viewing my dataframe to make sure it looks the way it is supposed to
view(df)

#Checking the column names to make sure I have everything necessary
#colnames(pbp)

#Joining in the players team data so I can use team logos and color schemes
df1 <- df %>%
  left_join(teams_colors_logos, by = c("team" = "team_abbr"))

#Writing the data frame to a csv to test in the JHub, ended up not needing this but included it anyways
write.csv(df1,"C:/Users/seggy/Documents/NC State Spring 2022/DSC495-011 RPython/nflqbstats1.csv", row.names = FALSE)

#Running a linear regression to predict cpoe using epa, I can use the intercept and slope given to plot a line of best fit
lm1 <- lm(df1$cpoe ~ df1$epa)
summary(lm1)

#Plotting epa and cpoe with lines for regression as well as the variable means. I also added team logos for player points
#Needed ggrepel for this as player names would overlap and it led to the graph being a mess
ggplot(df1, aes(epa, cpoe)) +
  labs(title = "NFL QBs by EPA and CPOE", caption = "Created by Jacob Segmiller ~ Data from nflfastR",
       x = "EPA (Expected Points Added per Play) for 2021 Season", y = "CPOE (Completion Percentage Above Expected) for 2021 Season") +
  geom_vline(xintercept = mean(df1$epa), color = "red") +
  geom_hline(yintercept = mean(df1$cpoe), color = "red") +
  geom_abline(intercept = -.7978, slope = 23.1725) +
  geom_image(aes(image = team_logo_espn), size = 0.025, asp = 15/8) +
  geom_text_repel(aes(label = name), max.overlaps = Inf)+
  xlim(-0.2, 0.3) +
  ylim(-10, 7.5)+
  theme_light()
#This graph is interesting the visuals are exactly what I was looking for, but some of the results are surprising. Justin Herbert and Matt Stafford
#were both eliminated as I was only taking QBs above the mean in each category, however they both were below average in CPOE. Tua Tagovailoa was the
#biggest surprise as I did not expect to see him rank this highly however he did, and same goes for Teddy Bridgewater. For the most part I have the
#subset of QBs that I expected to have.

#Creating variables to assign the mean of epa and cpoe for when I subset the data frame
meanepa <- mean(df1$epa)
meancpoe <- mean(df1$cpoe)

#Running a linear regression to predict wpa using epa, I can use the intercept and slope given to plot a line of best fit
#I was surprised to see Herbert and Stafford eliminated, and even though I plan to continue my preset process to avoid adding bias, I was curious
#to see if the results were different with another variable.
lm2 <- lm(df1$wpa ~ df1$epa)
summary(lm2)

#Plotting epa and wpa with lines for regression as well as the variable means
ggplot(df1, aes(epa, wpa)) +
  labs(title = "NFL QBs by EPA and WPA", caption = "Created by Jacob Segmiller ~ Data from nflfastR",
       x = "EPA (Expected Points Added per Play) for 2021 Season", y = "WPA (Win Probability Added) for 2021 Season") +
  geom_vline(xintercept = mean(df1$epa), color = "red") +
  geom_hline(yintercept = mean(df1$wpa), color = "red") +
  geom_abline(intercept = 1.0434, slope = 14.6255) +
  geom_image(aes(image = team_logo_espn), size = 0.025, asp = 15/8) +
  geom_text_repel(aes(label = name), max.overlaps = Inf)+
  xlim(-0.2, 0.3) +
  ylim(-2, 5.5)+
  theme_light()
#This graph was able to get Herbert and Stafford into the quadrant I personally feel they belong in. While I will not use it, I find it interesting to
#see how changing one variable can change the results. This graph also got Teddy Bridgewater out of the top right quadrant which excites me as I do not
#think he is very good. The flaw with this one is that Josh Allen and Lamar Jackson get left out. While I personally think Lamar would not excel in
#this type of analysis as I wanted to focus on passing heavy statistics, he likely should still be in the top right.

#Creating a new data frame with the subset of QBs that were above average in both epa and cpoe
df2 <- df1 %>%
  filter(epa > meanepa & cpoe > meancpoe)

#Running a linear regression to predict passing tds using passing yds, I can use the intercept and slope given to plot a line of best fit
lm3 <- lm(df2$passtds ~ df2$passyds)
summary(lm3)

#Plotting passing yards and passing tds with lines for regression as well as the variable means
ggplot(df2, aes(passyds, passtds)) +
  labs(title = "NFL QBs by Passing Yards and Passing Touchdowns", caption = "Created by Jacob Segmiller ~ Data from nflfastR",
       x = "Passing Yards for 2021 Season", y = "Passing Touchdowns for the 2021 Season") +
  geom_vline(xintercept = mean(df2$passyds), color = "red") +
  geom_hline(yintercept = mean(df2$passtds), color = "red") +
  geom_abline(intercept = -12.880199, slope = 0.010089) +
  geom_image(aes(image = team_logo_espn), size = 0.025, asp = 15/8) +
  geom_text_repel(aes(label = name), max.overlaps = Inf)+
  xlim(2500, 5500) +
  ylim(15,45)+
  theme_light()
#This graph was able to cut the number of QBs in half which is what I was hoping for. I mentioned in part one that I did not want any QB who did not
#play a ton of games to win, and counting stats could act as a filter for that. This successfully accomplished that mission as both Tua Tagovailoa and
#Lamar Jackson were eliminated and both missed substantial time this past season. This also removed some quarterbacks I was hoping to see go, such as
#game managers like Ryan Tannehill, Jimmy Garoppolo, and Teddy Bridgewater. One minor surprise could be that Kirk Cousins survived both cuts, however
#I think he likely gets more hate than he deserves.

#Creating variables to assign the mean of passing yards and tds for when I subset the data frame
meanyds <- mean(df2$passyds)
meantds <- mean(df2$passtds)

#Creating a new data frame with the subset of QBs that were above average in both passing yards and passing tds
df3 <- df2 %>%
  filter(passyds > meanyds & passtds > meantds)

#Assigning percentile values for the seven remaining quarterbacks. When creating this I realized my initial formula was not good for analysis, so I
#pivoted to assigning percentiles for each stat. This allows for my calculated statistic of weighted_qb_play to be a value from 0 to 1. I recognize that
#this value would be different if I created the percentiles in the initial data frame but my goal was to eliminate QBs who did not excel analytically
#nor with regular counting stats. I felt it was best to evaluate the best of the best against each other.
df3$epapct <- ecdf(df3$epa)(df3$epa)
df3$cpoepct <- ecdf(df3$cpoe)(df3$cpoe)
df3$wpapct <- ecdf(df3$wpa)(df3$wpa)
df3$ydspct <- ecdf(df3$passyds)(df3$passyds)
df3$tdspct <- ecdf(df3$passtds)(df3$passtds)
df3$intpct <- ecdf(df3$int)(df3$int)
df3$tdprctpct <- ecdf(df3$tdprct)(df3$tdprct)
df3$intprctpct <- ecdf(df3$intprct)(df3$intprct)
df3$comppct <- ecdf(df3$comp)(df3$comp)

#Applying my formula. I gave higher weight to advanced stats as my goal was to have them decide the outcome rather than stats that everyone knows
df3$weighted_qb_play <- ((0.25*df3$epapct) + (.25*df3$cpoepct) + (0.2*df3$wpapct) + (.1*df3$tdspct) + (.1*df3$ydspct) + (.1*df3$comppct))

#Creating a bar plot to show how each QB stacked up
ggplot(df3, aes(x = reorder(name, weighted_qb_play), y = weighted_qb_play)) +
  geom_bar(stat = "identity", color = df3$team_color2, fill = df3$team_color) +
  labs(title = "NFL QBs by Weighted QB Play", caption = "Created by Jacob Segmiller ~ Data from nflfastR",
       x = "QB Name", y = "Weighted QB Play") +
  coord_flip() +
  theme_light()
#I really like the way that this graph looks as the ordering and team colors make for an appealing graph to stare at. Seeing Aaron Rodgers at the top
#was not a surprise since he is the back to back NFL MVP, however I thought Tom Brady might have beat him, but he finished middle of the pack. I think
#the formula did a great job of filtering out a QB who likely did not belong in the best of the best in Kirk Cousins, but it looked highly upon Joe
#Burrow who ranked second. Looking back I could have found a way to incorporate interceptions into the equation which would have lowered his stock, but
#I thought statistics such as epa and wpa would have taken that into account more.

#I was curious to see how much my subsetting changed the result of the graph so I went back and performed the percentiles on the first data frame
df1$epapct <- ecdf(df1$epa)(df1$epa)
df1$cpoepct <- ecdf(df1$cpoe)(df1$cpoe)
df1$wpapct <- ecdf(df1$wpa)(df1$wpa)
df1$ydspct <- ecdf(df1$passyds)(df1$passyds)
df1$tdspct <- ecdf(df1$passtds)(df1$passtds)
df1$intpct <- ecdf(df1$int)(df1$int)
df1$tdprctpct <- ecdf(df1$tdprct)(df1$tdprct)
df1$intprctpct <- ecdf(df1$intprct)(df1$intprct)
df1$comppct <- ecdf(df1$comp)(df1$comp)
df1$weighted_qb_play <- ((0.25*df1$epapct) + (.25*df1$cpoepct) + (0.2*df1$wpapct) + (.1*df1$tdspct) + (.1*df1$ydspct) + (.1*df1$comppct))

#Creating a bar plot to show how each QB stacked up
ggplot(df1, aes(x = reorder(name, weighted_qb_play), y = weighted_qb_play)) +
  geom_bar(stat = "identity", color = df1$team_color2, fill = df1$team_color) +
  labs(title = "NFL QBs by Weighted QB Play", caption = "Created by Jacob Segmiller ~ Data from nflfastR",
       x = "QB Name", y = "Weighted QB Play") +
  coord_flip() +
  theme_light()
#By subsetting the QBs, I did not affect the top four whatsoever as they were again Rodgers, Burrow, Mahomes and Brady in that order. One thing that
#stood out to me was that QBs such as the aforementioned Herbert and Stafford ranked highly despite being eliminated early. Jimmy Garoppolo ranked fifth
#which is quite surprising, but does speak to his ability to avoid losing the game for the Niners while they rely on an elite run game and defense.