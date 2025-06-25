//
//  TradeNavigationStore.swift
//  Toff
//
//  Created by 송영모 on 6/16/25.
//

import Foundation
import ComposableArchitecture
import UIKit
import PhotosUI
import _PhotosUI_SwiftUI

@Reducer
public struct TradeNavigationStore {
    @Reducer
    public enum Path {}
    
    @ObservableState
    public struct State {
        public var path: StackState<Path.State>

        public let ticker: Ticker
        public var trade: TradeModel
        public var trades: [TradeModel] = []
        
        // 이미지 관리
        public var selectedPhotos: [PhotosPickerItem] = []
        public var isLoadingImages: Bool = false
        
        // 이미지 상세보기
        public var isShowingImageDetail: Bool = false
        public var selectedImageIndex: Int = 0
        
        public var isFormValid: Bool {
            trade.price > 0 && trade.quantity > 0
        }
        
        public init(
            path: StackState<Path.State> = .init(),
            ticker: Ticker,
            date: Date,
            trade: TradeModel? = nil
        ) {
            self.path = path
            self.ticker = ticker
            
            if let trade {
                self.trade = trade
            } else {
                self.trade = TradeModel(
                    date: date,
                    ticker: ticker
                )
            }
        }
    }
    
    public enum Action: BindableAction {
        case binding(BindingAction<State>)
        
        case onAppear
        
        case fetch
        case fetched([TradeModel])
        
        case cancelButtonTapped
        case saveButtonTapped
        
        // 이미지 관련 액션
        case photosSelected([PhotosPickerItem])
        case loadImagesFromPhotos
        case imagesLoaded([UIImage])
        case removeImage(Int) // 이미지 인덱스로 제거
        case showImageDetail(Int) // 이미지 상세보기 표시
        case hideImageDetail // 이미지 상세보기 숨김
        
        case path(StackActionOf<Path>)
        
        case delegate(Delegate)
        
        public enum Delegate {
            case requestDismiss
            case requestSaved
        }
    }
    
    public init() {}
    
    @Dependency(\.tradeClient) private var tradeClient
    
    public var body: some ReducerOf<Self> {
        BindingReducer()
        
        Reduce<State, Action> { state, action in
            switch action {
            case .binding:
                return .none
                
            case .onAppear:
                return .send(.fetch)
                
            case .fetch:
                let trades = tradeClient.fetches(ticker: state.ticker)
                return .send(.fetched(trades))
                
            case .fetched(let trades):
                state.trades = trades
                return .none
                
            case .cancelButtonTapped:
                return .send(.delegate(.requestDismiss))
                
            case .saveButtonTapped:
                let savedTrade = tradeClient.createOrUpdate(trade: state.trade)
                state.trade = savedTrade
                return .send(.delegate(.requestSaved))
                
            // MARK: - 이미지 관련 액션 처리
            case .photosSelected(let photos):
                state.selectedPhotos = photos
                return .send(.loadImagesFromPhotos)
                
            case .loadImagesFromPhotos:
                state.isLoadingImages = true
                return .run { [photos = state.selectedPhotos] send in
                    var loadedImages: [UIImage] = []
                    
                    for photo in photos {
                        if let data = try? await photo.loadTransferable(type: Data.self),
                           let uiImage = UIImage(data: data) {
                            loadedImages.append(uiImage)
                        }
                    }
                    
                    await send(.imagesLoaded(loadedImages))
                }
                
            case .imagesLoaded(let images):
                state.isLoadingImages = false
                state.selectedPhotos = [] // 선택된 사진 목록 초기화
                
                // TradeClient를 통해 이미지 추가
                state.trade = tradeClient.addImages(images, to: state.trade)
                return .none
                
            case .removeImage(let index):
                state.trade = tradeClient.removeImage(at: index, from: state.trade)
                return .none
                
            case .showImageDetail(let index):
                state.selectedImageIndex = index
                state.isShowingImageDetail = true
                return .none
                
            case .hideImageDetail:
                state.isShowingImageDetail = false
                return .none

            case .path, .delegate:
                return .none
            }
        }
        .forEach(\.path, action: \.path)
    }
}
