from make_metadata import generate_metadata
from pathlib import Path
import json
import shutil
import sys

def main():
    """metadata 생성 메인 함수"""
    
    # 기존 output 디렉토리 정리
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

    # 명령행 인수로 앱 이름이 제공된 경우
    if len(sys.argv) > 1:
        provided_app_name = sys.argv[1].lower()
        chosen_app_name = None
        
        # 대소문자 구분 없이 앱 이름 찾기
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
        selected_apps = [chosen_app_name]
    else:
        # 대화형 모드 - 사용자에게 선택 요청
        print("Available apps:")
        for i, app_name in enumerate(available_apps):
            print(f"{i + 1}: {app_name}")
        print(f"{len(available_apps) + 1}: All apps")

        choice_index = -1
        while choice_index < 0 or choice_index > len(available_apps):
            try:
                choice = input(f"Enter the number of the app to generate metadata for (1-{len(available_apps) + 1}): ")
                choice_index = int(choice) - 1
                
                if choice_index == len(available_apps):
                    # 모든 앱 선택
                    selected_apps = available_apps
                    print("Generating metadata for all apps")
                    break
                elif 0 <= choice_index < len(available_apps):
                    # 특정 앱 선택
                    selected_apps = [available_apps[choice_index]]
                    print(f"Generating metadata for: {selected_apps[0]}")
                    break
                else:
                    print("Invalid number. Please try again.")
            except ValueError:
                print("Invalid input. Please enter a number.")
            except (KeyboardInterrupt, EOFError):
                print("\nOperation cancelled by user.")
                return

    # 선택된 앱들의 metadata 생성
    total_files_generated = 0
    total_languages_processed = 0
    
    for app_name in selected_apps:
        try:
            print(f"\n--- Generating metadata for {app_name} ---")
            result = generate_metadata(app_name=app_name)
            
            if result and result.get("generated_files"):
                app_total = result.get("total_files", 0)
                languages_count = len(result.get("supported_languages", []))
                total_files_generated += app_total
                total_languages_processed += languages_count
                
                print(f"✅ {app_name}: {app_total} files generated across {languages_count} languages")
                
                # 언어별 파일 수 요약 출력
                generated_files = result.get("generated_files", {})
                for language, files in generated_files.items():
                    print(f"  - {language}: {len(files)} files")
                    
            else:
                print(f"❌ {app_name}: Failed to generate metadata")
                
        except Exception as e:
            print(f"❌ {app_name}: Error generating metadata - {e}")
    
    print(f"\n🎉 Metadata generation complete!")
    print(f"Total files generated: {total_files_generated}")
    print(f"Apps processed: {len(selected_apps)}")
    
    if total_files_generated > 0:
        print(f"\n📁 Files generated in: {base_output_dir}")
        print("Note: Files now contain actual localized content from the config files.")
        print("Each language has its own translated metadata content.")
        print("\n💡 Use Fastfile to copy these metadata files to the appropriate fastlane directory.")

if __name__ == "__main__":
    main()
