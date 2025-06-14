import SwiftUI

@main
struct ToffApp: App {
    var body: some Scene {
        WindowGroup {
            CollapsibleCalendarView { date in
                DemoCalendarItem.sampleItems(for: date)
            }
            .ignoresSafeArea(.all)
        }
    }
}
