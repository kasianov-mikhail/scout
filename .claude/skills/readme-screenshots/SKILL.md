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

1. Frame every screen and theme into `$WORK/framed/<screen>-<theme>.png`.
   - Use any image tool. Follow the frame specification above.
   - Scale the original to 960 px wide with high-quality interpolation, in sRGB.
   - Clip to the rounded rectangle, then draw the border inside the image.
2. Compress each file into `$WORK/out` with `pngquant --quality 85-100 --speed 1 --strip --force --output <out> <in>`.
   - The 8-bit palette keeps the alpha of the rounded corners.
   - Each file is about 60–100 KB, down from about 300 KB.
3. Look at the result on a white page and on a `#0d1117` page before the upload.
4. Ask the user to drop the files from `$WORK/out` into a comment on the PR. GitHub gives each file a `user-attachments` URL.
5. Compare each URL with its local file: `curl -sL -o dl.png <url>` and `cmp dl.png $WORK/out/<name>.png`. Use only URLs that match.
6. Put the URLs in the README, and keep the layout below.
7. Open the README at the commit hash, not at the branch, and measure the gaps in a 1400 px wide window. GitHub caches the branch page.

## Logo

The logo at the top of the README uses the same frame. Make the PNGs by hand or with any image tool.

| Property | Value |
|---|---|
| Source | The light logo, 2742 × 914, opaque white. It has an old gray border 1 px from each edge. Cut 6 px from every edge to remove it. |
| Width | 3096 px, height from the aspect ratio (3096 × 1023). That is 4 px per CSS px for a 774 px display width, the README content width on a file page. The border is 1 CSS px at that width and scales with the column. |
| Corner radius and border | As in the frame specification: 24 px radius, 4 px border inside the image, same colors per theme. |
| Dark background | `#0d1117` |
| Dark text color | `#e6edf3`, instead of the light-theme navy `#0e2a39`. |
| Dark mark color | `#3872f0`, the same blue as in the light theme. |

Recolor the dark version by coverage, not by a color swap. Each pixel is white mixed with one ink, so mix the same share of that ink into the dark background. This keeps the anti-aliased edges free of white halos.

- Compress with `pngquant`, as for the screenshots.
- In the README, use a `<picture>` with the dark `<source>` and the light `<img width="100%">`. The logo then fills the content width at any README column width, so the left and right padding stay equal.
- Put the `<picture>` in its own `<p>`. A bare image at the top of the README gets no paragraph margin, so the badges would sit right under it. The `<p>` gives the standard 16 px margin.

## README layout

- Each row of three is its own `<p>`. Put the three `<picture>` elements on one line, with no whitespace between them, joined by `&emsp;&emsp;`.
- The gap is 2 em, about 31 px at the 16 px README font. It equals the 32 px padding between the README box border and the first picture, so the space is the same on every side. Measure that padding again if GitHub changes it.
- Every `<img>` has `width="240"`.
- Three pictures and two gaps take about 784 px. The README column is 838 px, so they fit. A narrower view wraps the third picture.
- The vertical gap is the paragraph margin, 16 px, plus about 6 px under an inline image. It cannot be changed without CSS.

## If a step fails

- `pngquant` is missing: install it with `brew install pngquant`.
- A downloaded file differs from the local one: re-read the URL from the screenshot of the comment, or ask the user to copy it as text. Do not use the URL.
- The rendered page still shows the old pictures: open the README at the commit hash.

## Final report

- The files that were framed, and their sizes.
- Whether every uploaded URL matched its local file.
- The measured gap between the pictures.
