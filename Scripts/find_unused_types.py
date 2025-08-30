#!/usr/bin/env python3
"""
Find unused types in the Scout Swift codebase.

This script analyzes all Swift files to identify:
1. Completely unused types (defined but never referenced)
2. Potentially unused types (very low usage, only used locally)

Usage:
    python3 Scripts/find_unused_types.py [--include-tests] [--verbose]
"""

import os
import re
import sys
import argparse
from collections import defaultdict
from typing import Dict, List, Set, Tuple

class SwiftTypeAnalyzer:
    def __init__(self, project_root: str, include_tests: bool = False, verbose: bool = False):
        self.project_root = project_root
        self.include_tests = include_tests
        self.verbose = verbose
        self.types_defined: Dict[str, List[Tuple[str, int]]] = defaultdict(list)
        self.types_used: Dict[str, List[Tuple[str, int]]] = defaultdict(list)
        self.swift_files: List[str] = []
        
    def find_swift_files(self) -> List[str]:
        """Find all Swift files in the project."""
        swift_files = []
        
        # Always include Sources
        sources_dir = os.path.join(self.project_root, "Sources")
        if os.path.exists(sources_dir):
            for root, dirs, files in os.walk(sources_dir):
                for file in files:
                    if file.endswith('.swift'):
                        swift_files.append(os.path.join(root, file))
        
        # Optionally include Tests
        if self.include_tests:
            tests_dir = os.path.join(self.project_root, "Tests")
            if os.path.exists(tests_dir):
                for root, dirs, files in os.walk(tests_dir):
                    for file in files:
                        if file.endswith('.swift'):
                            swift_files.append(os.path.join(root, file))
        
        return sorted(swift_files)
    
    def extract_type_definitions(self, file_path: str, content: str) -> List[Tuple[str, int]]:
        """Extract type definitions from a Swift file."""
        type_defs = []
        lines = content.split('\n')
        
        # Patterns for different type definitions
        patterns = [
            # class definitions
            r'^\s*(?:public\s+|private\s+|internal\s+|fileprivate\s+|open\s+)?(?:final\s+)?class\s+(\w+)',
            # struct definitions  
            r'^\s*(?:public\s+|private\s+|internal\s+|fileprivate\s+)?struct\s+(\w+)',
            # enum definitions
            r'^\s*(?:public\s+|private\s+|internal\s+|fileprivate\s+)?enum\s+(\w+)',
            # protocol definitions
            r'^\s*(?:public\s+|private\s+|internal\s+|fileprivate\s+)?protocol\s+(\w+)',
            # typealias definitions
            r'^\s*(?:public\s+|private\s+|internal\s+|fileprivate\s+)?typealias\s+(\w+)',
        ]
        
        for line_num, line in enumerate(lines, 1):
            # Skip comments
            if line.strip().startswith('//') or line.strip().startswith('*'):
                continue
                
            for pattern in patterns:
                match = re.search(pattern, line)
                if match:
                    type_name = match.group(1)
                    # Skip generic type parameters and private names
                    if len(type_name) > 1 and not type_name.startswith('_'):
                        type_defs.append((type_name, line_num))
                        
        return type_defs
    
    def extract_type_usage(self, file_path: str, content: str) -> List[Tuple[str, int]]:
        """Extract type usage from a Swift file."""
        type_usage = []
        lines = content.split('\n')
        
        # Comprehensive patterns for type usage
        usage_patterns = [
            # Variable/property declarations: var/let name: Type
            r'(?:var|let)\s+\w+:\s*(\w+)',
            # Function parameters: func name(param: Type)
            r'func\s+\w+\([^)]*:\s*(\w+)',
            # Function return types: func name() -> Type
            r'func\s+\w+\([^)]*\)\s*(?:async\s+)?(?:throws\s*(?:\([^)]*\))?)?->\s*(\w+)',
            # Throwing specific errors: throws(Type)
            r'throws\s*\(\s*(\w+)',
            # Type annotations: as Type, is Type
            r'(?:as|is)\s+(\w+)',
            # Type initializers: Type()
            r'(\w+)\s*\(',
            # Static/class member access: Type.member
            r'(\w+)\.',
            # Generic constraints: where T: Type
            r'where\s+\w+:\s*(\w+)',
            # Inheritance and protocol conformance: : Type
            r':\s*(\w+)',
            # Property wrappers and attributes: @Type
            r'@(\w+)',
            # Enum cases with associated values: case name(Type)
            r'case\s+\w+\(\s*(\w+)',
            # Error handling: catch Type
            r'catch\s+(\w+)',
            # Test expectations: #expect(throws: Type)
            r'#expect\s*\(\s*throws:\s*(\w+)',
            # Switch cases: case Type.value or case .value
            r'case\s+(?:\.)?(\w+)',
            # Guard cases: guard case Type.value
            r'guard\s+case\s+(?:\.)?(\w+)',
            # Extension declarations: extension Type
            r'extension\s+(\w+)',
        ]
        
        for line_num, line in enumerate(lines, 1):
            # Skip comments
            if line.strip().startswith('//') or line.strip().startswith('*'):
                continue
            
            # Remove string literals to avoid false positives
            cleaned_line = re.sub(r'"[^"]*"', '""', line)
            cleaned_line = re.sub(r"'[^']*'", "''", cleaned_line)
            
            for pattern in usage_patterns:
                matches = re.finditer(pattern, cleaned_line)
                for match in matches:
                    type_name = match.group(1)
                    # Filter out obvious non-types
                    if (len(type_name) > 1 and 
                        type_name not in {'if', 'in', 'is', 'as', 'do', 'or', 'to', 'at', 'by', 'me', 'we', 'he', 'it', 'id', 'up', 'Set', 'get', 'set'} and
                        not type_name.startswith('_') and
                        type_name[0].isupper()):  # Types typically start with uppercase
                        type_usage.append((type_name, line_num))
                        
        return type_usage
    
    def analyze_files(self):
        """Analyze all Swift files for type definitions and usage."""
        self.swift_files = self.find_swift_files()
        
        if self.verbose:
            print(f"Analyzing {len(self.swift_files)} Swift files...")
        
        for file_path in self.swift_files:
            try:
                with open(file_path, 'r', encoding='utf-8') as f:
                    content = f.read()
                
                # Extract type definitions
                type_defs = self.extract_type_definitions(file_path, content)
                for type_name, line_num in type_defs:
                    self.types_defined[type_name].append((file_path, line_num))
                
                # Extract type usage
                type_usages = self.extract_type_usage(file_path, content)
                for type_name, line_num in type_usages:
                    self.types_used[type_name].append((file_path, line_num))
                    
            except Exception as e:
                if self.verbose:
                    print(f"Error analyzing {file_path}: {e}")
    
    def find_unused_types(self) -> Tuple[List[str], List[str]]:
        """Find unused and potentially unused types."""
        completely_unused = []
        potentially_unused = []
        
        for type_name, definitions in self.types_defined.items():
            usage_count = len(self.types_used.get(type_name, []))
            
            if usage_count == 0:
                completely_unused.append(type_name)
            elif usage_count <= 3:
                # Check if only used locally
                def_files = {def_file for def_file, _ in definitions}
                usage_files = {use_file for use_file, _ in self.types_used[type_name]}
                
                if usage_files.issubset(def_files):
                    potentially_unused.append(f"{type_name} (local usage: {usage_count})")
                elif usage_count <= 2:
                    potentially_unused.append(f"{type_name} (low usage: {usage_count})")
        
        return sorted(completely_unused), sorted(potentially_unused)
    
    def get_relative_path(self, file_path: str) -> str:
        """Get relative path from project root."""
        return os.path.relpath(file_path, self.project_root)
    
    def generate_report(self) -> str:
        """Generate a summary report."""
        completely_unused, potentially_unused = self.find_unused_types()
        
        report = []
        report.append("Scout Unused Types Analysis")
        report.append("=" * 30)
        report.append(f"Files analyzed: {len(self.swift_files)}")
        report.append(f"Types defined: {len(self.types_defined)}")
        report.append(f"Types referenced: {len(self.types_used)}")
        report.append("")
        
        if completely_unused:
            report.append(f"COMPLETELY UNUSED TYPES ({len(completely_unused)}):")
            report.append("-" * 40)
            for type_name in completely_unused:
                report.append(f"• {type_name}")
                for def_file, line_num in self.types_defined[type_name]:
                    rel_path = self.get_relative_path(def_file)
                    report.append(f"  -> {rel_path}:{line_num}")
            report.append("")
        else:
            report.append("✅ No completely unused types found!")
            report.append("")
        
        if self.verbose and potentially_unused:
            report.append(f"POTENTIALLY UNUSED TYPES ({len(potentially_unused)}):")
            report.append("-" * 40)
            for type_info in potentially_unused[:10]:  # Show first 10
                type_name = type_info.split(" (")[0]
                report.append(f"• {type_info}")
                for def_file, line_num in self.types_defined[type_name]:
                    rel_path = self.get_relative_path(def_file)
                    report.append(f"  -> {rel_path}:{line_num}")
            if len(potentially_unused) > 10:
                report.append(f"  ... and {len(potentially_unused) - 10} more")
            report.append("")
        
        return "\n".join(report)


def main():
    parser = argparse.ArgumentParser(description="Find unused types in Swift codebase")
    parser.add_argument("--include-tests", action="store_true", 
                       help="Include test files in analysis")
    parser.add_argument("--verbose", "-v", action="store_true",
                       help="Show detailed output including potentially unused types")
    
    args = parser.parse_args()
    
    # Assume script is run from project root or Scripts directory
    project_root = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
    if not os.path.exists(os.path.join(project_root, "Sources")):
        project_root = os.path.dirname(project_root)
    
    if not os.path.exists(os.path.join(project_root, "Sources")):
        print("Error: Could not find Sources directory. Run from project root.")
        sys.exit(1)
    
    analyzer = SwiftTypeAnalyzer(project_root, args.include_tests, args.verbose)
    analyzer.analyze_files()
    
    report = analyzer.generate_report()
    print(report)
    
    # Exit with non-zero code if unused types are found
    unused, _ = analyzer.find_unused_types()
    if unused:
        sys.exit(1)


if __name__ == "__main__":
    main()