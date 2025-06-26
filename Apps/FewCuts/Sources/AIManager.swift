//
//  Content.swift
//  FewCuts
//
//  Created by 송영모 on 6/25/25.
//

import Foundation
import MLXNN
import MLX
import SwiftUI

// MARK: - Content Type Detection
enum ContentType: String, CaseIterable {
    case songLyrics = "노래 가사"
    case recipe = "레시피"
    case clothing = "의류 정보"
    case menu = "메뉴"
    case contact = "연락처"
    case event = "이벤트/일정"
    case news = "뉴스/기사"
    case product = "상품 정보"
    case general = "일반 텍스트"
    
    var icon: String {
        switch self {
        case .songLyrics: return "🎵"
        case .recipe: return "🍳"
        case .clothing: return "👔"
        case .menu: return "🍽️"
        case .contact: return "📞"
        case .event: return "📅"
        case .news: return "📰"
        case .product: return "🛍️"
        case .general: return "📝"
        }
    }
}

// MARK: - Text Processing Rules
struct TextProcessingRule {
    let name: String
    let pattern: String
    let replacement: String
}

// MARK: - Content Processor Protocol
protocol ContentProcessor {
    func process(_ text: String) -> String
    func getPrompt() -> String
}

// MARK: - AI Manager
@Observable
class AIManager {
    // MARK: - Properties
    var isProcessing = false
    var progress: Double = 0.0
    var status = "준비됨"
    
    // 기본 텍스트 정리 규칙들
    private let basicRules: [TextProcessingRule] = [
        TextProcessingRule(name: "중복 공백", pattern: "\\s+", replacement: " "),
        TextProcessingRule(name: "줄바꿈 정리", pattern: "\n\n+", replacement: "\n\n"),
        TextProcessingRule(name: "특수문자", pattern: "[\\x00-\\x1F\\x7F]", replacement: ""),
        TextProcessingRule(name: "반복 문자", pattern: "([.!?])\\1{2,}", replacement: "$1"),
    ]
    
    // 콘텐츠 프로세서들
    private let processors: [ContentType: ContentProcessor] = [
        .songLyrics: SongLyricsProcessor(),
        .recipe: RecipeProcessor(),
        .clothing: ClothingProcessor(),
        .menu: MenuProcessor(),
        .contact: ContactProcessor(),
        .event: EventProcessor(),
        .news: NewsProcessor(),
        .product: ProductProcessor(),
        .general: GeneralTextProcessor()
    ]
    
    // MARK: - Initialization
    init() {
        MLX.GPU.set(cacheLimit: 256 * 1024 * 1024) // 256MB
    }
    
    // MARK: - Public Methods
    public func organizeExtractedText(_ extractedText: String) async -> String {
        guard !isProcessing else { return "처리 중입니다..." }
        
        await MainActor.run {
            self.isProcessing = true
            self.progress = 0.0
            self.status = "텍스트 분석 중..."
        }
        
        do {
            // 1단계: 기본 정리
            await updateProgress(0.1, status: "기본 정리 중...")
            let cleanedText = applyBasicCleaning(extractedText)
            
            // 2단계: 콘텐츠 타입 감지
            await updateProgress(0.3, status: "콘텐츠 타입 분석 중...")
            let detectedType = detectContentType(cleanedText)
            
            // 3단계: 문맥 기반 처리
            await updateProgress(0.5, status: "\(detectedType.icon) \(detectedType.rawValue) 정리 중...")
            let contextuallyProcessed = await processWithContext(cleanedText, type: detectedType)
            
            // 4단계: 구조화
            await updateProgress(0.7, status: "구조 최적화 중...")
            let structuredText = structureContent(contextuallyProcessed, type: detectedType)
            
            // 5단계: 마크다운 포맷팅
            await updateProgress(0.9, status: "마크다운 포맷팅 중...")
            let formattedText = formatAsMarkdown(structuredText, type: detectedType)
            
            // 완료
            await updateProgress(1.0, status: "완료")
            
            await MainActor.run {
                self.isProcessing = false
            }
            
            return formattedText
            
        } catch {
            await MainActor.run {
                self.isProcessing = false
                self.status = "오류: \(error.localizedDescription)"
            }
            return "텍스트 정리에 실패했습니다: \(error.localizedDescription)"
        }
    }
    
    public func getAnalysisStats(for text: String) -> TextAnalysisResult {
        let detectedType = detectContentType(text)
        let sections = analyzeStructure(text, type: detectedType)
        let confidence = calculateConfidence(text: text, sections: sections, type: detectedType)
        
        return TextAnalysisResult(
            originalLength: text.count,
            processedLength: sections.joined().count,
            detectedSections: sections.count,
            confidence: confidence
        )
    }
    
    // MARK: - Private Methods
    private func updateProgress(_ progress: Double, status: String) async {
        await MainActor.run {
            self.progress = progress
            self.status = status
        }
        
        try? await Task.sleep(nanoseconds: 300_000_000) // 0.3초
    }
    
    private func applyBasicCleaning(_ text: String) -> String {
        var result = text
        
        for rule in basicRules {
            result = result.replacingOccurrences(
                of: rule.pattern,
                with: rule.replacement,
                options: .regularExpression
            )
        }
        
        return result.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    private func detectContentType(_ text: String) -> ContentType {
        let lowerText = text.lowercased()
        let lines = text.components(separatedBy: .newlines)
        
        // 노래 가사 패턴
        if containsLyricsPatterns(lowerText) {
            return .songLyrics
        }
        
        // 레시피 패턴
        if containsRecipePatterns(lowerText) {
            return .recipe
        }
        
        // 의류 정보 패턴
        if containsClothingPatterns(lowerText) {
            return .clothing
        }
        
        // 메뉴 패턴
        if containsMenuPatterns(lowerText) {
            return .menu
        }
        
        // 연락처 패턴
        if containsContactPatterns(text) {
            return .contact
        }
        
        // 이벤트/일정 패턴
        if containsEventPatterns(lowerText) {
            return .event
        }
        
        // 뉴스/기사 패턴
        if containsNewsPatterns(lowerText) {
            return .news
        }
        
        // 상품 정보 패턴
        if containsProductPatterns(lowerText) {
            return .product
        }
        
        return .general
    }
    
    private func processWithContext(_ text: String, type: ContentType) async -> String {
        guard let processor = processors[type] else {
            return text
        }
        
        // 여기서 실제로는 LLM API를 호출하여 문맥 기반 정리를 수행
        // 현재는 각 프로세서의 규칙 기반 처리만 시뮬레이션
        return processor.process(text)
    }
    
    private func structureContent(_ text: String, type: ContentType) -> [String] {
        switch type {
        case .songLyrics:
            return structureLyrics(text)
        case .recipe:
            return structureRecipe(text)
        case .clothing:
            return structureClothing(text)
        case .menu:
            return structureMenu(text)
        case .contact:
            return structureContact(text)
        case .event:
            return structureEvent(text)
        case .news:
            return structureNews(text)
        case .product:
            return structureProduct(text)
        case .general:
            return structureGeneral(text)
        }
    }
    
    private func analyzeStructure(_ text: String, type: ContentType) -> [String] {
        return structureContent(text, type: type)
    }
    
    private func formatAsMarkdown(_ sections: [String], type: ContentType) -> String {
        let timestamp = DateFormatter.localizedString(from: Date(), dateStyle: .medium, timeStyle: .short)
        
        let header = """
        # \(type.icon) \(type.rawValue)
        
        > 이미지에서 추출한 텍스트를 AI가 문맥에 맞게 정리했습니다.
        > 생성 시간: \(timestamp)
        
        """
        
        let content = sections.joined(separator: "\n\n---\n\n")
        return header + "\n\n" + content
    }
    
    private func calculateConfidence(text: String, sections: [String], type: ContentType) -> Double {
        var confidence = 0.3 // 기본 신뢰도
        
        // 타입별 신뢰도 가중치
        switch type {
        case .songLyrics:
            if containsLyricsPatterns(text.lowercased()) { confidence += 0.4 }
        case .recipe:
            if containsRecipePatterns(text.lowercased()) { confidence += 0.4 }
        case .clothing:
            if containsClothingPatterns(text.lowercased()) { confidence += 0.4 }
        default:
            break
        }
        
        // 구조화 정도에 따른 가중치
        if sections.count > 1 { confidence += 0.2 }
        if text.count > 50 && text.count < 5000 { confidence += 0.1 }
        
        return min(confidence, 1.0)
    }
}

// MARK: - Content Type Detection Methods
extension AIManager {
    private func containsLyricsPatterns(_ text: String) -> Bool {
        let patterns = ["가사", "lyrics", "verse", "chorus", "후렴", "절", "bridge"]
        let repetitivePatterns = text.components(separatedBy: .newlines)
            .filter { !$0.trimmingCharacters(in: .whitespaces).isEmpty }
        
        // 반복되는 라인이 있는지 확인
        let uniqueLines = Set(repetitivePatterns)
        let hasRepetition = repetitivePatterns.count > uniqueLines.count * Int(1.3)
        
        return patterns.contains { text.contains($0) } || hasRepetition
    }
    
    private func containsRecipePatterns(_ text: String) -> Bool {
        let patterns = ["재료", "조리법", "만드는 법", "recipe", "ingredients", "분", "시간", "컵", "스푼", "그램", "ml"]
        return patterns.contains { text.contains($0) }
    }
    
    private func containsClothingPatterns(_ text: String) -> Bool {
        let patterns = ["사이즈", "size", "색상", "color", "브랜드", "원", "₩", "$", "옷", "셔츠", "바지", "드레스", "자켓"]
        return patterns.contains { text.contains($0) }
    }
    
    private func containsMenuPatterns(_ text: String) -> Bool {
        let patterns = ["메뉴", "menu", "원", "₩", "$", "가격", "price", "음식", "음료", "커피", "라떼"]
        let pricePattern = text.range(of: "[0-9,]+원", options: .regularExpression) != nil
        return patterns.contains { text.contains($0) } || pricePattern
    }
    
    private func containsContactPatterns(_ text: String) -> Bool {
        let phonePattern = text.range(of: "[0-9]{2,3}-[0-9]{3,4}-[0-9]{4}", options: .regularExpression) != nil
        let emailPattern = text.range(of: "[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}", options: .regularExpression) != nil
        return phonePattern || emailPattern
    }
    
    private func containsEventPatterns(_ text: String) -> Bool {
        let patterns = ["일정", "schedule", "시간", "날짜", "date", "이벤트", "event", "월", "일", "시"]
        return patterns.contains { text.contains($0) }
    }
    
    private func containsNewsPatterns(_ text: String) -> Bool {
        let patterns = ["기자", "뉴스", "news", "보도", "발표", "announcement", "기사"]
        return patterns.contains { text.contains($0) }
    }
    
    private func containsProductPatterns(_ text: String) -> Bool {
        let patterns = ["상품", "product", "제품", "모델", "model", "사양", "spec"]
        return patterns.contains { text.contains($0) }
    }
}

// MARK: - Content Structuring Methods
extension AIManager {
    private func structureLyrics(_ text: String) -> [String] {
        let lines = text.components(separatedBy: .newlines)
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .filter { !$0.isEmpty }
        
        var sections: [String] = []
        var currentVerse: [String] = []
        var verseCount = 1
        
        for line in lines {
            if line.isEmpty {
                if !currentVerse.isEmpty {
                    sections.append("## \(verseCount)절\n\n" + currentVerse.joined(separator: "\n"))
                    currentVerse = []
                    verseCount += 1
                }
            } else {
                currentVerse.append(line)
            }
        }
        
        if !currentVerse.isEmpty {
            sections.append("## \(verseCount)절\n\n" + currentVerse.joined(separator: "\n"))
        }
        
        return sections
    }
    
    private func structureRecipe(_ text: String) -> [String] {
        var sections: [String] = []
        let lines = text.components(separatedBy: .newlines)
        
        var ingredients: [String] = []
        var instructions: [String] = []
        var currentSection = ""
        
        for line in lines {
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            guard !trimmed.isEmpty else { continue }
            
            if trimmed.contains("재료") || trimmed.contains("ingredient") {
                currentSection = "ingredients"
                continue
            } else if trimmed.contains("조리법") || trimmed.contains("만드는") || trimmed.contains("방법") {
                currentSection = "instructions"
                continue
            }
            
            switch currentSection {
            case "ingredients":
                ingredients.append("- " + trimmed)
            case "instructions":
                instructions.append(trimmed)
            default:
                instructions.append(trimmed)
            }
        }
        
        if !ingredients.isEmpty {
            sections.append("## 재료\n\n" + ingredients.joined(separator: "\n"))
        }
        
        if !instructions.isEmpty {
            let numberedInstructions = instructions.enumerated().map { index, instruction in
                "\(index + 1). \(instruction)"
            }
            sections.append("## 조리법\n\n" + numberedInstructions.joined(separator: "\n"))
        }
        
        return sections
    }
    
    private func structureClothing(_ text: String) -> [String] {
        var sections: [String] = []
        let lines = text.components(separatedBy: .newlines)
        
        var info: [String: String] = [:]
        
        for line in lines {
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            guard !trimmed.isEmpty else { continue }
            
            if trimmed.contains("브랜드") || trimmed.contains("brand") {
                info["브랜드"] = trimmed
            } else if trimmed.contains("사이즈") || trimmed.contains("size") {
                info["사이즈"] = trimmed
            } else if trimmed.contains("색상") || trimmed.contains("color") {
                info["색상"] = trimmed
            } else if trimmed.contains("원") || trimmed.contains("₩") || trimmed.contains("$") {
                info["가격"] = trimmed
            }
        }
        
        if !info.isEmpty {
            let infoSection = info.map { "**\($0.key)**: \($0.value)" }.joined(separator: "\n")
            sections.append("## 상품 정보\n\n" + infoSection)
        }
        
        return sections.isEmpty ? [text] : sections
    }
    
    private func structureMenu(_ text: String) -> [String] {
        let lines = text.components(separatedBy: .newlines)
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .filter { !$0.isEmpty }
        
        var menuItems: [String] = []
        
        for line in lines {
            if line.range(of: "[0-9,]+원", options: .regularExpression) != nil {
                menuItems.append("- " + line)
            } else if !line.isEmpty {
                menuItems.append("- " + line)
            }
        }
        
        return ["## 메뉴\n\n" + menuItems.joined(separator: "\n")]
    }
    
    private func structureContact(_ text: String) -> [String] {
        var contactInfo: [String] = []
        let lines = text.components(separatedBy: .newlines)
        
        for line in lines {
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            guard !trimmed.isEmpty else { continue }
            
            if trimmed.range(of: "[0-9]{2,3}-[0-9]{3,4}-[0-9]{4}", options: .regularExpression) != nil {
                contactInfo.append("📞 **전화번호**: \(trimmed)")
            } else if trimmed.range(of: "[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}", options: .regularExpression) != nil {
                contactInfo.append("📧 **이메일**: \(trimmed)")
            } else {
                contactInfo.append("👤 **이름**: \(trimmed)")
            }
        }
        
        return ["## 연락처 정보\n\n" + contactInfo.joined(separator: "\n")]
    }
    
    private func structureEvent(_ text: String) -> [String] {
        let lines = text.components(separatedBy: .newlines)
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .filter { !$0.isEmpty }
        
        var eventInfo: [String] = []
        
        for line in lines {
            if line.contains("시간") || line.contains("time") {
                eventInfo.append("🕐 **시간**: \(line)")
            } else if line.contains("날짜") || line.contains("date") {
                eventInfo.append("📅 **날짜**: \(line)")
            } else if line.contains("장소") || line.contains("location") {
                eventInfo.append("📍 **장소**: \(line)")
            } else {
                eventInfo.append("📋 **내용**: \(line)")
            }
        }
        
        return ["## 이벤트 정보\n\n" + eventInfo.joined(separator: "\n")]
    }
    
    private func structureNews(_ text: String) -> [String] {
        let lines = text.components(separatedBy: .newlines)
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .filter { !$0.isEmpty }
        
        var sections: [String] = []
        
        if let firstLine = lines.first, firstLine.count < 100 {
            sections.append("## 제목\n\n" + firstLine)
            
            if lines.count > 1 {
                let content = Array(lines.dropFirst()).joined(separator: "\n")
                sections.append("## 내용\n\n" + content)
            }
        } else {
            sections.append("## 기사 내용\n\n" + lines.joined(separator: "\n"))
        }
        
        return sections
    }
    
    private func structureProduct(_ text: String) -> [String] {
        let lines = text.components(separatedBy: .newlines)
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .filter { !$0.isEmpty }
        
        var productInfo: [String] = []
        
        for line in lines {
            if line.contains("모델") || line.contains("model") {
                productInfo.append("🔤 **모델**: \(line)")
            } else if line.contains("사양") || line.contains("spec") {
                productInfo.append("⚙️ **사양**: \(line)")
            } else if line.contains("가격") || line.contains("원") || line.contains("₩") {
                productInfo.append("💰 **가격**: \(line)")
            } else {
                productInfo.append("📋 **설명**: \(line)")
            }
        }
        
        return ["## 상품 정보\n\n" + productInfo.joined(separator: "\n")]
    }
    
    private func structureGeneral(_ text: String) -> [String] {
        let lines = text.components(separatedBy: .newlines)
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .filter { !$0.isEmpty }
        
        var sections: [String] = []
        var currentSection: [String] = []
        
        for line in lines {
            if isLikelyTitle(line) {
                if !currentSection.isEmpty {
                    sections.append(currentSection.joined(separator: "\n"))
                    currentSection = []
                }
                currentSection.append("## \(line)")
            } else {
                currentSection.append(line)
            }
        }
        
        if !currentSection.isEmpty {
            sections.append(currentSection.joined(separator: "\n"))
        }
        
        return sections.isEmpty ? [text] : sections
    }
    
    private func isLikelyTitle(_ text: String) -> Bool {
        let titlePatterns = [
            "^[0-9]+\\.",
            "^[가-힣A-Za-z\\s]+:$",
            "^\\[.*\\]$",
        ]
        
        for pattern in titlePatterns {
            if text.range(of: pattern, options: .regularExpression) != nil {
                return true
            }
        }
        
        return text.count < 50 && text.count > 5
    }
}

// MARK: - Content Processors
struct SongLyricsProcessor: ContentProcessor {
    func process(_ text: String) -> String {
        // 가사의 특성에 맞게 처리 (반복 구간 인식, 절/후렴 구분 등)
        return text.replacingOccurrences(of: "\\s*\\([^)]*\\)\\s*", with: "", options: .regularExpression)
    }
    
    func getPrompt() -> String {
        return "이 텍스트를 노래 가사로 인식하고 절과 후렴구를 구분하여 정리해주세요."
    }
}

struct RecipeProcessor: ContentProcessor {
    func process(_ text: String) -> String {
        // 레시피 특성에 맞게 처리 (재료와 조리법 분리)
        return text
    }
    
    func getPrompt() -> String {
        return "이 텍스트를 요리 레시피로 인식하고 재료와 조리법을 명확히 구분하여 정리해주세요."
    }
}

struct ClothingProcessor: ContentProcessor {
    func process(_ text: String) -> String {
        // 의류 정보 특성에 맞게 처리
        return text
    }
    
    func getPrompt() -> String {
        return "이 텍스트를 의류 상품 정보로 인식하고 브랜드, 사이즈, 색상, 가격 등을 구조화하여 정리해주세요."
    }
}

struct MenuProcessor: ContentProcessor {
    func process(_ text: String) -> String {
        // 메뉴 특성에 맞게 처리
        return text
    }
    
    func getPrompt() -> String {
        return "이 텍스트를 메뉴로 인식하고 음식/음료명과 가격을 명확하게 정리해주세요."
    }
}

struct ContactProcessor: ContentProcessor {
    func process(_ text: String) -> String {
        // 연락처 특성에 맞게 처리
        return text
    }
    
    func getPrompt() -> String {
        return "이 텍스트를 연락처 정보로 인식하고 이름, 전화번호, 이메일 등을 구조화하여 정리해주세요."
    }
}

struct EventProcessor: ContentProcessor {
    func process(_ text: String) -> String {
        // 이벤트 특성에 맞게 처리
        return text
    }
    
    func getPrompt() -> String {
        return "이 텍스트를 이벤트/일정 정보로 인식하고 날짜, 시간, 장소, 내용을 구조화하여 정리해주세요."
    }
}

struct NewsProcessor: ContentProcessor {
    func process(_ text: String) -> String {
        // 뉴스 특성에 맞게 처리
        return text
    }
    
    func getPrompt() -> String {
        return "이 텍스트를 뉴스 기사로 인식하고 제목과 본문을 구분하여 정리해주세요."
    }
}

struct ProductProcessor: ContentProcessor {
    func process(_ text: String) -> String {
        // 상품 정보 특성에 맞게 처리
        return text
    }
    
    func getPrompt() -> String {
        return "이 텍스트를 상품 정보로 인식하고 모델명, 사양, 가격 등을 구조화하여 정리해주세요."
    }
}

struct GeneralTextProcessor: ContentProcessor {
    func process(_ text: String) -> String {
        // 일반 텍스트 처리
        return text
    }
    
    func getPrompt() -> String {
        return "이 텍스트를 일반적인 내용으로 인식하고 가독성 있게 정리해주세요."
    }
}

// MARK: - Supporting Types
struct TextAnalysisResult {
    let originalLength: Int
    let processedLength: Int
    let detectedSections: Int
    let confidence: Double
}
