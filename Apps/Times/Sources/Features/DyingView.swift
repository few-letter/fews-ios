import SwiftUI

// 국가 구조체 정의
struct Country: Identifiable, Codable, Hashable {
    let id: String
    let name: String
    let code: String
}

// 성별 열거형 정의
enum Gender: String, CaseIterable, Identifiable {
    case male = "남성"
    case female = "여성"
    var id: String { self.rawValue }
}

// API 응답 구조체 정의
struct LifeExpectancyResponse: Decodable {
    let value: [LifeExpectancyData]
}

struct LifeExpectancyData: Decodable {
    let numericValue: Double
    enum CodingKeys: String, CodingKey {
        case numericValue = "NumericValue"
    }
}

// 메인 SwiftUI 뷰
struct DyingView: View {
    @State private var name: String = ""
    @State private var birthdate: Date = Date()
    @State private var selectedCountry: Country?
    @State private var selectedGender: Gender?
    @State private var result: String = ""
    @State private var countries: [Country] = []
    
    var body: some View {
        Form {
            Section(header: Text("개인 정보")) {
                TextField("이름 (선택)", text: $name)
                DatePicker("생년월일", selection: $birthdate, displayedComponents: .date)
                    .environment(\.locale, Locale(identifier: "ko_KR"))
            }
            
            Section(header: Text("국가 및 성별")) {
                Picker("국가", selection: $selectedCountry) {
                    Text("선택하세요").tag(nil as Country?)
                    ForEach(countries, id: \.code) { country in
                        Text(country.name).tag(country as Country?)
                    }
                }
                
                Picker("성별", selection: $selectedGender) {
                    Text("선택하세요").tag(nil as Gender?)
                    ForEach(Gender.allCases, id: \.self) { gender in
                        Text(gender.rawValue).tag(gender)
                    }
                }
            }
            
            Section {
                Button("예측하기") {
                    guard let country = selectedCountry, let gender = selectedGender else {
                        result = "국가와 성별을 선택해주세요."
                        return
                    }
                    
                    let genderCode = gender == .male ? "MLE" : "FMLE"
                    let urlString = "https://ghoapi.azureedge.net/api/WHOSIS_000001?$filter=Dim1 eq '\(genderCode)' and SpatialDim eq '\(country.code)'&$orderby=TimeDimensionBegin desc&$top=1&$format=json"
                    
                    guard let url = URL(string: urlString) else {
                        result = "잘못된 URL입니다."
                        return
                    }
                    
                    URLSession.shared.dataTask(with: url) { data, response, error in
                        if let error = error {
                            DispatchQueue.main.async {
                                result = "API 호출 오류: \(error.localizedDescription)"
                            }
                            return
                        }
                        
                        guard let data = data else {
                            DispatchQueue.main.async {
                                result = "데이터를 받지 못했습니다."
                            }
                            return
                        }
                        
                        do {
                            if let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any], json["error"] != nil {
                                DispatchQueue.main.async {
                                    result = "API 오류: \(json["error"] as? String ?? "알 수 없는 오류")"
                                }
                                return
                            }
                            
                            let decoder = JSONDecoder()
                            let response = try decoder.decode(LifeExpectancyResponse.self, from: data)
                            
                            if let lifeExpectancy = response.value.first?.numericValue {
                                let calendar = Calendar.current
                                if let deathDate = calendar.date(byAdding: .year, value: Int(lifeExpectancy), to: birthdate) {
                                    let formatter = DateFormatter()
                                    formatter.dateStyle = .medium
                                    formatter.locale = Locale(identifier: "ko_KR")
                                    DispatchQueue.main.async {
                                        result = "\(name.isEmpty ? "" : "\(name)님, ")당신의 예상 수명은 \(Int(lifeExpectancy))년이며, 예상 사망 날짜는 \(formatter.string(from: deathDate))입니다.\n\n이 예측은 평균 수명 데이터를 기반으로 한 추정치이며, 개인의 건강 상태나 생활습관을 반영하지 않습니다. 의학적 조언으로 사용되지 않습니다."
                                    }
                                } else {
                                    DispatchQueue.main.async {
                                        result = "사망 날짜를 계산할 수 없습니다."
                                    }
                                }
                            } else {
                                DispatchQueue.main.async {
                                    result = "사용 가능한 데이터가 없습니다."
                                }
                            }
                        } catch {
                            DispatchQueue.main.async {
                                result = "응답 해석 오류: \(error.localizedDescription)"
                            }
                        }
                    }.resume()
                }
            }
            
            Section(header: Text("결과")) {
                Text(result)
                    .foregroundColor(.gray)
            }
        }
        .navigationTitle("Dying - 수명 예측")
        .onAppear {
            fetchCountries()
        }
    }
    
    // 국가 목록을 API에서 동적으로 가져오는 함수
    func fetchCountries() {
        let urlString = "https://ghoapi.azureedge.net/api/DIMENSION/COUNTRY/DimensionValues"
        guard let url = URL(string: urlString) else {
            result = "국가 목록을 가져오지 못했습니다."
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                DispatchQueue.main.async {
                    result = "국가 목록 호출 오류: \(error.localizedDescription)"
                }
                return
            }
            
            guard let data = data else {
                DispatchQueue.main.async {
                    result = "국가 목록 데이터를 받지 못했습니다."
                }
                return
            }
            
            do {
                let decoder = JSONDecoder()
                let response = try decoder.decode(CountryResponse.self, from: data)
                DispatchQueue.main.async {
                    countries = response.value.map { Country(id: $0.code, name: $0.name, code: $0.code) }
                }
            } catch {
                DispatchQueue.main.async {
                    result = "국가 목록 해석 오류: \(error.localizedDescription)"
                }
            }
        }.resume()
    }
}

// 국가 목록 API 응답 구조체 정의
struct CountryResponse: Decodable {
    let value: [CountryData]
}

struct CountryData: Decodable {
    let code: String
    let name: String
    enum CodingKeys: String, CodingKey {
        case code = "Code"
        case name = "Title"
    }
}
