//
// Copyright 2025 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

struct CellKeyParser {
    /// Parses a cell key in the format "cell_<part1>_<part2>"
    static func parse(key: String) -> (String, String) {
        let parts = key.components(separatedBy: "_")
        
        guard parts.count == 3 else {
            fatalError("Invalid key format")
        }
        
        return (parts[1], parts[2])
    }
    
    /// Creates a cell key from two components
    static func createKey(prefix: String, suffix: String) -> String {
        "cell_\(prefix)_\(suffix)"
    }
}