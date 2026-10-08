#!/usr/bin/env bash
# Usage: frame-all.sh <originals-dir> <work-dir>
# Builds frame.swift, frames every screen in both themes, and compresses the results into <work-dir>/out.
set -euo pipefail

if [[ $# -ne 2 ]]; then
    echo "usage: frame-all.sh <originals-dir> <work-dir>" >&2
    exit 64
fi

originals=$1
work=$2
here=$(cd "$(dirname "$0")" && pwd)
screens=(home event retention crash metric_distribution release_health)

command -v pngquant >/dev/null || { echo "pngquant is missing: brew install pngquant" >&2; exit 1; }

mkdir -p "$work/framed" "$work/out"
swiftc -O "$here/frame.swift" -o "$work/frame"

for screen in "${screens[@]}"; do
    for theme in light dark; do
        name=$screen-$theme
        input=$originals/$name
        [[ -f $input ]] || input=$input.png
        [[ -f $input ]] || { echo "missing original: $originals/$name" >&2; exit 1; }

        "$work/frame" "$input" "$work/framed/$name.png" "$theme"
        pngquant --quality 85-100 --speed 1 --strip --force --output "$work/out/$name.png" "$work/framed/$name.png"
    done
done

ls -l "$work/out"
