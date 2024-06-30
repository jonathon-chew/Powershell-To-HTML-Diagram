param (
    [string]$inputScriptPath,
    [string]$outputHtmlPath
)

# Function to parse the script and build the logic tree
function Parse-Script {
    param (
        [string]$scriptContent
    )

    $lines = $scriptContent -split "\n"
    $indent = 0
    $tree = @()

    function Add-Node {
        param (
            [string]$type,
            [int]$indent,
            [string]$condition = $null
        )
        $node = [PSCustomObject]@{
            Type = $type
            Indent = $indent
            Condition = $condition
            Children = @()
        }
        return $node
    }

    for ($i = 0; $i -lt $lines.Length; $i++) {
        $line = $lines[$i].Trim()

        if ($line -match '^if\s*\((.+)\)') {
            $condition = $matches[1]
            $node = Add-Node -type 'if' -indent $indent -condition $condition
            $tree += $node
            $indent++
        } elseif ($line -match '^elseif\s*\((.+)\)') {
            $condition = $matches[1]
            $node = Add-Node -type 'elseif' -indent $indent -condition $condition
            $tree += $node
        } elseif ($line -match '^else\s*\{') {
            $node = Add-Node -type 'else' -indent $indent
            $tree += $node
        } elseif ($line -match '^for\s*\((.+)\)') {
            $condition = $matches[1]
            $node = Add-Node -type 'for' -indent $indent -condition $condition
            $tree += $node
            $indent++
        } elseif ($line -match '^while\s*\((.+)\)') {
            $condition = $matches[1]
            $node = Add-Node -type 'while' -indent $indent -condition $condition
            $tree += $node
            $indent++
        } elseif ($line -match '^\$(update_request|export_request)') {
            $node = Add-Node -type 'action' -indent $indent -condition $line
            $tree += $node
        } elseif ($line -match '^\}') {
            if ($indent -gt 0) {
                $indent--
            }
        }
    }

    return $tree
}

# Function to generate HTML from the logic tree
function Generate-HTML {
    param (
        [array]$tree
    )

    $html = @"
<!DOCTYPE html>
<html>
<head>
    <title>Script Logic Visualization</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            //display:flex;
            //align-items:center;
            justify-content:center;
        }
        #indent-top { margin-top: 50px }
        .indent-0 { margin-left: 0; }
        .indent-1 { margin-left: 20px; }
        .indent-2 { margin-left: 40px; }
        .indent-3 { margin-left: 60px; }
        .branch {
            //display: inline-block;
            margin-right: 20px;
            padding: 5px;
            border: 1px solid #000;
        }  
    </style>
</head>
<body>
"@

    foreach ($node in $tree) {
        $indentClass = "indent-$($node.Indent)"
        if ($node.Type -eq 'if') {
            $html += "<div id='indent-top' class='branch $indentClass'><strong>if ($($node.Condition))</strong></div>`n"
        } elseif ($node.Type -eq 'elseif') {
            $html += "<div id='indent-top' class='branch $indentClass'><strong>elseif ($($node.Condition))</strong></div>`n"
        } elseif ($node.Type -eq 'else') {
            $html += "<div id='indent-top' class='branch $indentClass'><strong>else</strong></div>`n"
        } elseif ($node.Type -eq 'for') {
            $html += "<div id='indent-top' class='branch $indentClass'><strong>for ($($node.Condition))</strong></div>`n"
        } elseif ($node.Type -eq 'while') {
            $html += "<div id='indent-top' class='branch $indentClass'><strong>while ($($node.Condition))</strong></div>`n"
        } elseif ($node.Type -eq 'action') {
            $html += "<div id='indent-top' class='branch $indentClass'>$($node.Condition)</div>`n"
        }
    }

    $html += @"
</body>
</html>
"@

    return $html
}

# Read the input script content
$scriptContent = Get-Content -Path $inputScriptPath -Raw

# Parse the script
$tree = Parse-Script -scriptContent $scriptContent

# Output the tree structure for debugging
Write-Output "Parsed Tree: " $tree | ForEach-Object { Write-Output $_ }

# Generate HTML from the parsed tree
$htmlContent = Generate-HTML -tree $tree

# Output the HTML to a file
Set-Content -Path $outputHtmlPath -Value $htmlContent

Write-Output "HTML file has been generated at: $outputHtmlPath"
