# LLM labels for Week 6

`llm_labels_w6.csv` holds the output of a large language model asked to decide
whether each of 181 tweets is about immigration, together with the hand labels
those tweets already carried. Week 6 is an exercise in judging that output, so
this file is the object of study rather than a convenience.

It is also, deliberately, a worked example of the reproducibility problem the
session is about. A measurement taken from a commercial API cannot be re-run in
the way a regression can, and recording enough for somebody else to try is the
minimum defensible practice. Everything needed to repeat the exercise is
documented below, and the script that produced the file is in the repository at
`R/w6_generate_llm_labels.R`.

## Columns

| Column | Contents |
|---|---|
| `id`, `date`, `text` | The tweet, carried over unchanged from `trump_immigration_2019.csv` |
| `human` | The hand label from Week 4, `immigration` or `other` |
| `llm_main` | The model's label under the prompt as written |
| `llm_reword` | The same model, same task, a reworded prompt |
| `llm_model2` | A second, larger model, under the original prompt |

181 rows, which are exactly the test cases from the Week 4 split, so the model's
labels can be compared against Naive Bayes on identical tweets.

## What is in it

Against the hand labels, `llm_main` is correct on 95.0 percent of the 181
tweets. The majority-class baseline is 51.9 percent. The model was shown no
labeled training examples at all.

Taking `immigration` as the positive class:

|  | human `immigration` | human `other` |
|---|---|---|
| predicted `immigration` | 85 | 7 |
| predicted `other` | 2 | 87 |

Precision is 0.924 and recall is 0.977, so the model over-flags: it is more
willing to call a borderline tweet `immigration` than to miss one.

The two reliability checks:

- **Prompt stability.** `llm_main` and `llm_reword` agree on 96.1 percent of
  tweets. Seven tweets change label under a rewording that any reasonable coder
  might have written first.
- **Agreement across models.** `llm_main` and `llm_model2` also agree on 96.1
  percent.

Read those two numbers against the error rate rather than on their own. The
model is wrong about 5 percent of the time and moves on about 4 percent of the
corpus when the prompt is reworded, so the instability introduced by a defensible
change of wording is nearly as large as the measured error.

The drift also has a direction. The original prompt returns 92 `immigration`
labels, the reworded prompt 99, and the second model 97, against 87 in the hand
coding. The disagreement is therefore systematic rather than random, which
matters for anything computed downstream from these labels.

## Reproducing it

Run `R/w6_generate_llm_labels.R`. It needs the `ellmer` package and an OpenAI
API key in `.Renviron`, exactly as in Week 5. Two to four minutes, and a few
cents of API credit.

You will not get this file back. You should get something close to it, and the
gap between "close" and "identical" is the point of the exercise.

**Run details. Record these for your own project.**

| | |
|---|---|
| Date run | TO BE COMPLETED |
| Model, `llm_main` and `llm_reword` | TO BE COMPLETED |
| Model, `llm_model2` | TO BE COMPLETED |
| `ellmer` version | TO BE COMPLETED |
| Temperature | provider default, not set explicitly |
| Seed | not set; the API offers no reliable one |

The prompts are reproduced verbatim in the script, which matters more than any
of the above. A description of a prompt is not a prompt.

## Four things that will stop you reproducing it exactly

**The model is not deterministic.** Repeat runs of the same prompt against the
same model return different labels for a small share of documents. Nothing in
the output indicates which ones.

**Temperature and decoding were left at the provider's defaults.** Fixing them
narrows the variation without eliminating it, and the defaults can themselves
change.

**Model names are not stable over time.** The identifiers above refer to
whatever those names pointed at on the date given. Providers retire and replace
models on their own schedule, and a withdrawn model cannot be re-run at all.

**The hand labels are a measurement, not the truth.** They were produced by one
coder applying the written codebook in `trump_immigration_2019_README.md`. A
second coder would disagree on some tweets, so the 95 percent figure describes
agreement between a model and one person's application of one coding scheme.
That is the strongest claim the file supports, and it is weaker than "the model
is 95 percent accurate."

## If you use this pattern in your own project

Report the model, the date, the exact prompt, and whether you set the
temperature. Then report how much of your corpus moves when you reword the
prompt, because it is cheap to compute and almost nobody reports it.

And keep in mind what the agreement figures do not establish. Two models
agreeing tells you a measurement is reproducible. It does not tell you the
measurement is right, and only the hand labels speak to that.
