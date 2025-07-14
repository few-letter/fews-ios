#!/usr/bin/env python3
# scripts/metadata/check_json_chars.py

import json
import sys

# 글자수 제한 설정
CHAR_LIMITS = {
    'name': 30,
    'subtitle': 30,
    'keywords': 100,
    'description': 4000
}

def check_json_character_limits(config_path):
    """JSON 설정 파일의 글자수 제한 검증"""
    print(f"🔍 JSON 메타데이터 글자수 검증: {config_path}")
    
    with open(config_path, 'r', encoding='utf-8') as f:
        config = json.load(f)
    
    app_name = config.get('app_name', 'unknown')
    violations = []
    
    print(f"\n📱 앱: {app_name}")
    print("=" * 50)
    
    for lang, data in config.get('localization', {}).items():
        print(f"\n🌐 언어: {lang}")
        
        for field, content in data.items():
            if field in CHAR_LIMITS:
                char_count = len(str(content))
                limit = CHAR_LIMITS[field]
                
                status = "✅" if char_count <= limit else "❌"
                print(f"  {field:12} : {char_count:3d}/{limit:3d} 글자 {status}")
                
                if char_count > limit:
                    violations.append({
                        'app': app_name,
                        'lang': lang,
                        'field': field,
                        'current': char_count,
                        'limit': limit,
                        'excess': char_count - limit
                    })
    
    # 결과 요약
    if violations:
        print(f"\n❌ 글자수 초과 항목: {len(violations)}개")
        print("-" * 50)
        for v in violations:
            print(f"  {v['lang']}.{v['field']}: {v['current']}자 ({v['excess']}자 초과)")
        return False
    else:
        print(f"\n✅ 모든 항목이 글자수 제한을 준수합니다!")
        return True

if __name__ == "__main__":
    if len(sys.argv) != 2:
        print("사용법: python3 check_json_chars.py <config.json>")
        sys.exit(1)
    
    config_file = sys.argv[1]
    try:
        is_valid = check_json_character_limits(config_file)
        sys.exit(0 if is_valid else 1)
    except FileNotFoundError:
        print(f"❌ 파일을 찾을 수 없습니다: {config_file}")
        sys.exit(1)
    except json.JSONDecodeError:
        print(f"❌ JSON 형식이 올바르지 않습니다: {config_file}")
        sys.exit(1) 