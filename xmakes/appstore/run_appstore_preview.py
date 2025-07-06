from make_appstore_preview import generate_appstore_previews
from pathlib import Path
import json
import shutil # Add this import

def main():
    # Define the base output directory
    base_output_dir = Path(__file__).parent / "output"

    # Remove the existing output directory if it exists
    if base_output_dir.exists() and base_output_dir.is_dir():
        print(f"Removing existing output directory: {base_output_dir}")
        shutil.rmtree(base_output_dir)
        print("Output directory removed.")

    # Load config from plots_config.json
    config_path = Path(__file__).parent / "resources" / "config" / "plots_config.json"
    try:
        with open(config_path, 'r', encoding='utf-8') as f:
            config_data = json.load(f)
        app_name = config_data.get("app_name", "default_app")
        localization_data = config_data.get("localization", {})
        supported_languages = list(localization_data.keys())
        supported_devices = list(config_data.get("devices", {}).keys())
    except FileNotFoundError:
        print(f"Error: Config file not found: {config_path}")
        return
    except Exception as e:
        print(f"Error loading config file: {e}")
        return

    if not supported_languages:
        print("Error: No supported languages found in config file.")
        return
    
    if not supported_devices:
        print("Error: No supported devices found in config file.")
        return

    for device_type in supported_devices:
        for lang in supported_languages:
            print(f"\n--- Generating previews for {app_name} ({device_type}) in {lang} ---")
            generate_appstore_previews(app_name=app_name, language=lang, device_type=device_type)

if __name__ == "__main__":
    main()