# Applied AI for Political Scientists

Course materials for the core course of the MSc Political Science specialization in the Politics of Artificial Intelligence, Leiden University. Block 1, Fall 2026.

**Read the handouts here:** https://babakrezaee.github.io/AppliedAI-PoliSci/

The website is where you read. This repository holds the same material as source files, together with the templates and datasets used in the workshops.

## Contents

| Folder | Contents |
|---|---|
| `bootcamp/` | Preparatory R material. Work through it before 2 September. |
| `handouts/` | Weekly handouts, Weeks 1 to 6, and the final project brief. |
| `templates/` | Starting files for the final project and for the Week 5 API call. |
| `data/` | Datasets used in the handouts. |
| `R/` | Helper scripts used in more than one handout. |
| `docs/` | The rendered website. Generated automatically; do not edit. |

## Downloading a single file

You do not need to download the whole repository. To get one file, for instance the final project template:

1. Click the file in the list above.
2. Click the **Download raw file** button at the top right of the file view.
3. Save it somewhere you will find it again, and open it in RStudio.

Datasets used in the handouts load over the internet, so you do not need to download those at all. The code in each handout includes the address.

## API credentials, from Week 5 onward

Week 5 involves calling a language model from R, which requires a key. Keys are issued through the course; do not use a personal account.

Copy `.Renviron.example`, rename the copy to `.Renviron`, paste the key after the equals sign, and restart R. In your code the key is then retrieved with `Sys.getenv("OPENAI_API_KEY")`.

Never type a key into a script, a `.qmd` file, or anything you submit. A key that has been shared has to be revoked, and deleting the line afterward does not undo it.

## If something does not run

Say so, in the workshop or by email. Code in the handouts is more likely to be wrong than you are, and a broken example is worth fixing for everyone.

## Reuse

Prepared for students enrolled in the course. Please do not redistribute without permission.
