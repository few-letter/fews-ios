import SwiftUI
import SafariServices
import StoreKit
import ComposableArchitecture
import DS

public struct SettingView: View {
    @Environment(\.requestReview) private var requestReview
    let store: StoreOf<SettingFeature>
    
    public init(store: StoreOf<SettingFeature>) {
        self.store = store
    }
    
    public var body: some View {
        WithPerceptionTracking {
            NavigationStack {
                ScrollView {
                    VStack(spacing: DS.Spacing.lg) {
                        // 헤더 섹션
                        VStack(spacing: DS.Spacing.md) {
                            Image(systemName: "gearshape.2.fill")
                                .font(.system(size: 60))
                                .foregroundColor(DS.Colors.primary)
                            
                            Text("Settings")
                                .font(DS.Typography.h2)
                                .foregroundColor(DS.Colors.content1)
                            
                            Text("Manage your KPT app preferences")
                                .font(DS.Typography.bodyRegular)
                                .foregroundColor(DS.Colors.content2)
                                .multilineTextAlignment(.center)
                        }
                        .padding(.top, DS.Spacing.xl)
                        
                        // 설정 옵션들
                        VStack(spacing: DS.Spacing.md) {
                            // App Store 리뷰
                            DSCard(cardShadow: .sm, isPressable: true, onPress: {
                                Task { await requestReview() }
                            }) {
                                DSCardBody {
                                    HStack(spacing: DS.Spacing.md) {
                                        Image(systemName: "star.fill")
                                            .font(.system(size: 24))
                                            .foregroundColor(DS.Colors.warning)
                                            .frame(width: 40, height: 40)
                                            .background(DS.Colors.warning.opacity(0.1))
                                            .clipShape(Circle())
                                        
                                        VStack(alignment: .leading, spacing: DS.Spacing.xs) {
                                            Text("Rate Our App")
                                                .font(DS.Typography.bodyMedium)
                                                .foregroundColor(DS.Colors.content1)
                                            
                                            Text("Help us improve by leaving a review")
                                                .font(DS.Typography.smallRegular)
                                                .foregroundColor(DS.Colors.content2)
                                        }
                                        
                                        Spacer()
                                        
                                        Image(systemName: "chevron.right")
                                            .font(.system(size: 14, weight: .medium))
                                            .foregroundColor(DS.Colors.content3)
                                    }
                                }
                            }
                            
                            // 기능 요청
                            DSCard(cardShadow: .sm, isPressable: true, onPress: {
                                store.send(.featureRequestsTapped)
                            }) {
                                DSCardBody {
                                    HStack(spacing: DS.Spacing.md) {
                                        Image(systemName: "lightbulb.fill")
                                            .font(.system(size: 24))
                                            .foregroundColor(DS.Colors.success)
                                            .frame(width: 40, height: 40)
                                            .background(DS.Colors.success.opacity(0.1))
                                            .clipShape(Circle())
                                        
                                        VStack(alignment: .leading, spacing: DS.Spacing.xs) {
                                            Text("Feature Requests")
                                                .font(DS.Typography.bodyMedium)
                                                .foregroundColor(DS.Colors.content1)
                                            
                                            Text("Suggest new features and improvements")
                                                .font(DS.Typography.smallRegular)
                                                .foregroundColor(DS.Colors.content2)
                                        }
                                        
                                        Spacer()
                                        
                                        Image(systemName: "chevron.right")
                                            .font(.system(size: 14, weight: .medium))
                                            .foregroundColor(DS.Colors.content3)
                                    }
                                }
                            }
                        }
                        
                        Spacer(minLength: DS.Spacing.xl)
                    }
                    .padding(.horizontal, DS.Spacing.md)
                }
                .background(DS.Colors.background)
                .navigationBarTitleDisplayMode(.inline)
            }
            .sheet(
                isPresented: Binding(
                    get: { store.safariURL != nil },
                    set: { _ in store.send(.featureRequestsTapped) }
                )
            ) {
                if let url = store.safariURL {
                    SafariView(url: url)
                }
            }
        }
    }
}

private struct SafariView: UIViewControllerRepresentable {
    let url: URL

    func makeUIViewController(context: UIViewControllerRepresentableContext<SafariView>) -> SFSafariViewController {
        return SFSafariViewController(url: url)
    }

    func updateUIViewController(_ uiViewController: SFSafariViewController, context: UIViewControllerRepresentableContext<SafariView>) {
    }
} 
