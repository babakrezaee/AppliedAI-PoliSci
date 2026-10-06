# ---------------------------------------------------------------------------
# Week 6: a second opinion from a different company
#
# Check three currently compares two models from one provider, which is a weak
# form of independence: same company, similar training data, similar
# assumptions. This runs the identical prompt through a model from a different
# company so the comparison is between two genuinely separate instruments.
#
# One run of 181 tweets. Two to three minutes, a few cents.
#
# SETUP, once:
#   1. Get an API key from the Anthropic developer console. A Claude Pro
#      subscription does NOT give API access; it is a separate account.
#   2. usethis::edit_r_environ()
#   3. Add one line, no quotes, no spaces around the = sign:
#         ANTHROPIC_API_KEY=sk-ant-...
#   4. Save, restart R.
#   5. Check without printing the key:
#         nchar(Sys.getenv("ANTHROPIC_API_KEY")) > 0
#
# ellmer reads that variable by itself. The key never appears in this script.
# ---------------------------------------------------------------------------

library(ellmer)

url <- paste0("https://raw.githubusercontent.com/babakrezaee/",
              "AppliedAI-PoliSci/refs/heads/main/data/",
              "trump_immigration_2019.csv")

tweets <- read.csv(url, stringsAsFactors = FALSE,
                   colClasses = c(id = "character"))  # 19-digit IDs: text, not numbers

train_id <- 1:floor(0.8 * nrow(tweets))
test     <- tweets[-train_id, ]

nrow(test)   # should print 181

# ---------------------------------------------------------------------------
# Identical schema and identical prompt A. Nothing varies except the provider.
# ---------------------------------------------------------------------------

type_label <- type_object(
  "Whether a tweet is about immigration.",
  label = type_enum(
    c("immigration", "other"),
    "immigration if immigration, immigrants, the border, or immigration policy
     is a main subject of the tweet; other otherwise."
  )
)

prompt_a <- "
You are coding tweets for a political science project.

Decide whether immigration is a main subject of the tweet. This includes the
southern border, the border wall, illegal immigration, deportation, ICE,
sanctuary cities, asylum, visas, and DACA.

If immigration is mentioned only in passing within a longer list of topics,
code it as other.
"

# Name the model explicitly rather than relying on the default, which changes.
# models_anthropic() lists what is currently available to your account.
model_claude <- "claude-sonnet-5"

chat_c <- chat_anthropic(prompt_a, model = model_claude, echo = "none")

run_claude <- parallel_chat_structured(chat_c, as.list(test$text),
                                       type = type_label)

# ---------------------------------------------------------------------------

out <- data.frame(
  id          = test$id,
  text        = test$text,
  human       = test$label,
  llm_claude  = as.character(run_claude$label),
  stringsAsFactors = FALSE
)

write.csv(out, "llm_claude_w6.csv", row.names = FALSE)

# ---------------------------------------------------------------------------
# A look before you send it. The second line is the one that matters: it is
# the comparison the handout cannot currently make.
# ---------------------------------------------------------------------------

cat("\naccuracy against the hand labels:",
    round(mean(out$llm_claude == out$human), 3), "\n")

prev <- read.csv(paste0("https://raw.githubusercontent.com/babakrezaee/",
                        "AppliedAI-PoliSci/refs/heads/main/data/",
                        "llm_labels_w6.csv"),
                 stringsAsFactors = FALSE, colClasses = c(id = "character"))

stopifnot(identical(prev$text, out$text))   # same tweets, same order

cat("agreement with the first model, same company :",
    round(mean(prev$llm_main == prev$llm_model2), 3), "\n")
cat("agreement with the first model, other company:",
    round(mean(prev$llm_main == out$llm_claude), 3), "\n")

cat("\nRecord for the write-up:\n")
cat("  date run :", format(Sys.time()), "\n")
cat("  model    :", model_claude, "\n")
cat("  ellmer   :", as.character(packageVersion("ellmer")), "\n")
