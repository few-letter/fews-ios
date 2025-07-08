#!/usr/bin/env python3
"""
Fastlane 메타데이터 자동 번역 스크립트

사용법:
    python3 scripts/translate_metadata.py --app Plots --file release_notes.txt --korean-text "앱을 업데이트 했습니다. 그리고 첫 출근을 했습니다."
    python3 scripts/translate_metadata.py --all-apps --file release_notes.txt --korean-text "앱을 업데이트 했습니다. 그리고 첫 출근을 했습니다."

⚠️  주의: 이 스크립트는 지정된 파일만 업데이트합니다. 다른 파일들은 건드리지 않습니다.
"""

import os
import sys
import argparse
from pathlib import Path
from typing import Dict, List

# 번역 매핑 - 한국어 기준으로 20개 언어 번역
TRANSLATIONS = {
    "en-US": {
        "앱을 업데이트 했습니다. 그리고  첫 출근을 했습니다.": "Updated the app. And I started my first day at work."
    },
    "ja": {
        "앱을 업데이트 했습니다. 그리고  첫 출근을 했습니다.": "アプリを更新しました。そして初出勤をしました。"
    },
    "zh-Hans": {
        "앱을 업데이트 했습니다. 그리고  첫 출근을 했습니다.": "应用已更新。我已开始第一天上班。"
    },
    "zh-Hant": {
        "앱을 업데이트 했습니다. 그리고  첫 출근을 했습니다.": "應用程式已更新。我已開始第一天上班。"
    },
    "de-DE": {
        "앱을 업데이트 했습니다. 그리고  첫 출근을 했습니다.": "Die App wurde aktualisiert. Und ich habe meinen ersten Arbeitstag gehabt."
    },
    "fr-FR": {
        "앱을 업데이트 했습니다. 그리고  첫 출근을 했습니다.": "L'application a été mise à jour. Et j'ai fait mon premier jour de travail."
    },
    "es-ES": {
        "앱을 업데이트 했습니다. 그리고  첫 출근을 했습니다.": "La aplicación ha sido actualizada. Y tuve mi primer día de trabajo."
    },
    "it": {
        "앱을 업데이트 했습니다. 그리고  첫 출근을 했습니다.": "L'app è stata aggiornata. E ho fatto il mio primo giorno di lavoro."
    },
    "pt-BR": {
        "앱을 업데이트 했습니다. 그리고  첫 출근을 했습니다.": "O aplicativo foi atualizado. E tive meu primeiro dia de trabalho."
    },
    "ru": {
        "앱을 업데이트 했습니다. 그리고  첫 출근을 했습니다.": "Приложение обновлено. И у меня был первый рабочий день."
    },
    "ar-SA": {
        "앱을 업데이트 했습니다. 그리고  첫 출근을 했습니다.": "تم تحديث التطبيق. وقد بدأت يومي الأول في العمل."
    },
    "hi": {
        "앱을 업데이트 했습니다. 그리고  첫 출근을 했습니다.": "ऐप अपडेट किया गया है। और मैंने काम का पहला दिन शुरू किया है।"
    },
    "tr": {
        "앱을 업데이트 했습니다. 그리고  첫 출근을 했습니다.": "Uygulama güncellendi. Ve ilk iş günümü yaşadım."
    },
    "pl": {
        "앱을 업데이트 했습니다. 그리고  첫 출근을 했습니다.": "Aplikacja została zaktualizowana. I miałem pierwszy dzień pracy."
    },
    "nl-NL": {
        "앱을 업데이트 했습니다. 그리고  첫 출근을 했습니다.": "De app is bijgewerkt. En ik had mijn eerste werkdag."
    },
    "sv": {
        "앱을 업데이트 했습니다. 그리고  첫 출근을 했습니다.": "Appen har uppdaterats. Och jag hade min första arbetsdag."
    },
    "da": {
        "앱을 업데이트 했습니다. 그리고  첫 출근을 했습니다.": "Appen er blevet opdateret. Og jeg havde min første arbejdsdag."
    },
    "fi": {
        "앱을 업데이트 했습니다. 그리고  첫 출근을 했습니다.": "Sovellus on päivitetty. Ja minulla oli ensimmäinen työpäiväni."
    },
    "no": {
        "앱을 업데이트 했습니다. 그리고  첫 출근을 했습니다.": "Appen er oppdatert. Og jeg hadde min første arbeidsdag."
    }
}

# 지원하는 앱 목록
SUPPORTED_APPS = ["Capts", "Multis", "Plots", "Retros", "Toffs"]

# 지원하는 언어 목록 (한국어 제외)
SUPPORTED_LANGUAGES = list(TRANSLATIONS.keys())

# 번역 가능한 파일 목록 (안전을 위해 제한)
TRANSLATABLE_FILES = ["release_notes.txt", "name.txt", "subtitle.txt", "description.txt", "keywords.txt"]

def get_workspace_root() -> Path:
    """작업공간 루트 디렉토리를 찾습니다."""
    current = Path.cwd()
    while current != current.parent:
        if (current / "fastlane").exists():
            return current
        current = current.parent
    raise FileNotFoundError("fastlane 디렉토리를 찾을 수 없습니다.")

def is_safe_to_update(file_name: str) -> bool:
    """파일이 번역 대상인지 확인합니다."""
    return file_name in TRANSLATABLE_FILES

def backup_file_if_exists(file_path: Path) -> bool:
    """파일이 존재하면 백업을 생성합니다."""
    if file_path.exists():
        backup_path = file_path.with_suffix(f"{file_path.suffix}.backup")
        try:
            backup_path.write_text(file_path.read_text(encoding='utf-8'), encoding='utf-8')
            print(f"📁 백업 생성: {backup_path.relative_to(get_workspace_root())}")
            return True
        except Exception as e:
            print(f"❌ 백업 실패: {e}")
            return False
    return True

def update_korean_file(app_name: str, file_name: str, korean_text: str, create_backup: bool = True) -> bool:
    """한국어 원본 파일을 안전하게 업데이트합니다."""
    if not is_safe_to_update(file_name):
        print(f"⚠️  '{file_name}'은 번역 대상 파일이 아닙니다. 허용된 파일: {', '.join(TRANSLATABLE_FILES)}")
        return False
    
    workspace_root = get_workspace_root()
    ko_file_path = workspace_root / "fastlane" / "metadata" / app_name / "ko" / file_name
    
    # 디렉토리가 없으면 생성
    ko_file_path.parent.mkdir(parents=True, exist_ok=True)
    
    # 기존 파일 백업
    if create_backup and not backup_file_if_exists(ko_file_path):
        return False
    
    try:
        with open(ko_file_path, 'w', encoding='utf-8') as f:
            f.write(korean_text)
        print(f"✅ {app_name}/ko/{file_name} 업데이트 완료")
        return True
    except Exception as e:
        print(f"❌ {app_name}/ko/{file_name} 업데이트 실패: {e}")
        return False

def translate_and_update_file(app_name: str, language: str, file_name: str, korean_text: str, create_backup: bool = True) -> bool:
    """지정된 언어로 번역하고 파일을 안전하게 업데이트합니다."""
    if not is_safe_to_update(file_name):
        return False
        
    if korean_text not in TRANSLATIONS[language]:
        print(f"⚠️  '{korean_text}'에 대한 {language} 번역이 없습니다.")
        return False
    
    translated_text = TRANSLATIONS[language][korean_text]
    
    workspace_root = get_workspace_root()
    target_file_path = workspace_root / "fastlane" / "metadata" / app_name / language / file_name
    
    # 디렉토리가 없으면 생성
    target_file_path.parent.mkdir(parents=True, exist_ok=True)
    
    # 기존 파일 백업
    if create_backup and not backup_file_if_exists(target_file_path):
        return False
    
    try:
        with open(target_file_path, 'w', encoding='utf-8') as f:
            f.write(translated_text)
        print(f"✅ {app_name}/{language}/{file_name} 번역 완료")
        return True
    except Exception as e:
        print(f"❌ {app_name}/{language}/{file_name} 번역 실패: {e}")
        return False

def process_app(app_name: str, file_name: str, korean_text: str, create_backup: bool = True) -> Dict[str, int]:
    """하나의 앱에 대해 전체 번역 프로세스를 안전하게 실행합니다."""
    print(f"\n🔄 {app_name} 앱 처리 중...")
    
    results = {"success": 0, "failed": 0}
    
    # 1. 한국어 원본 파일 업데이트
    if update_korean_file(app_name, file_name, korean_text, create_backup):
        results["success"] += 1
    else:
        results["failed"] += 1
        return results  # 한국어 파일 업데이트가 실패하면 번역도 중단
    
    # 2. 모든 언어로 번역
    for language in SUPPORTED_LANGUAGES:
        if translate_and_update_file(app_name, language, file_name, korean_text, create_backup):
            results["success"] += 1
        else:
            results["failed"] += 1
    
    return results

def main():
    parser = argparse.ArgumentParser(description="Fastlane 메타데이터 안전 번역 도구")
    
    group = parser.add_mutually_exclusive_group(required=True)
    group.add_argument("--app", choices=SUPPORTED_APPS, help="번역할 앱 이름")
    group.add_argument("--all-apps", action="store_true", help="모든 앱에 대해 번역")
    
    parser.add_argument("--file", required=True, help=f"번역할 파일명 (허용: {', '.join(TRANSLATABLE_FILES)})")
    parser.add_argument("--korean-text", required=True, help="한국어 원본 텍스트")
    parser.add_argument("--no-backup", action="store_true", help="백업 파일을 생성하지 않음")
    parser.add_argument("--dry-run", action="store_true", help="실제 파일을 변경하지 않고 시뮬레이션만 실행")
    
    args = parser.parse_args()
    
    # 파일 안전성 검사
    if not is_safe_to_update(args.file):
        print(f"❌ '{args.file}'은 번역 대상 파일이 아닙니다.")
        print(f"허용된 파일: {', '.join(TRANSLATABLE_FILES)}")
        sys.exit(1)
    
    if args.dry_run:
        print("🔍 DRY RUN 모드: 실제 파일을 변경하지 않습니다.")
        print(f"📄 대상 파일: {args.file}")
        print(f"🇰🇷 한국어 텍스트: {args.korean_text}")
        print(f"📁 백업 생성: {'아니오' if args.no_backup else '예'}")
        return
    
    create_backup = not args.no_backup
    
    print("🚀 Fastlane 메타데이터 안전 번역 시작")
    print(f"📄 대상 파일: {args.file}")
    print(f"🇰🇷 한국어 텍스트: {args.korean_text}")
    print(f"📁 백업 생성: {'아니오' if args.no_backup else '예'}")
    
    total_results = {"success": 0, "failed": 0}
    
    if args.all_apps:
        print(f"\n📱 모든 앱 처리 중... ({len(SUPPORTED_APPS)}개)")
        for app_name in SUPPORTED_APPS:
            app_results = process_app(app_name, args.file, args.korean_text, create_backup)
            total_results["success"] += app_results["success"]
            total_results["failed"] += app_results["failed"]
    else:
        app_results = process_app(args.app, args.file, args.korean_text, create_backup)
        total_results["success"] += app_results["success"]
        total_results["failed"] += app_results["failed"]
    
    print(f"\n🎉 번역 완료!")
    print(f"✅ 성공: {total_results['success']}개")
    print(f"❌ 실패: {total_results['failed']}개")
    
    if create_backup:
        print(f"\n📁 백업 파일들은 '.backup' 확장자로 저장되었습니다.")
        print("백업 파일 정리: find fastlane/metadata -name '*.backup' -delete")
    
    if total_results["failed"] > 0:
        sys.exit(1)

if __name__ == "__main__":
    main() 