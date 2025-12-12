# Science Advances Quarto Template

A Quarto extension that helps authors draft Science Advances manuscripts and supplementary materials with journal-aligned structure and defaults.

## Getting started

### Create a new manuscript project

```bash
quarto use template mcashm/Science_Advances_Quarto_template --no-prompt
```

This installs the extension and generates `template.qmd` and `supplement.qmd` with Science Advances scaffolding.

### Add to an existing project

From your Quarto project directory:

```bash
quarto add mcashm/Science_Advances_Quarto_template
```

Use the `sciadv-pdf` or `sciadv-html` formats in your document YAML:

```yaml
title: "Your Manuscript Title"
format:
  sciadv-pdf:
    keep-tex: true
bibliography: bibliography.bib
```

Render with:

```bash
quarto render template.qmd --to sciadv-pdf
quarto render template.qmd --to sciadv-html
```

## Format options

* **Citation style**: Uses the Science Advances CSL via `citeproc` for both HTML and PDF.
* **Page setup (PDF)**: Letter paper, 12pt base font, 1 in margins, light line stretch (1.2), colored links, line numbers, and Science Advances headers/footers.
* **HTML theme**: `sciadv.scss` applies a readable serif body font with a clean blue accent.

### PDF-specific features

The PDF format includes several Science Advances-specific formatting elements:

- **Line numbers**: Automatically added to the left margin for easy reference during review
- **Page headers**: "Science Advances" on the left, "Manuscript Template" on the right
- **Page footers**: "Page X of Y" format in the bottom right
- **Keywords display**: Keywords from the YAML metadata are displayed after the abstract
- **One-sentence summary**: The `teaser` field is displayed prominently after the abstract

## Manuscript structure

The template shows placeholders for the key Science Advances sections:

- Title, short title, and one-sentence summary (teaser)
- Authors (with basic name display)
- Abstract (<160 words) and keywords
- Introduction, Results, Discussion, Materials and Methods
- References plus required back-matter blocks (Acknowledgments, Funding, Author contributions, Competing interests, Data availability)
- Supplementary Materials callout

### Author information

The template automatically displays author names from the YAML metadata. The Science Advances format requires numbered affiliations and corresponding author markers. While the template will display author names, affiliation superscripts need to be manually formatted in the final submission if required by the journal during the editorial process.

## Supplementary materials

`supplement.qmd` provides a companion layout for the Supplementary Materials PDF. Keep the title and first author consistent with the main manuscript and organize content into Supplementary Text, Figures, Tables, Captions, and References.

## Reference files

- `advances_ms_template_2022.pdf`: Science Advances manuscript instructions
- `advances_supplementary_materials_template_2022.pdf`: Supplementary materials instructions
