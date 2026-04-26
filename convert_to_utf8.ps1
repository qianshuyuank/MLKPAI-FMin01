# PowerShell Script to convert files to UTF-8 (BOM-less)
# Target extensions: .v, .sv, .vhd, .do, .tcl, .f, .py, .c, .h

$extensions = "*.v", "*.sv", "*.vhd", "*.do", "*.tcl", "*.f", "*.py", "*.c", "*.h"
$files = Get-ChildItem -Recurse -Include $extensions

foreach ($file in $files) {
    Write-Host "Converting: $($file.FullName)"
    
    # Read the file content
    # Note: Using -Encoding Default to capture common local encodings (like GBK)
    $content = Get-Content -Path $file.FullName -Encoding Default
    
    # Write back as UTF-8 without BOM
    # In PowerShell 5.1 (default on Win10), -Encoding utf8 adds a BOM.
    # In PowerShell Core (pwsh), it's BOM-less by default.
    # This approach works for both to ensure a clean UTF-8 string.
    [System.IO.File]::WriteAllLines($file.FullName, $content)
}

Write-Host "Done! All target files converted to UTF-8."
