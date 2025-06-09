import XCTest
@testable import FewCuts

final class FewCutsTests: XCTestCase {
    
    func testVideoProjectCreation() {
        let project = VideoProject(name: "Test Project")
        
        XCTAssertEqual(project.name, "Test Project")
        XCTAssertNotNil(project.id)
        XCTAssertEqual(project.duration, 0)
        XCTAssertNil(project.thumbnailData)
    }
    
    func testVideoClipCreation() {
        let url = URL(string: "file://test.mp4")!
        let clip = VideoClip(name: "Test Clip", url: url)
        
        XCTAssertEqual(clip.name, "Test Clip")
        XCTAssertEqual(clip.url, url)
        XCTAssertEqual(clip.startTime, 0)
        XCTAssertEqual(clip.endTime, 0)
        XCTAssertEqual(clip.order, 0)
    }
    
    func testTimeIntervalFormatting() {
        let time: TimeInterval = 125 // 2분 5초
        XCTAssertEqual(time.formattedTime, "02:05")
        
        let shortTime: TimeInterval = 30 // 30초
        XCTAssertEqual(shortTime.formattedTime, "00:30")
    }
} 