param(
  [Parameter(Mandatory = $true)]
  [string]$InputFile,

  [Parameter(Mandatory = $true)]
  [string]$OutputFile,

  [int]$YearShift = -20,
  [double]$AmountScale = 0.41
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

Add-Type -AssemblyName Microsoft.VisualBasic

function Unquote([string]$s) {
  if ($null -eq $s) { return "" }
  if ($s.Length -ge 2 -and $s.StartsWith('"') -and $s.EndsWith('"')) {
    return $s.Substring(1, $s.Length - 2)
  }
  return $s
}

function Quote([string]$s) {
  return '"' + $s.Replace('"', '""') + '"'
}

function Split-CsvLine([string]$line) {
  $sr = New-Object System.IO.StringReader($line)
  $parser = New-Object Microsoft.VisualBasic.FileIO.TextFieldParser($sr)
  $parser.TextFieldType = [Microsoft.VisualBasic.FileIO.FieldType]::Delimited
  $parser.SetDelimiters(',')
  $parser.HasFieldsEnclosedInQuotes = $true
  $fields = $parser.ReadFields()
  $parser.Close()
  return ,$fields
}

function Shift-DateToken([string]$token, [int]$yearShift) {
  if ($token -match '^(\d{4})\D(\d{2})\D(\d{2})\D?$') {
    $origYear = [int]$Matches[1]
    if ($origYear -lt 2000) {
      return $token
    }

    $y = $origYear + $yearShift
    return ("{0}/{1}/{2}" -f $y.ToString("0000"), $Matches[2], $Matches[3])
  }
  return $token
}

function Scale-NumberText([string]$text, [double]$scale) {
  if (-not ($text -match '^[+-]?\d+$')) {
    return $text
  }

  $n = [int]$text
  $scaled = [int][math]::Round($n * $scale, 0, [System.MidpointRounding]::AwayFromZero)

  if ($text.StartsWith('+') -and $scaled -ge 0) {
    return "+$scaled"
  }

  return [string]$scaled
}

$codeMap = @{}
$nameMap = @{}
$nextCode = 7001
$nextName = 1

function Map-Code([string]$code) {
  $k = $code.Trim()
  if ([string]::IsNullOrWhiteSpace($k)) {
    return $code
  }

  if (-not $script:codeMap.ContainsKey($k)) {
    $script:codeMap[$k] = ("{0}     " -f $script:nextCode)
    $script:nextCode++
  }

  return $script:codeMap[$k]
}

function Map-Name([string]$name) {
  $k = $name.Trim()
  if ([string]::IsNullOrWhiteSpace($k)) {
    return $name
  }

  if (-not $script:nameMap.ContainsKey($k)) {
    $script:nameMap[$k] = ("SAMPLE_STOCK_{0}" -f $script:nextName.ToString("000"))
    $script:nextName++
  }

  return $script:nameMap[$k]
}

$lines = Get-Content -Path $InputFile
$out = New-Object System.Collections.Generic.List[string]
$prevLabel = $false

foreach ($line in $lines) {
  if ($prevLabel -and $line -match '^[+-]?\d+$') {
    $out.Add((Scale-NumberText -text $line -scale $AmountScale))
    $prevLabel = $false
    continue
  }

  if ($line.Contains(',')) {
    $fields = Split-CsvLine -line $line

    for ($i = 0; $i -lt $fields.Count; $i++) {
      $fields[$i] = Shift-DateToken -token (Unquote $fields[$i]) -yearShift $YearShift
    }

    if ($fields.Count -ge 12) {
      $isDetail = ($fields[3] -match '^\d{4}/\d{2}/\d{2}$' -or $fields[6] -match '^\d{4}/\d{2}/\d{2}$')

      if ($fields[0] -match '^\d{4}\s*$') {
        $fields[0] = Map-Code -code $fields[0]
      }

      if ($isDetail -and -not [string]::IsNullOrWhiteSpace($fields[1])) {
        $fields[1] = Map-Name -name $fields[1]
      }

      foreach ($idx in 7,8,10,11,12) {
        if ($idx -lt $fields.Count) {
          $fields[$idx] = Scale-NumberText -text $fields[$idx] -scale $AmountScale
        }
      }
    }

    $out.Add(($fields | ForEach-Object { Quote $_ }) -join ',')
    $prevLabel = $false
    continue
  }

  $out.Add($line)
  $prevLabel = (-not [string]::IsNullOrWhiteSpace($line) -and -not ($line -match '^[+-]?\d+$'))
}

Set-Content -Path $OutputFile -Value $out -Encoding utf8
Write-Output ("Sample generated: {0} -> {1} ({2} lines)" -f $InputFile, $OutputFile, $out.Count)
