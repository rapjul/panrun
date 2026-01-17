# Panrun

Minimal script that runs [pandoc](http://pandoc.org/) with the options it finds in the YAML metadata of the input markdown file. For example:

```sh
panrun -t html input.md
```

with the following `input.md`:

```md
---
title: my document
from: gfm
output:
    html:
        standalone: true
        output: test.html
        include-in-header:
            - foo.css
            - bar.js
    latex:
        from: gfm+hard_line_breaks
        toc: true
        toc-depth: 3
        output: test.pdf
        template: letter.tex
        metadata:
            fontsize: 12pt
---

# My Header

My text.

## My Sub-Header

More of my text.
```

Will execute:

```sh
pandoc test.md --standalone --output test.html --include-in-header foo.css --include-in-header bar.js --from gfm -to html
```

Note how panrun defaults to using the first key in the YAML, in this case `html`.


## Usage

```sh
panrun [pandoc-options] input-file
```

You can also supply more options either *before* or *after* the input file; both are supported and will be forwarded to pandoc. Panrun also looks at the `-o` (`--output`) and `-t` (`--to`) options to determine the output format. For example:

```sh
panrun -t epub input.md
panrun input.md -t latex -o test.pdf
```

Panrun will only look at the YAML in the first input-file, but more are passed along to pandoc:

```sh
panrun 01.md 02.md 03.md -o output.pdf
```

Thus `panrun *.md` will work, as long as the YAML is found in the alphabetically first file.

The input-file doesn't even have to be a markdown file. As long as it starts with a YAML block, it should work.


### Defaults and document types

If you put some YAML in `~/.panrun/default.yaml` (see `panrun -h` for the Windows location), panrun will merge this with the YAML in your input file and add the `--metadata-file` option when calling pandoc. The YAML should be in the same format as always, for example:

```yaml
---
author: Always Me
output:
    html:
    standalone: true
---
```

Finally, you can e.g. put `type: letter` in the YAML of your input document. In that case, panrun will look for `~/.panrun/letter.yaml` instead of `default.yaml`.

### Specifying the input format (`from`)

You can specify the pandoc input format using a top-level `from:` key (applies as a default for all outputs) or a per-output `from:` that overrides the top-level value. This is useful when you want more than plain `markdown`, e.g. to enable extensions:

```yaml
from: markdown+hard_line_breaks+lists_without_preceding_blankline-blank_before_blockquote-blank_before_header
output:
    epub:
    from: markdown+hard_line_breaks+lists_without_preceding_blankline-blank_before_blockquote-blank_before_header
    standalone: true
```

The `from` value is passed through to pandoc as `--from <value>`.

## Multiple outputs, auto-filename and CLI flags

You can convert a document to multiple formats in one invocation using multiple `-t` flags, or by using a YAML `outputs:` list in your document:

```sh
panrun -t html -t epub input.md
```

or in YAML:

```yaml
---
outputs:
  - html
  - epub
output:
  html:
    standalone: true
  epub:
    standalone: true
auto-filename: true
---
```

When `auto-filename: true` is set, panrun will generate output filenames from the document `title` (or the first top-level `# Heading` if `title` is not present). Use `auto-filename: date` (or `auto-filename-date: true`) to append the current date in ISO format to the generated filename, e.g. `my-title_2026-01-16.epub`.

CLI flags added:

- `--force` / `-f` — overwrite existing output files
- `--dry-run` — show planned commands without running them
- `--verbose` / `-v` — show pandoc output and commands
- `--quiet` — suppress informational messages
- `--log <file>` — append panrun invocation messages to a log file
- `--help` / `-h` — show help

panrun validates requested formats against your installed pandoc (it strips `+`/`-` extensions before checking). If pandoc is missing, panrun will show installation hints for your platform (Homebrew, apt, dnf, pacman, apk, choco/winget).


## Design

- Panrun should run with no dependencies except pandoc and `ruby >= 2.3.3`, which is the builtin in macOS 10.13.
- Fortunately, Ruby comes with a YAML parser, which is the same one Jekyll uses.
- Panrun doesn't hardcode or assume anything about the options. It simply asks your installed pandoc which options it supports (through `pandoc --bash-completion`) and ignores the unknown options in your YAML.
- The idea is to be somewhat compatible with [rmarkdown's document format](https://bookdown.org/yihui/rmarkdown/output-formats.html). Therefore you can use, for example, either the `html` or `html_document` key (or even `pdf_document` or `slidy_presentation`), or either `toc-depth` or `toc_depth`, and the value of `pandoc_args` is also passed on. (However, as opposed to rmarkdown, panrun doesn't do anything more than passing on the options it finds.) Question: is this useful to anyone, or does this introduce more confusion, since a lot of rmarkdown-options will be silently ignored?
- If you're looking for more than a simple wrapper script, have a look at [panzer](https://github.com/msprev/panzer) or [pandocomatic](https://github.com/htdebeer/pandocomatic).
- If you're wondering whether this functionality will soon be part of pandoc itself, the answer is [probably not](https://github.com/jgm/pandoc/issues/4627#issuecomment-422108494).
- Look at the source, it's really quite minimal! (In the end, I couldn't resist adding another ~40 lines of code for the defaults functionality...)


## Installation

1. [Download panrun](https://raw.githubusercontent.com/rapjul/panrun/master/panrun)
2. Place the file somewhere on your `PATH` (e.g. in `/usr/local/bin/`)
3. Make sure the file has no extension and make it executable. On macOS/Linux (for Windows [read this](https://stackoverflow.com/questions/1422380/)):

```sh
chmod +x ./panrun
```
