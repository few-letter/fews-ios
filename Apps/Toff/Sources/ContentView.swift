import SwiftUI
import DS

struct ContentView: View {
    var body: some View {
        VStack(spacing: DS.Spacing.lg) {
            Image(systemName: "star")
                .imageScale(.large)
                .foregroundStyle(DS.Colors.accent)
            
            Text("Welcome to Toff!")
                .font(DS.Typography.title1)
                .foregroundColor(DS.Colors.accent)
            
            DSCard {
                VStack(spacing: DS.Spacing.md) {
                    Text("Toff App")
                        .font(DS.Typography.headline)
                    
                    Text("이것은 Toff 앱입니다.")
                        .font(DS.Typography.body)
                        .multilineTextAlignment(.center)
                }
            }
            
            VStack(spacing: DS.Spacing.sm) {
                DSPrimaryButton(title: "시작하기") {
                    print("시작하기 button tapped")
                }
                
                DSSecondaryButton(title: "설정") {
                    print("설정 button tapped")
                }
            }
        }
        .padding(DS.Spacing.lg)
        .background(DS.Colors.background)
    }
}

#Preview {
    ContentView()
} 