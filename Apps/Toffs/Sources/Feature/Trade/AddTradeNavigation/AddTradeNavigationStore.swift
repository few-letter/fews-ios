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
public struct AddTradeNavigationStore {
    @Reducer
    public enum Path {}
    
    public enum AddTradeType {
        case new(ticker: Ticker, selectedDate: Date)
        case edit(trade: TradeModel)
    }
    
    @ObservableState
    public struct State {
        public var path: StackState<Path.State>

        public var trade: TradeModel
        public var trades: [TradeModel] = []
        
        public var selectedPhotos: [PhotosPickerItem] = []
        public var isLoadingImages: Bool = false
        public var isShowingImageDetail: Bool = false
        public var selectedImageIndex: Int = 0
        
        public var isFormValid: Bool {
            trade.price > 0 && trade.quantity > 0
        }
        
        public init(
            path: StackState<Path.State> = .init(),
            addTradeType: AddTradeType
        ) {
            self.path = path
            
            switch addTradeType {
            case .new(let ticker, let selectedDate):
                self.trade = .init(date: selectedDate, ticker: ticker)
            case .edit(let trade):
                self.trade = trade
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
        
        case photosSelected([PhotosPickerItem])
        case loadImagesFromPhotos
        case imagesLoaded([UIImage])
        case removeImage(Int)
        case showImageDetail(Int)
        case hideImageDetail
        
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
                let ticker = state.trade.ticker
                let trades = tradeClient.fetches(ticker: ticker)
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
