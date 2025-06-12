# App Store Connect API 키 설정 함수 (공식 문서 방식)
def setup_api_key
  # 환경변수 로드
#   Dotenv.overload(File.join(File.dirname(__FILE__), "../config.env"))
  
  # API 키 파일 경로 확인
  api_key_json_path = File.expand_path("../api_key.json", File.dirname(__FILE__))
  
  unless File.exist?(api_key_json_path)
    UI.error("API 키 파일을 찾을 수 없습니다: #{api_key_json_path}")
    return
  end
  
  # API 키 JSON 파일 읽기
  api_key_data = JSON.parse(File.read(api_key_json_path))
  
  app_store_connect_api_key(
    key_id: api_key_data["key_id"],
    issuer_id: api_key_data["issuer_id"],
    key_content: api_key_data["key"],
    duration: 1200,
    in_house: api_key_data["in_house"] || false
  )
  
  UI.success("App Store Connect API 키가 설정되었습니다! 🔑")
  UI.message("Key ID: #{api_key_data["key_id"]}")
  UI.message("Issuer ID: #{api_key_data["issuer_id"]}")
  UI.message("Shared value로 설정되어 모든 action에서 자동 사용됩니다.")
end 