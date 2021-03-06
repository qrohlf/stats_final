library(ggplot2)
library(scales)
library(grid)
library(RColorBrewer)

custom_theme <- function() {
  
  # Generate the colors for the chart procedurally with RColorBrewer
  palette <- brewer.pal("Greys", n=9)
  color.background = palette[2]
  color.grid.major = palette[3]
  color.axis.text = palette[6]
  color.axis.title = palette[7]
  color.title = palette[7]
  
  # Begin construction of chart
  theme_bw(base_size=9) +
    
    # Set the entire chart region to a light gray color
    theme(panel.background=element_rect(fill=color.background, color=color.background)) +
    theme(plot.background=element_rect(fill=color.background, color=color.background)) +
    theme(panel.border=element_rect(color=color.background)) +
    
    # Format the grid
    theme(panel.grid.major=element_line(color=color.grid.major,size=.25)) +
    theme(panel.grid.minor=element_blank()) +
    theme(axis.ticks=element_blank()) +
    
    # Format the legend, but hide by default
    theme(legend.position="none") +
    theme(legend.background = element_rect(fill=color.background)) +
    theme(legend.text = element_text(size=7,color=color.axis.title)) +
    
    # Set title and axis labels, and format these and tick marks
    theme(plot.title=element_text(color=color.title, size=20, vjust=1.25)) +
    theme(axis.text.x=element_text(size=12,color=color.axis.text)) +
    theme(axis.text.y=element_text(size=12,color=color.axis.text)) +
    theme(axis.title.x=element_text(size=15,color=color.axis.title, vjust=0)) +
    theme(axis.title.y=element_text(size=15,color=color.axis.title, vjust=1.25)) +
    
    # Plot margins
    theme(plot.margin = unit(c(0.35, 0.2, 0.3, 0.35), "cm"))
}

data <- read.csv("~/Projects/stats_final/out.csv")

ggplot(data, aes(prs_closed)) +
  geom_histogram(binwidth=0.1) + 
  scale_x_log10() +
  labs(title="Distribution of GitHub PRs Per User", x="Pull Requests", y="Frequency") +
  custom_theme()

ggplot(data, aes(pr_ratio)) + 
  geom_histogram(binwidth=.05) + 
  labs(title="Distribution of GitHub PR Acceptance Rate", x="PR Acceptance Ratio", y="Frequency") +
  custom_theme()

ggplot(data, aes(stars)) + 
  geom_histogram(binwidth=.05) + 
  scale_x_log10(labels=comma, breaks=10^(0:6)) +
  labs(title="Distribution of GitHub User Star Counts", x="Star Count", y="Frequency") +
  custom_theme()

ggplot(data, aes(x=stars, y=pr_ratio, size=5)) + 
  geom_point(alpha=0.2, color="#c0392b") + 
  scale_x_log10(labels=comma, breaks=10^(0:6)) +
  labs(title="PR Acceptance Rate vs Combined Star Count", x="Number of Stars", y="PR Acceptance Ratio") +
  custom_theme()
