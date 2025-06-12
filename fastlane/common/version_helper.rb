# 버전 업데이트 함수
def update_version(app_info, version_number = nil, build_number = nil)
  info_plist_path = app_info[:info_plist_path]
  
  if version_number
    UI.message("버전을 #{version_number}로 업데이트합니다...")
    set_info_plist_value(
      path: info_plist_path,
      key: "CFBundleShortVersionString",
      value: version_number
    )
  end
  
  if build_number
    UI.message("빌드 번호를 #{build_number}로 업데이트합니다...")
    set_info_plist_value(
      path: info_plist_path,
      key: "CFBundleVersion", 
      value: build_number
    )
  end
  
  current_version = get_info_plist_value(
    path: info_plist_path,
    key: "CFBundleShortVersionString"
  )
  current_build = get_info_plist_value(
    path: info_plist_path,
    key: "CFBundleVersion"
  )
  
  UI.success("현재 버전: #{current_version} (#{current_build})")
end 