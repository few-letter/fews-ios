import SwiftUI
import SwiftData
import UIKit
import AppTrackingTransparency
import CloudKit
import FirebaseCore
import ComposableArchitecture

@Reducer
public struct AppFeature {
    @ObservableState
    public struct State {
        var mainTab: MainTabFeature.State = .init()
        
        public init() {}
    }
    
    public enum Action {
        case mainTab(MainTabFeature.Action)
        case appDelegate(AppDelegateAction)
        
        public enum AppDelegateAction {
            case didFinishLaunching
            case didBecomeActive
        }
    }
    
    public init() {}
    
    @Dependency(\.modelContext) var modelContext
    
    public var body: some ReducerOf<Self> {
        Scope(state: \.mainTab, action: \.mainTab) {
            MainTabFeature()
        }
        
        Reduce { state, action in
            switch action {
            case .mainTab:
                return .none
                
            case .appDelegate(.didFinishLaunching):
                FirebaseApp.configure()
                
                // CloudKit 상태 확인
                CKContainer.default().accountStatus { (accountStatus, error) in
                    print("CloudKit 계정 상태: \(accountStatus.rawValue), 오류: \(String(describing: error))")
                }
                
                return .none
                
            case .appDelegate(.didBecomeActive):
                return .run { _ in
                    await ATTrackingManager.requestTrackingAuthorization(completionHandler: { _ in })
                }
            }
        }
    }
} 