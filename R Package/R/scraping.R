#'@import rebus
#'@import stringr
#'@import rvest
#'@import tidyverse
#'@import httr
#'@import xml2
make_df = function() {

    print("It might take some minutes to scrape...")

    #The following functions are sort of helper functions in order to scrape the data:

    # removes spaces, new lines, some symbols from all scraped data
    clean_str = function(strg) {
        strg = str_remove_all(strg, "\n")
        strg = str_remove_all(strg, " ")
        strg = str_remove_all(strg, regex("[$%+,]"))
    }

    # returns school type
    get_school_type = function(info) {
        school_type = str_split(info[1], ",", n = 2)
        school_type = school_type[[1]][1]
        school_type = clean_str(school_type)
        return(school_type)
    }

    # returns year founded
    get_year_founded = function(info) {
        year = clean_str(info[2])
        year = str_remove_all(year, regex("[a-z]"))
        return(year)
    }

    # returns religious affiliation
    get_religion = function(info) {
        religion = str_remove_all(info[3], "\n")
        religion = str_remove_all(religion, "religious affiliation")
        religion = str_remove_all(religion, "/s")
        return(religion)
    }

    # returns endowment
    get_endowment = function(info) {
        endowment = str_remove_all(info[6], regex("[a-z]"))
        endowment = str_remove_all(endowment, regex("20[0-9]{2}"))
        endowment = clean_str(endowment)
        # choose unit of million or billion
        if (str_detect(info[6], pattern = "million")) {
            return(endowment)
        } else {
            endowment = as.numeric(endowment) * 1000
            return(endowment)
        }
    }

    # returns median starting salary for new graduates
    get_median_starting_salary = function(info2) {
        if (str_detect(info2[1], regex("[0-9]"))) {
            salary = clean_str(info2[1])
            salary = str_remove_all(salary, regex("[,*]"))
            return(salary)
        } else {
            return(NA)
        }
    }

    # returns acceptance rate
    get_acc_rate = function(info2) {
        lon = 2:9
        accept = NA
        for (i in lon) {
            if (str_detect(info2[i], "%")) {
                accept = info2[2]
                accept = clean_str(info2[i])
                break
            }
        }
        return(accept)
    }

    # get student faculty ratio
    get_stu_fac_ratio = function(info2) {
        lon = 9:13
        ratio = NA
        try({
            for (i in lon) {
                if (str_detect(info2[i], ":")) {
                  ratio = clean_str(info2[i])
                  break
                }
            }
        }, silent = TRUE)
        return(ratio)
    }

    # get 4 year graduation rate
    get_grad_rate = function(info) {
        lon = 10:14
        grad = NA
        try({
            for (i in lon) {
                if (str_detect(info2[i], "%")) {
                  grad = clean_str(info2[i])
                  break
                }
            }
        }, silent = TRUE)
        return(grad)
    }

    # gets score
    get_score = function(details) {
        score = NA
        if (str_detect(details[2], pattern = "Overall")) {
            score = clean_str(details[2])
            score = str_remove_all(score, regex("[a-zA-Z]"))
            score = str_split(score, "/", n = 2)
            score = score[[1]][1]
        }
        return(score)
    }

    # gets location
    get_location = function(details) {
        lon = 1:4
        location = NA
        for (i in lon) {
            if (str_detect(details[i], ",")) {
                location = details[i]
                break
            }
        }
        return(location)
    }

    # gets tuition
    get_tuition = function(details) {
        lon = 4:9
        tuition = NA
        for (i in lon) {
            if (str_detect(details[i], "Quick")) {
                ind = i + 1
                tuition = clean_str(details[ind])
                tuition = str_split(tuition, "\\(", n = 2)
                tuition = tuition[[1]][1]
            }
        }
        return(tuition)
    }

    # get room & board
    get_room_board = function(details) {
        lon = 4:9
        rb = NA
        for (i in lon) {
            if (str_detect(details[i], "Quick")) {
                ind = i + 2
                rb = clean_str(details[ind])
                rb = str_split(rb, "\\(", n = 2)
                rb = rb[[1]][1]
            }
        }
        return(rb)
    }

    # get enrollment
    get_enrollment = function(details) {
        lon = 4:9
        enroll = NA
        for (i in lon) {
            if (str_detect(details[i], "Quick")) {
                ind = i + 3
                enroll = clean_str(details[ind])
            }
        }
        if (str_detect(enroll, "\\(")) {
            enroll = str_split(enroll, "\\(", n = 2)
            enroll = enroll[[1]][1]
        }
        return(enroll)
    }


    universities = rep(NA, 312)
    links_u = rep(NA, 312)
    count = 0
    try(while (TRUE) {
        # change url
        count = count + 1
        url = str_c("https://www.usnews.com/best-colleges/rankings/national-universities?_mode=table&amp;_page=", as.character(count))
        tryCatch(webpage <- read_html(url), error = function() break)

        # university names
        names = html_text(html_nodes(webpage, "td.full-width > div > a"))
        universities[(sum(!is.na(universities)) + 1):(sum(!is.na(universities)) + length(names))] = names

        # links
        semi_links = html_attr(html_nodes(webpage, "div.text-strong.text-large.block-tighter > a"), "href")
        links_u[(sum(!is.na(links_u)) + 1):(sum(!is.na(links_u)) + length(semi_links))] = str_c("https://www.usnews.com", semi_links)
    }, silent = TRUE)

    year_founded = rep(NA, length(universities))
    religion = rep(NA, length(universities))
    endowment = rep(NA, length(universities))
    school_type = rep(NA, length(universities))
    median_start_sal = rep(NA, length(universities))
    acc_rate = rep(NA, length(universities))
    stu_fac_ratio = rep(NA, length(universities))
    grad_rate = rep(NA, length(universities))
    score = rep(NA, length(universities))
    location = rep(NA, length(universities))
    tuition = rep(NA, length(universities))
    room_board = rep(NA, length(universities))
    enrollment = rep(NA, length(universities))

    try(
      for (i in 1:length(universities)) {
        link = read_html(links_u[i])
        info = html_text(html_nodes(link, ".flex-small"))
        details = html_text(html_nodes(link, ".full-width , strong"))
        info2 = html_text(html_nodes(link, ".medium-end"))
        year_founded[i] = get_year_founded(info)
        religion[i] = get_religion(info)
        endowment[i] = get_endowment(info)
        school_type[i] = get_school_type(info)
        median_start_sal[i] = get_median_starting_salary(info2)
        acc_rate[i] = get_acc_rate(info2)
        stu_fac_ratio[i] = get_stu_fac_ratio(info2)
        grad_rate[i] = get_grad_rate(info2)
        score[i] = get_score(details)
        location[i] = get_location(details)
        tuition[i] = get_tuition(details)
        room_board[i] = get_room_board(details)
        enrollment[i] = get_enrollment(details)
    },
    silent = TRUE)

    df = data.frame(as.character(universities),
                    as.integer(as.character(year_founded)),
                    religion, as.integer(as.character(endowment)),
                    school_type,
                    as.integer(as.character(median_start_sal)),
                    as.integer(as.character(acc_rate)),
                    as.character(stu_fac_ratio),
                    as.integer(as.character(grad_rate)),
                    as.integer(as.character(score)),
                    as.character(location),
                    as.integer(as.character(tuition)),
                    as.integer(as.character(room_board)),
                    as.integer(as.character(enrollment)))

    colnames(df) = c("University",
                     "Year_Founded",
                     "Religion",
                     "Endowment",
                     "School_Type",
                     "Median_Start_Sal",
                     "Acc_Rate",
                     "Stu_Fac_Ratio",
                     "Graduation_Rate",
                     "Score",
                     "Location",
                     "Tuition",
                     "Room_Board",
                     "Enrollment")

    df = as.tibble(df)
    return(df)
}

#'get_data
#'
#'This function simply returns the data from US News stored in the package.
#'@examples
#'get_data()
get_data = function(){
  return(df)
}
