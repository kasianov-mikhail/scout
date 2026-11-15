---
name: docs-images
description: Frame, compress, upload, and lay out the images in the documentation files, such as the Scout README dashboard screenshots and logo — border, corner radius, divider colors, logo dark variant, spacing between pictures, and PNG compression. Use when images in the README or other documentation are re-exported, added, restyled, or their layout changes.
---

The README shows six dashboard screens in light only. Scout UI pins the light scheme with `.preferredColorScheme(.light)` in `HomeView`, so there is no dark variant to capture: each screen is a plain `<img>`, with no `prefers-color-scheme: dark` `<source>`. If the app stops pinning the light scheme, capture dark variants again and restore a `<picture>` per screen. The logo is the exception and keeps its dark `<picture>`. The PNGs are uploaded to GitHub (`user-attachments`) and are not stored in the repository.

GitHub strips `style` from README HTML. Bake the frame into each PNG, and never put the pictures in a table. A table adds a cell border and about 13 px of padding that shrink the screen.

## Variables

| Name | Meaning |
|---|---|
| `ORIGINALS` | Folder with the simulator screenshots, named `<screen>`. Keep it outside the repository. |
| `WORK` | Scratch folder for the framed files. |
| `SCREENS` | `home release crash metrics event timeline` |
| `DISPLAY_WIDTH` | Width of the picture in the README, in CSS px. 240 for a screenshot. 774 for the logo, the README content width on a file page. |
| `SCALE` | Pixels of the PNG per CSS px. 4. |
| `RADIUS` | GitHub box corner radius, in CSS px. 6. |
| `BORDER` | GitHub box border width, in CSS px. 1. |

## Frame specification

| Property | Value |
|---|---|
| Width | `DISPLAY_WIDTH × SCALE`. For a screenshot 960 px, with the height from the aspect ratio (960 × 2078 for a 780 × 1688 capture, 960 × 2087 for 1206 × 2622). |
| Corner radius | `RADIUS × SCALE`. 24 px. |
| Border | `BORDER × SCALE`, drawn inside the image. 4 px. |
| Border color, light | `#dfe4e9`, the muted divider below. |
| Border color, dark (logo only) | `#2f353d`, the muted divider below. |
| Shadow and margin | None. No transparent margin around the image. |
| Color space | sRGB, high-quality interpolation. |

The border colors are the GitHub Primer muted divider (`borderColor-muted`), drawn opaque: `#d1d9e0` at 70 % over white, and `#3d444d` at 70 % over `#0d1117`. The default border color, `#d1d9e0` and `#3d444d`, looked heavier than the dividers under the README headings.

## Before framing

- Confirm the final screen set with the user before framing. It changes between refreshes.
- Copy every source into `$ORIGINALS` as soon as the user provides it. Files in Downloads or Desktop move and disappear.
- Confirm that every screen exists in `origin/HEAD`. A screen from an unmerged branch makes the README show UI that the release does not have.
- Crop every screen to one height, top-aligned, so every frame has the same aspect ratio. Use the device screen, for example 780 × 1688 for a 2× capture. Scroll captures are taller and need the same crop.
- When a capture is taller than the screen by only a few pixels and a bottom crop would cut a row, trim that overflow from the blank area under the status bar instead.

## Steps

1. Frame every screen into `$WORK/framed/<screen>.png`.
   - Use any image tool. Follow the frame specification above.
   - Scale the original to `DISPLAY_WIDTH × SCALE` px wide with high-quality interpolation, in sRGB.
   - Clip to the rounded rectangle, then draw the border inside the image.
2. Compress each file into `$WORK/out` with `pngquant --quality 85-100 --speed 1 --strip --force --output <out> <in>`.
   - The 8-bit palette keeps the alpha of the rounded corners.
   - Each file is about 80–120 KB, down from about 150–310 KB.
3. Look at the result on a white page and on a `#0d1117` page before the upload.
4. Create a new draft PR for this refresh before the uploads. Reuse an open draft PR only; never reuse a merged PR.
   - When the working tree has no change yet, start the branch with an empty commit so the draft PR exists. The README commit follows after the uploads.
   - Upload the files from `$WORK/out` with `gh pr comment <PR> --attach '<file>#<Alt>'`, one `--attach` per file. Run `gh` inside the repository; from any other directory it exits with `fatal: not a git repository`.
   - GitHub stores each file as a `user-attachments` URL and writes the markdown image into the comment. Read the comment back with `gh api repos/<owner>/<repo>/issues/comments/<id> --jq .body` and take the URLs from there, not from the rendered page.
5. Download every URL with `curl -sL -o dl.png <url>`. Match each file to its screen by content, not by the upload order. Run `cmp dl.png $WORK/out/<name>.png` and use only URLs that match.
6. Put the URLs in the README, and keep the layout below.
   - After the URLs are in place, hide the comment with the images. Hiding keeps the attachments working; deleting the comment may break them. Take the comment's `node_id` from the same `gh api` call and run:
     `gh api graphql -f query='mutation { minimizeComment(input: {subjectId: "<node_id>", classifier: OUTDATED}) { minimizedComment { isMinimized } } }'`
7. Commit and push the README change.
   - Mark the PR ready for review once the uploaded URLs are checked. Do not wait for a separate request.
8. Open the README at the commit hash, not at the branch, and measure the gaps in a 1400 px wide window. GitHub caches the branch page.

## Logo

The logo at the top of the README uses the same frame. Make the PNGs by hand or with any image tool.

| Property | Value |
|---|---|
| Source | The light logo, 2742 × 914, opaque white. It has an old gray border 1 px from each edge. Cut 6 px from every edge to remove it. |
| Width | `DISPLAY_WIDTH × SCALE`, with `DISPLAY_WIDTH` 774. That is 3096 px, and the height from the aspect ratio is 1023 px. |
| Corner radius and border | As in the frame specification, from `RADIUS` and `BORDER`. The border scales with the column, because the image has `width="100%"`. |
| Dark background | `#0d1117` |
| Dark text color | `#e6edf3`, instead of the light-theme navy `#0e2a39`. |
| Dark mark color | `#3872f0`, the same blue as in the light theme. |

Recolor the dark version by coverage, not by a color swap. Each pixel is white mixed with one ink, so mix the same share of that ink into the dark background. This keeps the anti-aliased edges free of white halos.

- Compress with `pngquant`, as for the screenshots.
- In the README, use a `<picture>` with the dark `<source>` and the light `<img width="100%">`. The logo then fills the content width at any README column width, so the left and right padding stay equal.
- Put the `<picture>` in its own `<p>`. A bare image at the top of the README gets no paragraph margin, so the badges would sit right under it. The `<p>` gives the standard 16 px margin.

## README layout

- Each row of three is its own `<p>`. Put the three screenshots on one line, with no whitespace between them, joined by `&emsp;&emsp;`.
- Each screenshot is a plain `<img width="240" alt="<Screen>" src="…">`; it has no `<picture>` and no dark source.
- The gap is 2 em, about 31 px at the 16 px README font. It equals the 32 px padding between the README box border and the first picture, so the space is the same on every side. Measure that padding again if GitHub changes it.
- Every `<img>` has `width` equal to `DISPLAY_WIDTH`, which is `240`.
- Three screenshots and two gaps take about 784 px. The README column is 838 px, so they fit. A narrower view wraps the third picture.
- The vertical gap is the paragraph margin, 16 px, plus about 6 px under an inline image. It cannot be changed without CSS.

## If a step fails

- `pngquant` is missing: install it with `brew install pngquant`.
- `gh pr comment --attach` says `failed to run git`: run it from inside the repository.
- A downloaded file differs from the local one: check that you paired the right screen. When the pairing is right, re-read the URL from the comment body, or ask the user to copy it as text. Do not use the URL.
- The rendered page still shows the old pictures: open the README at the commit hash.

## Final report

- The files that were framed, and their sizes.
- Whether every uploaded URL matched its local file.
- The measured gap between the pictures.
