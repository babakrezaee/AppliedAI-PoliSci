# ---------------------------------------------------------------------------
# Week 6: generating the LLM labels in data/llm_labels_w6.csv
#
# This is the script that produced the file you are evaluating in class. It is
# here so that you can read exactly what was asked of the model, and re-run it
# yourself if you want to see how close you get.
#
# You will need the ellmer package and your own API key in .Renviron, as in
# Week 5. Two to four minutes, a few cents.
#
# You will NOT reproduce the file exactly. See data/llm_labels_w6_README.md for
# why, which is most of the point of this week.
#
# It produces three sets of labels for the same 181 test tweets:
#   A. the prompt as written            -> the comparison against the hand labels
#   B. the same task, reworded          -> the prompt-stability check
#   C. a second, larger model, prompt A -> the agreement-across-models check
# ---------------------------------------------------------------------------

library(ellmer)

set.seed(7)

url <- paste0("https://raw.githubusercontent.com/babakrezaee/",
              "AppliedAI-PoliSci/refs/heads/main/data/",
              "trump_immigration_2019.csv")

tweets <- read.csv(url, stringsAsFactors = FALSE,
                   colClasses = c(id = "character"))  # IDs are 19 digits:
                                                      # never read them as numbers

# The Week 4 split, reproduced exactly. Do not change this: the handout
# compares the model against Naive Bayes on the SAME held-out tweets.
n        <- nrow(tweets)
train_id <- 1:floor(0.8 * n)
test     <- tweets[-train_id, ]

nrow(test)   # should print 181

# ---------------------------------------------------------------------------
# The schema. Identical across all three runs, so only the prompt and the
# model vary and the comparison is clean.
# ---------------------------------------------------------------------------

type_label <- type_object(
  "Whether a tweet is about immigration.",
  label = type_enum(
    c("immigration", "other"),
    "immigration if immigration, immigrants, the border, or immigration policy
     is a main subject of the tweet; other otherwise."
  )
)

# ---------------------------------------------------------------------------
# A. The prompt as written
# ---------------------------------------------------------------------------

prompt_a <- "
You are coding tweets for a political science project.

Decide whether immigration is a main subject of the tweet. This includes the
southern border, the border wall, illegal immigration, deportation, ICE,
sanctuary cities, asylum, visas, and DACA.

If immigration is mentioned only in passing within a longer list of topics,
code it as other.
"

model_small <- "gpt-5.6-luna"   # see the README: model names go stale

chat_a <- chat_openai(prompt_a, model = model_small, echo = "none")

run_a <- parallel_chat_structured(chat_a, as.list(test$text), type = type_label)

# ---------------------------------------------------------------------------
# B. The same task, reworded. Deliberately a reasonable alternative phrasing
#    rather than a worse one: the point is that defensible rewordings disagree.
# ---------------------------------------------------------------------------

prompt_b <- "
Classify each tweet by topic.

Answer immigration if the tweet concerns immigration or border policy in any
substantial way. Answer other for everything else.
"

chat_b <- chat_openai(prompt_b, model = model_small, echo = "none")

run_b <- parallel_chat_structured(chat_b, as.list(test$text), type = type_label)

# ---------------------------------------------------------------------------
# C. A second model, prompt A
# ---------------------------------------------------------------------------

model_large <- "gpt-5.6-terra"

chat_c <- chat_openai(prompt_a, model = model_large, echo = "none")

run_c <- parallel_chat_structured(chat_c, as.list(test$text), type = type_label)

# ---------------------------------------------------------------------------
# Save. Keep the human label: it is the anchor for everything.
# ---------------------------------------------------------------------------

out <- data.frame(
  id          = test$id,
  date        = test$date,
  text        = test$text,
  human       = test$label,
  llm_main    = as.character(run_a$label),
  llm_reword  = as.character(run_b$label),
  llm_model2  = as.character(run_c$label),
  stringsAsFactors = FALSE
)

write.csv(out, "llm_labels_w6.csv", row.names = FALSE)

# A quick look, so you know it worked before sending it
table(human = out$human, llm = out$llm_main)

cat("\nagreement with humans :", round(mean(out$human == out$llm_main), 3),
    "\nprompt stability      :", round(mean(out$llm_main == out$llm_reword), 3),
    "\nagreement across models:", round(mean(out$llm_main == out$llm_model2), 3), "\n")

cat("\nRecord these for your own write-up:\n")
cat("  date run    :", format(Sys.time()), "\n")
cat("  models      :", model_small, "/", model_large, "\n")
cat("  ellmer      :", as.character(packageVersion("ellmer")), "\n")
