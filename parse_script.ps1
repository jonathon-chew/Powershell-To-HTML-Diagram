$filePath = "./script.ps1"

# Read the content of the file
$fileContent = Get-Content -Path $filePath -Raw

$lineNumber = 1

$lineCount = ($fileContent -split '\n').Count -1
Write-Host "Line count: $lineCount`n"
$previousLineIndent = 0
$openingLine = ""

foreach($line in $fileContent -split '\n'){
  # Count the number of tab characters
  $tabCount = ($line -split "  ").Count - 1
  if($tabCount -gt $previousLineIndent){
    $openingLine = $line
    $previousLineIndent = $tabCount
  } elseif ($tabCount -lt $previousLineIndent){

    $previousLineIndent = $tabCount
  }
  if($tabCount -ge 1){
    # Output the count
    Write-Output "Number of tab characters: $tabCount `non line: $lineNumber`nwhose contents is: $(($line -Replace "  ", '').Substring(0, [Math]::Min($string.Length, 20))) `nit is a child of $($openingLine -Replace '  ', '')`n`n"
  }
  $lineNumber++

}
