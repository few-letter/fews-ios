#!/usr/bin/env python3
"""
가상환경 설정 스크립트
"""

import subprocess
import sys
import os
from pathlib import Path

def setup_virtual_environment():
    """가상환경을 설정하고 필요한 패키지를 설치합니다."""
    
    # 현재 디렉터리 확인
    current_dir = Path(__file__).parent
    venv_dir = current_dir / "venv"
    requirements_file = current_dir / "requirements.txt"
    
    print(f"🚀 가상환경 설정을 시작합니다...")
    print(f"📁 작업 디렉터리: {current_dir}")
    
    try:
        # 기존 가상환경이 있으면 삭제
        if venv_dir.exists():
            print("🗑️  기존 가상환경을 삭제합니다...")
            import shutil
            shutil.rmtree(venv_dir)
        
        # 가상환경 생성
        print("🔧 가상환경을 생성합니다...")
        subprocess.run([sys.executable, "-m", "venv", str(venv_dir)], check=True)
        
        # 가상환경 활성화를 위한 pip 경로 설정
        if os.name == 'nt':  # Windows
            pip_path = venv_dir / "Scripts" / "pip"
            python_path = venv_dir / "Scripts" / "python"
        else:  # Unix/Linux/macOS
            pip_path = venv_dir / "bin" / "pip"
            python_path = venv_dir / "bin" / "python"
        
        # pip 업그레이드
        print("📦 pip을 업그레이드합니다...")
        subprocess.run([str(python_path), "-m", "pip", "install", "--upgrade", "pip"], check=True)
        
        # requirements.txt가 존재하면 패키지 설치
        if requirements_file.exists():
            print("📥 패키지를 설치합니다...")
            subprocess.run([str(pip_path), "install", "-r", str(requirements_file)], check=True)
        else:
            print("⚠️  requirements.txt 파일이 없습니다. 기본 패키지만 설치합니다.")
            subprocess.run([str(pip_path), "install", "Pillow"], check=True)
        
        print("✅ 가상환경 설정이 완료되었습니다!")
        print(f"🎯 가상환경 위치: {venv_dir}")
        
        # 활성화 방법 안내
        if os.name == 'nt':  # Windows
            print(f"\n🔧 가상환경 활성화 방법:")
            print(f"   {venv_dir}\\Scripts\\activate")
        else:  # Unix/Linux/macOS
            print(f"\n🔧 가상환경 활성화 방법:")
            print(f"   source {venv_dir}/bin/activate")
        
        return True
        
    except subprocess.CalledProcessError as e:
        print(f"❌ 가상환경 설정 중 오류가 발생했습니다: {e}")
        return False
    except Exception as e:
        print(f"❌ 예상치 못한 오류가 발생했습니다: {e}")
        return False

def check_python_version():
    """Python 버전을 확인합니다."""
    version = sys.version_info
    if version.major < 3 or (version.major == 3 and version.minor < 7):
        print("❌ Python 3.7 이상이 필요합니다.")
        print(f"   현재 버전: {version.major}.{version.minor}.{version.micro}")
        return False
    
    print(f"✅ Python 버전 확인: {version.major}.{version.minor}.{version.micro}")
    return True

if __name__ == "__main__":
    print("🐍 Python 가상환경 설정 도구")
    print("=" * 50)
    
    if not check_python_version():
        sys.exit(1)
    
    if setup_virtual_environment():
        print("\n🎉 모든 설정이 완료되었습니다!")
    else:
        print("\n💥 설정 중 오류가 발생했습니다.")
        sys.exit(1) 