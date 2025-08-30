# Find Unused Types Script

This directory contains a Python script to analyze the Scout Swift codebase and identify unused types.

## Overview

The `find_unused_types.py` script performs static analysis on Swift source files to:

1. **Find completely unused types** - Types that are defined but never referenced anywhere
2. **Identify potentially unused types** - Types with very low usage that might be candidates for removal

## Usage

### Basic Analysis (Sources only)
```bash
python3 Scripts/find_unused_types.py
```

### Include Test Files
```bash
python3 Scripts/find_unused_types.py --include-tests
```

### Verbose Output (show potentially unused types)
```bash
python3 Scripts/find_unused_types.py --verbose
```

### All Options
```bash
python3 Scripts/find_unused_types.py --include-tests --verbose
```

## Output

The script generates a report showing:

- **Files analyzed**: Total number of Swift files processed
- **Types defined**: Total number of type definitions found
- **Types referenced**: Total number of type references found
- **Completely unused types**: Types with zero references
- **Potentially unused types**: Types with very low usage (verbose mode only)

## Current Results

As of the last analysis, the Scout codebase has:

### Completely Unused Types (2):
- **Row** (`Sources/Scout/UI/Controls/Row.swift:10`)
- **SyncableError** (`Sources/Scout/Core/Sync/Syncable.swift:22`)

### Analysis Details

#### Row struct
- Generic SwiftUI view wrapper for navigation
- Defined but never instantiated
- Appears to be leftover from refactoring

#### SyncableError enum
- Error type for sync operations
- Defined but never thrown or caught
- May indicate missing error handling

## Recommendations

1. **Review Row struct**: Determine if this is dead code that can be removed or if it should be used somewhere
2. **Review SyncableError**: Check if error handling is missing or if this error type is no longer needed
3. **Consider the potentially unused types**: Run with `--verbose` to see types with low usage that might also be candidates for cleanup

## How It Works

The script uses regular expressions to:

1. **Find type definitions**: Searches for `class`, `struct`, `enum`, `protocol`, and `typealias` declarations
2. **Find type usage**: Searches for various patterns where types are referenced:
   - Variable declarations (`var name: Type`)
   - Function parameters and return types
   - Type annotations (`as Type`, `is Type`)
   - Initializers (`Type()`)
   - Static member access (`Type.member`)
   - Inheritance and protocol conformance
   - Error handling patterns
   - Test expectations

## Limitations

- **Static analysis only**: Cannot detect dynamic usage through reflection or string-based instantiation
- **Pattern matching**: May miss some complex usage patterns
- **Test classes**: Test classes appear as "unused" when `--include-tests` is used because they're discovered by the test framework
- **Build-time usage**: Cannot detect usage in build scripts, code generation, or external tools

## Testing

Run the test suite to verify the script works correctly:

```bash
python3 Scripts/test_find_unused_types.py
```

## Integration

This script can be integrated into CI/CD pipelines:

- **Exit code 0**: No unused types found
- **Exit code 1**: Unused types found (can fail builds)

Example CI usage:
```bash
# Fail build if unused types are found
python3 Scripts/find_unused_types.py || (echo "Unused types found! Please review." && exit 1)
```