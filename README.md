# convertmd

Converts a Markdown file to HTML, DOCX, and PDF using a shared CSS stylesheet for consistent styling across all three formats.

## Dependencies

- [pandoc](https://pandoc.org/) — document converter, must be on PATH
- [WeasyPrint](https://weasyprint.org/) — PDF renderer, must be on PATH

## Installation

Place both files in a folder that is on your PATH (e.g. `C:\Users\you\bin\`):

```shell
convertmd.bat
convertmd.css
```

## Usage

```shell
convertmd "My document.md"
```

Run from any folder containing the `.md` file. The three output files are written to the same folder as the input:

```shell
My document.html
My document.docx
My document.pdf
```

## Supported Markdown elements

- Headings (`#`, `##`, `###`, `####`)
- **Bold** and *italic*
- Fenced code blocks with syntax highlighting (tango theme) and inline code
- Bullet lists and numbered lists
- Links and images

## Styling (convertmd.css)

The CSS file drives the appearance of both the HTML and PDF outputs. It uses a blue/slate colour scheme:

- Body font: Segoe UI / Calibri / Arial
- Headings: dark blue (`#1a365d`), with a rule line under `h1` and `h2`
- Inline code: red-on-grey (`#c53030` on `#edf2f7`)
- Code blocks: light grey background (`#f8f8f8`) with a border, monospace font
- Links: blue (`#3182ce`)
- PDF page margins: 2 cm top/bottom, 2.5 cm left/right (via CSS `@page`)
- Orphan headings: `page-break-after: avoid` prevents headings from being stranded at the bottom of a page

To change the colour scheme or typography, edit `convertmd.css`. The DOCX output is not styled by the CSS — it uses pandoc's default DOCX template.

## Notes

**Filenames with diacritics** — `cmd.exe` mangles non-ASCII characters when passing filenames to external tools. The script works around this by copying the input to a temporary ASCII-named file (`convtmp_XXXX.md`), running all conversions against that copy, then renaming the outputs back to the original filename. The temp file is deleted on completion or on any error.

**WeasyPrint CSS path** — WeasyPrint requires the stylesheet to be passed as a `file:///` URI rather than a Windows path. The script builds this URI automatically from `%~dp0` (the script's own directory), so `convertmd.css` must always sit in the same folder as `convertmd.bat`.

**DOCX styling** — the CSS does not apply to DOCX output. If you need consistent DOCX styling, provide a reference document via `--reference-doc` in the pandoc DOCX step.
