# 앱 선택 함수
def select_app
  apps_dir = File.expand_path("../../Apps", __dir__)
  apps = Dir.entries(apps_dir)
             .select { |entry| File.directory?(File.join(apps_dir, entry)) }
             .reject { |entry| entry.start_with?('.') || entry == 'Derived' || entry == 'Tuist' || entry == 'Apps' || entry.include?('.xc') }
             .select { |entry| File.exist?(File.join(apps_dir, entry, "#{entry}.xcodeproj")) }
             .sort
  
  if apps.empty?
    UI.error("Apps 디렉토리에서 앱을 찾을 수 없습니다.")
    return nil
  end
  
  UI.message("사용 가능한 앱들:")
  apps.each_with_index do |app, index|
    UI.message("#{index + 1}. #{app}")
  end
  
  choice = UI.input("빌드할 앱을 선택하세요 (1-#{apps.length}): ")
  
  begin
    index = choice.to_i - 1
    if index >= 0 && index < apps.length
      selected_app = apps[index]
      UI.success("선택된 앱: #{selected_app}")
      return selected_app
    else
      UI.error("잘못된 선택입니다.")
      return nil
    end
  rescue
    UI.error("잘못된 입력입니다.")
    return nil
  end
end

# 앱 정보 가져오기 함수
def get_app_info(app_name)
  project_path = "Apps/#{app_name}/#{app_name}.xcodeproj"
  full_project_path = File.expand_path("../../Apps/#{app_name}/#{app_name}.xcodeproj", __dir__)
  info_plist_path = "Apps/#{app_name}/Resources/Info.plist"
  
  unless File.exist?(full_project_path)
    UI.error("프로젝트 파일을 찾을 수 없습니다: #{project_path}")
    return nil
  end
  
  return {
    name: app_name,
    project_path: project_path,
    scheme: app_name,
    info_plist_path: info_plist_path
  }
end

# Bundle ID 가져오기 함수
def get_bundle_id(app_name)
  case app_name
  when "Plots"
    ENV['BUNDLE_ID_PLOTS']
  when "FewCuts"
    ENV['BUNDLE_ID_FEWCUTS']
  when "FewRetros"
    ENV['BUNDLE_ID_FEWRETROS']
  when "Toff"
    ENV['BUNDLE_ID_TOFF']
  else
    UI.error("알 수 없는 앱: #{app_name}")
    nil
  end
end

# 모든 Bundle ID 가져오기 함수
def get_all_bundle_ids
  [
    ENV['BUNDLE_ID_PLOTS'],
    ENV['BUNDLE_ID_FEWCUTS'],
    ENV['BUNDLE_ID_FEWRETROS'],
    ENV['BUNDLE_ID_TOFF'],
  ].compact
end 