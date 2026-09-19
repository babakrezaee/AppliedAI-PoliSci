# Trump tweets, 2019, labeled for immigration

`trump_immigration_2019.csv` is a hand-labeled corpus for supervised text
classification. Each row is one tweet, labeled for whether it is about
immigration.

| Column | Contents |
|---|---|
| `id` | Tweet status ID |
| `date` | Timestamp, `YYYY-MM-DD HH:MM` |
| `label` | `immigration` or `other` |
| `text` | The tweet |

905 rows. 367 labeled `immigration`, 538 labeled `other`. Predicting `other`
for every tweet therefore gets 59.4 percent correct, which is the number any
model has to beat before its accuracy means anything.

## Where the tweets come from

All tweets posted by `@realDonaldTrump` during calendar year 2019, taken from
the Complete Trump Tweets Archive:

<https://github.com/MarkHershey/CompleteTrumpTweetsArchive>

7,249 tweets were posted in 2019. Cleaning removed 2,498 retweets, 561 tweets
whose content was only a link, hashtag, or mention, and 42 exact duplicates,
leaving 4,148 original tweets.

Two repairs were applied. The source file has character-encoding damage, where
UTF-8 was read as MacRoman, so an en dash arrives as `‚Äì`; this was decoded
back. HTML entities were unescaped, so `&amp;` is now `&`. Without the second
repair, `amp` becomes one of the most frequent tokens in the corpus and appears
in any word-frequency plot.

## How the 905 were chosen

The corpus is **stratified, not a random sample of 2019.** Immigration tweets
are a minority of any year's output, so a random sample would have left too few
positive cases to train on and an accuracy figure that means nothing.

Two strata:

1. **Keyword candidates, 755 tweets.** Every 2019 tweet matching a deliberately
   broad term list (immigra*, migrant, border, wall, illegal, alien, deport,
   asylum, refugee, caravan, DACA, amnesty, sanctuary, ICE, visa, citizenship,
   MS-13, Mexico, and others). The list was built for recall, not precision, so
   it pulls in a large number of tweets that are not about immigration at all.
   Of these, 366 were labeled `immigration` and 389 `other`.

2. **Random sample, 150 tweets.** Drawn with seed 7 from the 3,393 tweets that
   matched no keyword. 1 was labeled `immigration`, 149 `other`.

**Every label was assigned by reading the tweet, not by the keyword match.**
The keyword list decided which tweets were *read*. It did not decide any label.

This matters for what the negative class contains. Because 389 of the 538
`other` tweets came out of the keyword search, the negative class is full of
near misses: Wall Street Journal, the Turkish and Syrian borders, the China and
Hong Kong border, ice and snow in a joke about Amy Klobuchar, "illegal"
applied to wiretaps and leaks, MS-13 with no immigration claim attached. A
classifier cannot do well here by spotting a single word.

Rows are shuffled with seed 7, so splitting on row number gives an approximately
random split rather than a temporal one. Keep `date` if you want a temporal
split on purpose: immigration is far denser in January and February, during the
shutdown, than in the final quarter, when impeachment dominates.

## Coding scheme

`immigration` means immigration, immigrants, the border, or immigration policy
is **a main subject** of the tweet: the southern border and border security,
the wall and the fights over funding it, illegal or undocumented immigrants,
deportation, ICE, sanctuary cities, asylum and refugees entering the United
States, visas, DACA, amnesty, the travel ban, the census citizenship question,
or attacking or praising somebody specifically over their immigration position.
Gangs and drugs count only where the tweet itself ties them to immigrants or to
the border.

`other` is everything else.

Four rules resolved the hard cases, and they were applied consistently:

1. **Passing mention in a long list is `other`.** A tweet listing ten
   accomplishments with "Border" as the seventh is not about immigration. A
   short tweet naming three or four things, of which immigration is one, is.
2. **A claim is what counts.** A tweet that asserts something about immigration
   or border policy is `immigration`, even when that claim is a comparison. A
   tweet that merely uses a border image to talk about something else is not.
3. **Endorsement boilerplate is `other`.** "Strong on Crime, the Border, the
   Second Amendment, loves our Military and Vets" is a formula, and the border
   is one slot in it. Where immigration is the dominant charge against an
   opponent, the tweet is `immigration`.
4. **Location alone is not a topic.** Announcing a television interview held at
   the border is `other`; announcing a speech *about* border security is
   `immigration`.

Rule 1 is the one that moves the most cases, and it is worth saying out loud in
class, because it is a coding decision rather than a fact about the world. A
different coder could take the other view and produce a measurably different
dataset from identical tweets.

## What the accuracy figure does and does not mean

A Bernoulli Naive Bayes on binary word presence, fit on 80 percent of these
rows and tested on the remaining 181, gives:

|  | actual `immigration` | actual `other` |
|---|---|---|
| predicted `immigration` | 68 | 3 |
| predicted `other` | 9 | 101 |

Accuracy 93.4 percent, against a majority-class baseline of 57.5 percent on
that split.

That figure describes performance **on this constructed sample**. It is not the
accuracy you would get on a random stream of 2019 tweets, where immigration is
much rarer and the number of ways a tweet can be about something else is much
larger. The sample was built to be roughly balanced so that accuracy is
interpretable at all; the price is that it no longer represents the population
it was drawn from. Both halves of that sentence are worth a minute of class time.

## Known limits

- **One author, one year, one language.** Nothing here generalizes to other
  speakers or periods, and the model will learn this author's idiom rather than
  the concept of immigration.
- **One coder.** Every label was assigned by the same coder, so there is no
  second coder and no inter-coder reliability statistic. Where a label is
  contestable it has been decided in one direction, consistently, but decided
  all the same.
- **The keyword filter can miss.** In the 150-tweet random sample, 1 immigration
  tweet contained no keyword, which puts the miss rate somewhere near 1 percent
  on keyword-free tweets. A handful of positives in the 2019 corpus were
  therefore never read and are not in this file.
- **Contested content.** These tweets make empirical claims about immigrants and
  crime that are disputed, and some use language that students may find ugly.
  They are reproduced unedited because editing them would corrupt the corpus.
  Worth flagging before the session rather than during it.
