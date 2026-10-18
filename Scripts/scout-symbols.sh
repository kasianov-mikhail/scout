#!/bin/sh
#
# Copyright 2026 Mikhail Kasianov
#
# Use of this source code is governed by an MIT-style
# license that can be found in the LICENSE file or at
# https://opensource.org/licenses/MIT.
#
# Xcode Run Script phase: converts the target's dSYM into scout.scoutsym
# inside the app bundle, so Scout can symbolicate this build's crashes.

set -eu

if [ "${DEBUG_INFORMATION_FORMAT:-}" != "dwarf-with-dsym" ]; then
    echo "note: Scout symbols skipped because DEBUG_INFORMATION_FORMAT is not dwarf-with-dsym."
    exit 0
fi

package="$(cd "$(dirname "$0")/.." && pwd)"
dwarf="${DWARF_DSYM_FOLDER_PATH}/${DWARF_DSYM_FILE_NAME}/Contents/Resources/DWARF/${EXECUTABLE_NAME}"
output="${TARGET_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/scout.scoutsym"
scratch="${OBJROOT}/ScoutSymbols"

env -i \
    PATH="/usr/bin:/bin:/usr/sbin:/sbin" \
    HOME="${HOME}" \
    TMPDIR="${TMPDIR:-/tmp}" \
    DEVELOPER_DIR="${DEVELOPER_DIR:-$(xcode-select -p)}" \
    xcrun --sdk macosx swift build \
    --configuration release \
    --package-path "${package}" \
    --product scout-symbols \
    --scratch-path "${scratch}"

"${scratch}/release/scout-symbols" convert "${dwarf}" --output "${output}"
