#' pay_loans
#'
#' Time to pay student loans.
#'
#' @param university The complete name of the university.
#' @param salary The expected salary you will earn yearly in dollars.
#' @param interest The annual interest rate for the loans.
#' @param per_sal The percentage of the salary that would go into paying the loans.
#' @return The number of years to pay entirely for the loans based on the tuition of the chosen university.
#' @examples
#' pay_loans('Harvard University', salary = 80000, interest = 0.05, per_sal = 0.2)
#' pay_loans('Brown University', salary = 50000, interest = 0.01, per_sal = 0.1)
#' @import tidyverse
pay_loans = function(university, salary = 70000, interest = 0.03, per_sal = 0.15) {
    load("R/sysdata.Rdata")
    if (length(which(df$University == university)) == 0) {
        stop("That is not a valid university")
    }
    tuition = as.integer(as.character(df$Tuition[which(df$University == university)]))
    if (is.na(tuition)) {
        stop("Sorry, there is no tuition data avaiable for that university")
    }
    bill = 4 * tuition
    year = 0
    while (bill > 0) {
        bill = bill - salary * per_sal
        bill = bill * (1 + interest)
        year = year + 1
    }
    cat("Assuming a salary of ", salary, " dollars per year, that ", per_sal * 100, "% (", per_sal * salary, "$) would be used to pay the loan annualy, and an interest rate at ", 0.02 * 100, "% y/y, it would take ", year, " year(s) to pay for the student loans", sep = "")
}
