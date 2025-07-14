from make_screenshots import generate_screenshots
from pathlib import Path
import json
import shutil
import sys

def main():
    base_output_dir = Path(__file__).parent / "output"
    if base_output_dir.exists() and base_output_dir.is_dir():
        print(f"Removing existing output directory: {base_output_dir}")
        shutil.rmtree(base_output_dir)
        print("Output directory removed.")

    config_dir = Path(__file__).parent / "resources" / "config"
    config_files = list(config_dir.glob("*_config.json"))
    
    if not config_files:
        print("Error: No config files found in resources/config directory.")
        return

    available_apps = [f.stem.replace("_config", "") for f in config_files]

    # Check if app name is provided as command line argument
    if len(sys.argv) > 1:
        provided_app_name = sys.argv[1].lower()
        chosen_app_name = None
        
        # Find matching app name (case insensitive)
        for app_name in available_apps:
            if app_name.lower() == provided_app_name:
                chosen_app_name = app_name
                break
        
        if chosen_app_name is None:
            print(f"Error: App '{sys.argv[1]}' not found in available apps.")
            print("Available apps:")
            for i, app_name in enumerate(available_apps):
                print(f"{i + 1}: {app_name}")
            return
        
        print(f"Using app: {chosen_app_name}")
    else:
        # Interactive mode - ask user to select
        print("Available apps:")
        for i, app_name in enumerate(available_apps):
            print(f"{i + 1}: {app_name}")

        app_index = -1
        while app_index < 0 or app_index >= len(available_apps):
            try:
                choice = input(f"Enter the number of the app to generate screenshots for (1-{len(available_apps)}): ")
                app_index = int(choice) - 1
                if app_index < 0 or app_index >= len(available_apps):
                    print("Invalid number. Please try again.")
            except ValueError:
                print("Invalid input. Please enter a number.")
            except (KeyboardInterrupt, EOFError):
                print("\nOperation cancelled by user.")
                return

        chosen_app_name = available_apps[app_index]

    config_filename = f"{chosen_app_name.lower()}_config.json"
    config_path = config_dir / config_filename

    try:
        with open(config_path, 'r', encoding='utf-8') as f:
            config_data = json.load(f)
        
        final_app_name = config_data.get("app_name", chosen_app_name)
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
            print(f"\n--- Generating screenshots for {final_app_name} ({device_type}) in {lang} ---")
            generate_screenshots(app_name=final_app_name, language=lang, device_type=device_type)

if __name__ == "__main__":
    main()
