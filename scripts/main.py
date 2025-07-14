#!/usr/bin/env python3
"""
FEWS iOS 앱 관련 도구 실행 스크립트
"""

import sys
import os
import subprocess
from pathlib import Path
from typing import Optional

def check_venv_setup():
    """가상환경이 설정되어 있는지 확인합니다."""
    venv_dir = Path(__file__).parent / "venv"
    
    if not venv_dir.exists():
        print("❌ 가상환경이 설정되어 있지 않습니다.")
        print("🔧 가상환경을 설정하시겠습니까? (y/n): ", end="")
        
        choice = input().lower().strip()
        if choice in ['y', 'yes', '예']:
            return setup_venv()
        else:
            print("⚠️  가상환경 없이 실행을 시도합니다.")
            return True
    
    return True

def setup_venv():
    """가상환경을 설정합니다."""
    setup_script = Path(__file__).parent / "setup_venv.py"
    
    try:
        print("🚀 가상환경 설정을 시작합니다...")
        result = subprocess.run([sys.executable, str(setup_script)], check=True)
        return True
    except subprocess.CalledProcessError as e:
        print(f"❌ 가상환경 설정 실패: {e}")
        return False
    except Exception as e:
        print(f"❌ 예상치 못한 오류: {e}")
        return False

def run_screenshots():
    """스크린샷 이미지를 생성합니다."""
    screenshots_dir = Path(__file__).parent / "screenshots"
    run_script = screenshots_dir / "run_screenshots.py"
    
    if not run_script.exists():
        print(f"❌ 스크린샷 스크립트를 찾을 수 없습니다: {run_script}")
        return False
    
    # 가상환경 Python 경로 확인
    venv_dir = Path(__file__).parent / "venv"
    if venv_dir.exists():
        if os.name == 'nt':  # Windows
            python_path = venv_dir / "Scripts" / "python"
        else:  # Unix/Linux/macOS
            python_path = venv_dir / "bin" / "python"
        
        if python_path.exists():
            print(f"🐍 가상환경 Python 사용: {python_path}")
        else:
            print("⚠️  가상환경 Python을 찾을 수 없습니다. 시스템 Python을 사용합니다.")
            python_path = sys.executable
    else:
        print("⚠️  가상환경이 없습니다. 시스템 Python을 사용합니다.")
        python_path = sys.executable
    
    try:
        print("🎨 스크린샷 이미지 생성을 시작합니다...")
        print(f"📁 작업 디렉터리: {screenshots_dir}")
        
        # 작업 디렉터리를 screenshots로 변경하여 실행
        result = subprocess.run(
            [str(python_path), str(run_script)],
            cwd=str(screenshots_dir),
            check=True
        )
        
        print("✅ 스크린샷 이미지 생성이 완료되었습니다!")
        return True
        
    except subprocess.CalledProcessError as e:
        print(f"❌ 스크린샷 생성 실패: {e}")
        return False
    except Exception as e:
        print(f"❌ 예상치 못한 오류: {e}")
        return False

def show_menu():
    """메뉴를 표시합니다."""
    print("\n" + "=" * 50)
    print("🍎 FEWS iOS 앱 도구")
    print("=" * 50)
    print("1. 스크린샷 이미지 생성")
    print("2. 가상환경 설정")
    print("3. 종료")
    print("=" * 50)

def get_user_choice():
    """사용자 선택을 받습니다."""
    while True:
        try:
            choice = input("선택하세요 (1-3): ").strip()
            if choice in ['1', '2', '3']:
                return int(choice)
            else:
                print("⚠️  1, 2, 3 중에서 선택해주세요.")
        except KeyboardInterrupt:
            print("\n👋 프로그램을 종료합니다.")
            sys.exit(0)
        except Exception as e:
            print(f"❌ 입력 오류: {e}")

def main():
    """메인 함수"""
    print("🚀 FEWS iOS 앱 도구를 시작합니다...")
    
    while True:
        show_menu()
        choice = get_user_choice()
        
        if choice == 1:
            print("\n📱 스크린샷 이미지 생성을 선택하셨습니다.")
            
            # 가상환경 확인
            if not check_venv_setup():
                continue
            
            # 스크린샷 실행
            if run_screenshots():
                output_dir = Path(__file__).parent / "screenshots" / "output"
                print(f"📁 생성된 이미지 위치: {output_dir}")
            
        elif choice == 2:
            print("\n🔧 가상환경 설정을 선택하셨습니다.")
            setup_venv()
            
        elif choice == 3:
            print("\n👋 프로그램을 종료합니다.")
            break
        
        # 계속 진행할지 확인
        print("\n" + "-" * 30)
        continue_choice = input("계속 진행하시겠습니까? (y/n): ").lower().strip()
        if continue_choice not in ['y', 'yes', '예']:
            print("👋 프로그램을 종료합니다.")
            break

if __name__ == "__main__":
    try:
        main()
    except KeyboardInterrupt:
        print("\n👋 프로그램을 종료합니다.")
        sys.exit(0)
    except Exception as e:
        print(f"❌ 예상치 못한 오류가 발생했습니다: {e}")
        sys.exit(1)
