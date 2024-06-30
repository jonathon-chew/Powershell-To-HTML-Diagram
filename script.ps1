# This is an example of a comment 
<#
No example here
.SYNOPSIS
.DESCRIPTION
  A longer description of the function, its purpose, common use cases, etc.
.NOTES
  Information or caveats about the function e.g. 'This function is not supported in Linux'
.LINK
  Specify a URI to a help page, this will show when Get-Help -Online is used.
.EXAMPLE
  Test-MyTestFunction -Verbose
  Explanation of the function or its result. You can include multiple examples with additional .EXAMPLE lines
#>
function ExampleFunction ($firstInput, $secondInput){
    Write-Host "This is an example of a piece of work"
    if($condition){
      $assign_a_varibale_here = "Another example"
    }
    return $assign_a_variable_here
}

while($true){
  $getReturn = ExampleFunction $firstInput $secondInput
}
