# Laravel Language File Translation Script
![Screenshot 2024-10-23 165902](https://github.com/user-attachments/assets/67aaea08-f992-414a-86a6-397aaf1015c8)

This PowerShell script automates the translation of Laravel's `en.json` language file into multiple languages using the **Google Translate API**. It reads the English language file, translates each string into the specified languages, and generates corresponding JSON files for each language in your `lang` directory.

## Prerequisites

- **Google Translate API Key**: You need a valid Google Translate API key. You can get one from the [Google Cloud Console](https://console.cloud.google.com/).
- **PowerShell**: Ensure PowerShell is available on your system.

## Setup Instructions

1. **Clone the Repository** or download or copy the script.
2. If you don't already have an `en.json` file containing all your translatable strings, you can use this [Blade Translatable Extractor](https://github.com/tauseedzaman/Blade-Translatable-Extractor) PowerShell script to extract them from your Laravel views and generate the `en.json` file.

3. **Set your Google Translate API key** in the script:
   ```powershell
   $apiKey = "YOUR_API_KEY"
   ```
4. **Update the `lang` folder path** in the script to point to your Laravel `lang` directory:
   ```powershell
   $langDir = "path/to/lang"
   ```
5. Ensure the `lang` directory contains your **`en.json`** file.

## Running the Script

1. Open **PowerShell** and navigate to the directory where the script is located.
2. Run the script:
   ```powershell
   .\translate.ps1
   ```

The script will:
- Validate the `lang` folder and `en.json` file paths.
- Automatically translate the content of `en.json` into the supported languages.
- Save the translated files as JSON files (e.g., `es.json`, `fr.json`) in the same `lang` directory.

## Notes

- If a translation already exists in the target language file, the script will skip that key unless the key is missing.
- If a translation fails, the script will log an error and move on to the next key.

## Example

For example, if you are translating to **Spanish**, the script will generate a `es.json` file in the `lang` folder containing the translated strings.

```json
{
  "welcome": "bienvenida",
  "login": "acceso",
  "logout": "cerrar sesión"
}
```

## Troubleshooting

- If the script fails to find the `en.json` file or `lang` folder, ensure that the paths are correctly set in the script.
- Ensure that your **Google Translate API Key** is active and has sufficient quota.

## Troubleshooting

- If the script fails to find the `en.json` file or `lang` folder, ensure that the paths are correctly set in the script.
- Ensure that your **Google Translate API Key** is active and has sufficient quota.

## License

This script is open-source and available for personal and commercial use.
