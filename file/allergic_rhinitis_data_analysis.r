
data = read.table(file="./allergic_rhinitis_data.csv",
                  header=TRUE, sep=",", stringsAsFactor=TRUE)

grim_test <- function(n, m, decimals) {
    # Rounding to limit floating point comparison issues
    round(round(n * m)/n, decimals) == m
}

means_grim_fail <- c()
for (group in unique(data$group)) {
    n <- data[data$group == group & data$week == 0, ]$n[1]
    for (m in na.omit(data$mean[data$group == group])) {
        if (grim_test(n, m, 2) == FALSE) {
            means_grim_fail <- c(means_grim_fail, m)
        }
    }
}

cat("GRIM test failures:",
    round(length(means_grim_fail) / length(na.omit(data$mean)) * 100, 1), "%\n")
cat(means_grim_fail, "\n")
cat("\n")

# Check variance of sum by sampling from normal distributions
check_sd <- function(n, mean_1, sd_1, mean_2, sd_2, reported_sd, label, round=FALSE) {
    total <- c()
    for (i in 1:10000) {
        data_1 <- rnorm(n, mean_1, sd_1)
        data_2 <- rnorm(n, mean_2, sd_2)
        if (round) {
            data_1 <- round(data_1)
            data_2 <- round(data_2)
        }
        total <- c(total, sd(data_1 + data_2))
    }

    hist_data <- hist(total, main=label, xlab="Stddev")

    #define x and y values to use for normal curve
    x_values <- seq(min(total), max(total), length = 100)
    y_values <- dnorm(x_values, mean = mean(total), sd = sd(total))
    y_values <- y_values * diff(hist_data$mids[1:2]) * length(total)

    #overlay normal curve on histogram
    lines(x_values, y_values, lwd = 2)

    #add vertical line of reported value
    abline(v=reported_sd, col="red")

    # Two-tail test, switching tail for coherent p-values
    p <- pnorm(reported_sd, mean(total), sd(total),
               lower.tail=reported_sd <= mean(total))

    cat(label, ": ", "Expected:", mean(total), "±",  sd(total),
        "Reported:", reported_sd, "p:", p, "\n")

    p
}

# Check variance in all cases where we have AM, PM and AM+PM data (weeks 0 to 4)
p_values <- c()
invalid_mean_sum_count <- 0
par(mfrow=c(4,3))
for (group in unique(data$group)) {
    n <- data[data$group == group, ]$n[1]

    for (test in unique(data$test)) {
        for (week in c(0, 2, 4)) {

            m1 <- data$mean[ data$group == group
                           & data$test == test
                           & data$week == week
                           & data$period == "AM"]

            sd1 <- data$sd[ data$group == group
                          & data$test == test
                          & data$week == week
                          & data$period == "AM"]

            m2 <- data$mean[ data$group == group
                           & data$test == test
                           & data$week == week
                           & data$period == "PM"]

            sd2 <- data$sd[ data$group == group
                          & data$test == test
                          & data$week == week
                          & data$period == "PM"]

            me <- data$mean[ data$group == group
                           & data$test == test
                           & data$week == week
                           & data$period == "AMPM"]

            sde <- data$sd[ data$group == group
                          & data$test == test
                          & data$week == week
                          & data$period == "AMPM"]

            if (round(m1 + m2, 2) != me) {
                invalid_mean_sum_count <- invalid_mean_sum_count + 1
                cat(sprintf("Invalid mean sum: %s %s w%s\t%s + %s = %s ≠ %s\n",
                            group, test, week, m1, m2, m1+m2, me))
            }

            label <- paste(group, week, sep="-")

            # Rounded because original paper had integer values
            p <- check_sd(n, m1, sd1, m2, sd2, sde, label, round=TRUE)
            p_values <- c(p_values, p)
        }
    }
}

if (invalid_mean_sum_count > 0) {
    number_mean_sum <- length(na.omit(data$mean[data$period == "AMPM"]))
    cat("Percentage of invalid mean sum",
        round(invalid_mean_sum_count * 100 / number_mean_sum, 1),
        "%\n")
}
cat("\n")

# Doubled for two-tail p-value
p_values <- (p_values)
# Adjust for multiple measurements
adjusted_p_values <-p.adjust(2*p_values, method="hochberg")
cat("SD check: Adjusted p_values:", round(adjusted_p_values, 4), "\n")
if (all(adjusted_p_values < 0.05)) {
    cat("All SD checks significantly failed (p<0.05)\n")
} else if (any(adjusted_p_values < 0.05)) {
    cat("Some SD checks significantly failed (p<0.05)\n")
}
cat("\n")


# Check baseline change consistency
invalid_change_count <- 0
for (group in unique(data$group)) {
    n <- data[data$group == group, ]$n[1]

    for (test in unique(data$test)) {
        for (week in c(2, 4, 6)) {

            for (period in unique(data$period)) {
                # No data for week 6 aside from PM
                if (week == 6 & period != "PM") {
                    next
                }

                baseline <- data$mean[ data$group == group
                                     & data$test == test
                                     & data$week == 0
                                     & data$period == period]

                reported_mean <- data$mean[ data$group == group
                                          & data$test == test
                                          & data$week == week
                                          & data$period == period]

                reported_change <- data$mean_change[ data$group == group
                                                   & data$test == test
                                                   & data$week == week
                                                   & data$period == period]

                diff <- round(abs(baseline + reported_change - reported_mean),2)

                # Allow for rounding errors
                if (diff > 0.01) {
                    invalid_change_count <- invalid_change_count + 1
                    cat(sprintf("Invalid change: %s %s w%s %s\t%s%s = %s ≠ %s\n",
                                group, test, week, period,
                                baseline, reported_change,
                                baseline+reported_change, reported_mean))
                }
            }
        }
    }
}

if (invalid_change_count > 0) {
    number_mean_sum <- length(na.omit(data$mean_change))
    cat("Percentage of invalid mean sum",
        round(invalid_change_count * 100 / number_mean_sum, 1),
        "%\n")
}
cat("\n")
