# Define the path to the JSON input file
$langDir = "path/to/lang"

# Your Google Translate API Key
$apiKey = ""

# JSON input file path (English language file)
$jsonInputPath = "$langDir/en.json"

# Define the array of allowed languages
$allowedLanguages = @("zh", "es", "hi", "ar", "bn", "pt", "ru", "ja", "pa")

# Show script information
Write-Host "`n============================================" -ForegroundColor Cyan
Write-Host "  Laravel Language File Translation Script "
Write-Host "============================================" -ForegroundColor Cyan
Write-Host "`nThis script translates an English JSON file (`en.json`) into multiple languages."
Write-Host "Make sure the Google Translate API key is correctly set."
Write-Host "`n"
Start-Sleep 0.8

# Validate paths before proceeding
if (-not (Test-Path -Path $langDir -PathType Container)) {
    Write-Host -ForegroundColor Red "[Error] Invalid Lang folder path: '$langDir'. Please check the directory and try again."
    exit
}

if (-not (Test-Path -Path $jsonInputPath -PathType Leaf)) {
    Write-Host -ForegroundColor Red "[Error] English JSON file not found at '$jsonInputPath'. Please check the file path and try again."
    exit
}

# Convert the PSObject to a hashtable
function ConvertTo-Hashtable {
    param (
        [PSObject]$psObject
    )
    $hashtable = @{}
    foreach ($property in $psObject.PSObject.Properties) {
        $hashtable[$property.Name] = $property.Value
    }
    return $hashtable
}

# Function to call Google Translate API
function TranslateText {
    param (
        [string]$text,
        [string]$targetLanguage
    )

    $url = "https://translation.googleapis.com/language/translate/v2?key=$apiKey"
    $body = @{
        q      = $text
        target = $targetLanguage
    }

    try {
        $response = Invoke-RestMethod -Uri $url -Method Post -Body ($body | ConvertTo-Json) -ContentType "application/json"
        return $response.data.translations[0].translatedText
    }
    catch {
        Write-Host -ForegroundColor Red "[Error] Failed to translate '$text' to '$targetLanguage': $_"
        return $null  # Return null if translation fails
    }
}


# Read the English JSON file
$jsonContent = Get-Content -Path $jsonInputPath -Raw | ConvertFrom-Json

# Convert JSON content to a hashtable
$jsonHashtable = ConvertTo-Hashtable $jsonContent

# Loop through each allowed language except English
foreach ($languageCode in $allowedLanguages) {
    $jsonOutputPath = Join-Path -Path $langDir -ChildPath "$languageCode.json"

    # Create an empty hashtable to store translated values
    $translatedContent = @{}
    $translatedContentHashtable = @{}

    # Check if the output file already exists
    if (Test-Path -Path $jsonOutputPath) {
        # Read the existing translated content
        $translatedContent = Get-Content -Path $jsonOutputPath -Raw | ConvertFrom-Json

        # Convert JSON content to a hashtable
        $translatedContentHashtable = ConvertTo-Hashtable -psObject $translatedContent
    }

    Write-Host "`n----------------------------------------------------------------"
    Write-Host "Starting translation for language: '$languageCode'" -ForegroundColor Cyan
    Write-Host "----------------------------------------------------------------`n"
    Start-Sleep 0.8

    # Translate each entry
    foreach ($key in $jsonHashtable.Keys) {
        if (-not ($key -match "[a-zA-Z]")) {
            Write-Host -ForegroundColor DarkYellow "[!] Skipping key '$key' as it contains no alphabetical characters."
            continue
        }

        $originalText = $jsonHashtable[$key]

        # Check if the key already exists in the translated content
        if (-not $translatedContentHashtable.ContainsKey($key)) {
            # Translate the original text
            $translatedText = TranslateText -text $originalText -targetLanguage $languageCode

            # Only update if translation was successful
            if ($null -ne $translatedText) {
                $translatedContentHashtable[$key] = $translatedText
                Write-Host -ForegroundColor Green "[+] Translated: '$originalText' to '$translatedText' in $jsonOutputPath"
            }
            else {
                Write-Host -ForegroundColor Red "[Error] Skipping translation for key '$key' due to an error."
            }
        }
        else {
            Write-Host -ForegroundColor Yellow "[!] Key '$key' already translated: $($translatedContentHashtable[$key])"
        }
    }

    # Convert translated hashtable to JSON
    $translatedJson = $translatedContentHashtable | ConvertTo-Json -Depth 100

    # Save the translated JSON to file
    Set-Content -Path $jsonOutputPath -Value $translatedJson -Encoding UTF8

    Write-Host -ForegroundColor Cyan "`nTranslation completed and saved to $jsonOutputPath"
    Write-Host "`n"
}
