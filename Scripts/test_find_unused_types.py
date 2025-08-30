#!/usr/bin/env python3
"""
Test the find_unused_types.py script to ensure it works correctly.
"""

import os
import sys
import tempfile
import subprocess
from pathlib import Path

def create_test_swift_files():
    """Create a temporary directory with test Swift files."""
    temp_dir = tempfile.mkdtemp()
    sources_dir = os.path.join(temp_dir, "Sources", "TestModule")
    os.makedirs(sources_dir, exist_ok=True)
    
    # Create a used type
    used_type_content = '''
// Used.swift
struct UsedType {
    let value: String
}
'''
    
    # Create an unused type
    unused_type_content = '''
// Unused.swift
struct UnusedType {
    let value: String
}
'''
    
    # Create a file that uses UsedType
    using_content = '''
// Using.swift
class UsingClass {
    let instance: UsedType
    
    init() {
        instance = UsedType(value: "test")
    }
}
'''
    
    with open(os.path.join(sources_dir, "Used.swift"), 'w') as f:
        f.write(used_type_content)
    
    with open(os.path.join(sources_dir, "Unused.swift"), 'w') as f:
        f.write(unused_type_content)
    
    with open(os.path.join(sources_dir, "Using.swift"), 'w') as f:
        f.write(using_content)
    
    return temp_dir

def test_script():
    """Test the find_unused_types.py script."""
    # Create test files
    test_dir = create_test_swift_files()
    
    try:
        # Get the script path
        script_dir = os.path.dirname(os.path.abspath(__file__))
        script_path = os.path.join(script_dir, "find_unused_types.py")
        
        # Copy the script to the test directory temporarily
        import shutil
        test_script_path = os.path.join(test_dir, "Scripts", "find_unused_types.py")
        os.makedirs(os.path.dirname(test_script_path), exist_ok=True)
        shutil.copy2(script_path, test_script_path)
        
        # Run the script
        result = subprocess.run(
            [sys.executable, test_script_path],
            cwd=test_dir,
            capture_output=True,
            text=True
        )
        
        # Check the output
        output = result.stdout
        
        # The script should find UnusedType as unused
        assert "UnusedType" in output, f"UnusedType not found in output: {output}"
        assert "COMPLETELY UNUSED TYPES" in output, f"No unused types section found: {output}"
        
        # UsingClass should also be unused since it's not referenced anywhere
        assert "UsingClass" in output, f"UsingClass not found in output: {output}"
        
        # The script should exit with code 1 (unused types found)
        assert result.returncode == 1, f"Expected exit code 1, got {result.returncode}"
        
        print("✅ Test passed! Script correctly identifies unused types.")
        return True
        
    except Exception as e:
        print(f"❌ Test failed: {e}")
        return False
    
    finally:
        # Clean up
        import shutil
        shutil.rmtree(test_dir)

if __name__ == "__main__":
    success = test_script()
    sys.exit(0 if success else 1)