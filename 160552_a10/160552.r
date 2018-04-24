x11()
lambda <- 0.2
vec <- rexp(50000, lambda)
plot(sort(vec), main="Scatter Plot")
cat("Press any key to continue\n")
x <- readLines("stdin", 1)

mat = matrix(vec, nrow = 500, ncol = 100)

for (i in 1:5)
{
    plot(ecdf(mat[i,]), ylab="F(X)", main=paste("CDF for vector", toString(i)))
    cat("Press any key to continue")
    x <- readLines("stdin", 1)

    pdata <- rep(0, 100);
    for(j in 1:100)
    {
        val=round(mat[i,j], 0);
        if(val <= 100)
            pdata[val] = pdata[val] + 1/100;
    }
    xcols <- c(0:99)
    pdf <- predict(smooth.spline(xcols, pdata, spar=0.2))

    plot(pdf, pch=19, xlab="x", ylab="f(X)", main=paste("PDF for vector", toString(i)))
    lines(pdf)
    #plot(density(mat[i,]), main=paste("PDF for vector", toString(i)))
    cat("Press any key to continue")
    x <- readLines("stdin", 1)

    cat("Vector ", i, ", Mean = ", mean(mat[i,]), ", Standard deviation = ", sqrt(var(mat[i,])), "\n", sep = "")
}

means = apply(mat, 1, mean)

plot(table(round(means)), main="Frequency for means")
cat("Press any key to continue\n")
x <- readLines("stdin", 1)

plot(ecdf(means), main="CDF for means")
cat("Press any key to continue\n")
x <- readLines("stdin", 1)

plot(density(means), main="PDF for means")
cat("Press any key to continue\n")
x <- readLines("stdin", 1)

cat("For means, Mean = ", mean(means), ", Standard deviation = ", sqrt(var(means)), "\n", sep = "")
cat("According to CLT, Expected Mean = ", 1/lambda, ", Expected Standard deviation = ", 0.1/lambda, "\n", sep = "")
