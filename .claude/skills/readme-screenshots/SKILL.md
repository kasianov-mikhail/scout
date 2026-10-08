---
name: readme-screenshots
description: Frame, compress, upload, and lay out the dashboard screenshots in the Scout README — border, corner radius, divider colors, spacing between pictures, and PNG compression. Use when the README screenshots are re-exported, added, restyled, or their layout changes.
---

The README shows six dashboard screens in light and dark. Each is a `<picture>` with a `prefers-color-scheme: dark` `<source>` and a light `<img>`. The PNGs are uploaded to GitHub (`user-attachments`) and are not stored in the repository.

GitHub strips `style` from README HTML. Bake the frame into each PNG, and never put the pictures in a table. A table adds a cell border and about 13 px of padding that shrink the screen.

## Variables

| Name | Meaning |
|---|---|
| `ORIGINALS` | Folder with the simulator screenshots, 1206 × 2622, named `<screen>-light` and `<screen>-dark`. Keep it outside the repository. |
| `WORK` | Scratch folder for the framed files. |
| `SCREENS` | `home event retention crash metric_distribution release_health` |
| `SKILL` | This folder, `.claude/skills/readme-screenshots`. |

## Frame specification

| Property | Value |
|---|---|
| Width | 960 px, height from the aspect ratio (960 × 2087). That is 4 px per CSS px for a 240 px display width. |
| Corner radius | 24 px, which is 6 CSS px, the GitHub box radius. |
| Border | 4 px, which is 1 CSS px, drawn inside the image. |
| Border color, light | `#dfe4e9` |
| Border color, dark | `#2f353d` |
| Shadow and margin | None. No transparent margin around the image. |
| Color space | sRGB, high-quality interpolation. |

The border colors are GitHub's muted divider, drawn opaque: `#d1d9e0` at 70 % over white, and `#3d444d` at 70 % over `#0d1117`. The default border color, `#d1d9e0` and `#3d444d`, looked heavier than the dividers under the README headings.

## Steps

1. Build the tool: `swiftc -O $SKILL/scripts/frame.swift -o $WORK/frame`.
2. Frame every screen and theme: `$WORK/frame $ORIGINALS/<screen>-<theme> $WORK/framed/<screen>-<theme>.png <theme>`. The theme is `light` or `dark`.
3. Compress each file: `pngquant --quality 85-100 --speed 1 --strip --force --output $WORK/out/<name>.png $WORK/framed/<name>.png`.
   - The 8-bit palette keeps the alpha of the rounded corners.
   - Each file is about 60–100 KB, down from about 300 KB.
4. Look at the result on a white page and on a `#0d1117` page before the upload.
5. Ask the user to drop the files from `$WORK/out` into a comment on the PR. GitHub gives each file a `user-attachments` URL.
6. Compare each URL with its local file: `curl -sL -o dl.png <url>` and `cmp dl.png $WORK/out/<name>.png`. Use only URLs that match.
7. Put the URLs in the README, and keep the layout below.
8. Open the README at the commit hash, not at the branch, and measure the gaps in a 1400 px wide window. GitHub caches the branch page.

## README layout

- Each row of three is its own `<p>`. Put the three `<picture>` elements on one line, with no whitespace between them, joined by `&emsp;&emsp;&ensp;`.
- The gap is 2.5 em, about 40 px at the 16 px README font. It is the same as the gap between the columns on the GitHub dashboard.
- Every `<img>` has `width="240"`.
- Three pictures and two gaps take 800 px. The README column is 838 px, so they fit. A narrower view wraps the third picture.
- The vertical gap is the paragraph margin, 16 px, plus about 6 px under an inline image. It cannot be changed without CSS.

## If a step fails

- `pngquant` is missing: install it with `brew install pngquant`.
- A downloaded file differs from the local one: re-read the URL from the screenshot of the comment, or ask the user to copy it as text. Do not use the URL.
- The rendered page still shows the old pictures: open the README at the commit hash.

## Final report

- The files that were framed, and their sizes.
- Whether every uploaded URL matched its local file.
- The measured gap between the pictures.
