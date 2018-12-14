#' setup_tweets
#'
#' This function sets up the environment for twitter functions. It does not need to be called prior to the other functions though.
#'
#' @param consumer_key From API.
#' @param consumer_secret From API.
#' @param access_token From API.
#' @param access_secret From API.
#'
#' @import base64enc
#' @import twitteR
setup_tweets = function(consumer_key = "kmp7IUYAhZQftCrYkFSICCjuz", consumer_secret = "EMtBaYhcYV7V3vAEmSMSvApaSDJfj101fCD5TYAjicf4Z3ncy6", access_token = "1060241795240599557-Qyvx7TY0kYQ2ovPLYnMi6E4GNgirko",
    access_secret = "Q0AEBJvFx8kAh1p5tOCFppWppT12Mm8iEEj0zaf7dFvxL") {
    invisible(capture.output(setup_twitter_oauth(consumer_key, consumer_secret, access_token, access_secret)))
}



#' show_tw
#'
#' Shows one recent tweet related to the parameter inside the function.
#'
#' @param string The name of the university to find a tweet about.
#' @return A description of whether the university is viewed positively or negatively on Twitter. Scores vary from -4 to 4.
#' @examples
#' show_tw('Yale University')
#' @import twitteR
show_tw = function(string, n_tweets = 1) {
    setup_tweets()
    twt = twitteR::searchTwitter(string, n = n_tweets, since = as.character(Sys.Date() - 30))
    df_tw = twitteR::twListToDF(twt)
    print(df_tw$text)
}



#' get_tw_words
#'
#' This function scrapes Twitter to return a vector of words related to the university. It is mainly a helper function for the other Twitter-related functions.
#'
#' @param string The complete name of the university as in the dataset.
#' @param n_tweets The number of tweets to scrape.
#' @param since_date The date to first start scraping.
#' @return A vector with the words from the tweets associated with the string.
#' @import stringr
#' @import twitteR
get_tw_words = function(string, n_tweets, since_date) {
    setup_tweets()
    twt = twitteR::searchTwitter(string, n = n_tweets, since = as.character(since_date), retryOnRateLimit = 10000, lang = "en")
    df_tw = twitteR::twListToDF(twt)
    words = vector()
    for (i in 1:nrow(df_tw)) {
        text = vector()
        count = 1
        while (!is.na(word(df_tw$text[i], count))) {
            text[count] = str_extract(word(df_tw$text[i], count), regex("[A-Za-z]+"))
            count = count + 1
        }
        words = append(words, text)
    }
    return(words)
}



#' get_tw_feelings
#'
#' This function uses sentiment analysis from the afinn dataset to rate positivity and negativity of the words associated with a certain university on Twitter.
#'
#' @param string The complete name of the university.
#' @param n_tweets The number of tweets to scrape.
#' @param since_date The date to first start scraping.
#' @return A description of whether the university is viewed positively or negatively on Twitter. Scores vary from -4 to 4.
#' @examples
#' get_tw_feelings('Harvard University')
#' @import tidyverse
#' @import tidytext
#' @import utf8
#'
get_tw_feelings = function(string, n_tweets = 20, since_date = Sys.Date() - 30) {
    words = get_tw_words(string, n_tweets, since_date)
    afinn = get_sentiments("afinn")
    scores = vector()
    count = 1
    for (i in 1:length(words)) {
        if (words[i] %in% afinn$word) {
            scores[count] = afinn$score[which(afinn$word == words[i])]
            count = count + 1
        }
    }
    p_value = t.test(scores)[[3]]
    avg = t.test(scores)[[5]]
    if (avg > 1.5) {
        message = "Wow, that's very positive!"
        emoji = "\U0001f601"
    } else if (avg > 0.5) {
        message = "That's positive!"
        emoji = "\U0001f603"
    } else if (avg > 0) {
        message = "That's close to neutral, slightly positive."
        emoji = "\U0001f60a"
    } else if (avg > -0.5) {
        message = "That's close to neutral, slightly negative"
        emoji = "\U0001f623"
    } else if (avg > -1.5) {
        message = "That's negative..."
        emoji = "\U0001f628"
    } else {
        message = "That's very, very negative."
        emoji = "\U0001f631"
    }
    cat("The positivity/negativity score of the ", n_tweets, " tweets is ", avg, " (p-value = ", p_value, "). ", message, " ", sep = "")
    cat(utf8_format(emoji))
}



#' plot_moody_pie
#'
#' This function utilizes the nrc dataset to get the emotions associated with the words from the tweets related to the university being searched.
#'
#' @param string The complete name of the university.
#' @param n_tweets The number of tweets to scrape.
#' @param since_date The date to first start scraping.
#' @return A pie chart plot with the sentiments associated with that univertity on Twitter.
#' @examples
#' plot_moody_pie('Princeton University')
#' @import tibble
#' @import tidytext
#' @import ggplot2
plot_moody_pie = function(string, n_tweets = 20, since_date = Sys.Date() - 30) {
    words = get_tw_words(string, n_tweets, since_date)
    nrc = get_sentiments("nrc")
    feelings = vector()
    count = 1
    for (i in 1:length(words)) {
        if (words[i] %in% nrc$word) {
            for (j in 1:length(which(nrc$word == words[i]))) {
                feelings[count] = nrc$sentiment[which(nrc$word == words[i])[j]]
                count = count + 1
            }
        }
    }
    f_df = tibble(feelings)
    colnames(f_df) = "feelings"
    f_df[[1]] = as.factor(f_df[[1]])
    ggplot(f_df, aes(x = 1, fill = feelings, col = feelings)) +
      geom_bar() +
      coord_polar(theta = "y") +
      ggtitle(string)
}
