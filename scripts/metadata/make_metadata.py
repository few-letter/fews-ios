import json
import os
from pathlib import Path
from typing import Dict, List, Optional

class MetadataGenerator:
    def __init__(self, app_name: str = "plots"):
        self.app_name = app_name.lower()
        self.config_path = Path(__file__).parent / "resources" / "config" / f"{self.app_name}_config.json"
        self.config_data = self._load_config()
        
    def _load_config(self) -> Dict:
        """config 파일을 로드합니다."""
        try:
            with open(self.config_path, 'r', encoding='utf-8') as f:
                return json.load(f)
        except FileNotFoundError:
            print(f"Error: Config file not found: {self.config_path}")
            return {}
        except Exception as e:
            print(f"Error loading config file: {e}")
            return {}
    
    def _get_output_base_dir(self) -> Path:
        """출력 기본 디렉토리를 가져옵니다."""
        # 내부 output 폴더 사용 (스크린샷 스크립트와 동일한 구조)
        return Path(__file__).parent / "output"
    
    def _get_base_language(self) -> str:
        """기준 언어를 가져옵니다."""
        return self.config_data.get("base_language", "ko")
    
    def _get_supported_languages(self) -> List[str]:
        """지원하는 언어 목록을 localization 데이터의 키에서 가져옵니다."""
        return list(self.config_data.get("localization", {}).keys())
    
    def _get_app_display_name(self) -> str:
        """앱의 표시 이름을 가져옵니다."""
        return self.config_data.get("app_name", self.app_name).title()
    
    def _ensure_directory_exists(self, directory_path: Path):
        """디렉토리가 존재하지 않으면 생성합니다."""
        directory_path.mkdir(parents=True, exist_ok=True)
    
    def _write_metadata_file(self, file_path: Path, content: str):
        """metadata 파일을 작성합니다."""
        try:
            self._ensure_directory_exists(file_path.parent)
            with open(file_path, 'w', encoding='utf-8') as f:
                f.write(content)
            print(f"Created: {file_path}")
        except Exception as e:
            print(f"Error writing file {file_path}: {e}")
    
    def generate_language_metadata(self, language: str):
        """특정 언어의 metadata 파일들을 생성합니다."""
        if not self.config_data:
            print("Error: No config data available")
            return []

        localization_data = self.config_data.get("localization", {})
        base_language = self._get_base_language()
        
        # 해당 언어의 데이터가 있는지 확인, 없으면 기준 언어 사용
        if language in localization_data:
            metadata = localization_data[language]
        elif base_language in localization_data:
            metadata = localization_data[base_language]
            print(f"Warning: No localization data for '{language}', using base language '{base_language}'")
        else:
            print(f"Error: No metadata found for language '{language}' or base language '{base_language}'")
            return []
        
        app_display_name = self._get_app_display_name()
        output_base_dir = self._get_output_base_dir()
        lang_dir = output_base_dir / app_display_name / language
        
        # 각 metadata 파일 생성
        metadata_files = {
            "name.txt": metadata.get("name", ""),
            "subtitle.txt": metadata.get("subtitle", ""),
            "description.txt": metadata.get("description", ""),
            "keywords.txt": metadata.get("keywords", ""),
            "release_notes.txt": metadata.get("release_notes", "")
        }
        
        # URL 파일들 처리 - 언어별 우선, 없으면 최상위 레벨 사용
        url_fields = ["marketing_url", "support_url", "privacy_url"]
        for url_field in url_fields:
            # 1. 언어별 metadata에서 먼저 찾기
            url_value = metadata.get(url_field, "")
            
            # 2. 언어별에 없으면 최상위 레벨에서 찾기
            if not url_value:
                url_value = self.config_data.get(url_field, "")
            
            if url_value:
                metadata_files[f"{url_field}.txt"] = url_value
        
        generated_files = []
        for filename, content in metadata_files.items():
            if content:  # 내용이 있는 경우에만 파일 생성
                file_path = lang_dir / filename
                self._write_metadata_file(file_path, content)
                generated_files.append(str(file_path))
        
        return generated_files
    
    def generate_all_metadata(self):
        """모든 언어의 metadata를 생성합니다."""
        print(f"Starting metadata generation for {self.app_name}")
        
        if not self.config_data:
            print("Error: No config data available")
            return {}
        
        supported_languages = self._get_supported_languages()
        
        if not supported_languages:
            print("Error: No localization data found in config")
            return {}
        
        all_generated_files = {}
        total_files = 0
        
        for language in supported_languages:
            print(f"Generating metadata for language: {language}")
            generated_files = self.generate_language_metadata(language)
            
            if generated_files:
                all_generated_files[language] = generated_files
                total_files += len(generated_files)
                print(f"  {language}: {len(generated_files)} files generated")
            else:
                print(f"  {language}: No files generated")
        
        print(f"Total metadata generation complete: {total_files} files")
        
        return {
            "generated_files": all_generated_files,
            "total_files": total_files,
            "supported_languages": supported_languages,
            "app_name": self.app_name,
            "output_directory": str(self._get_output_base_dir())
        }

def generate_metadata(app_name: str):
    """지정된 앱의 metadata를 생성합니다."""
    generator = MetadataGenerator(app_name=app_name)
    return generator.generate_all_metadata()

if __name__ == "__main__":
    # 테스트용 - 실제 사용시에는 run_metadata.py를 사용해야 합니다.
    print("Please use run_metadata.py to generate metadata.")
