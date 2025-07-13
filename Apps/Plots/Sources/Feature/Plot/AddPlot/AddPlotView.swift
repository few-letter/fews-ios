//
//  AddPlotView.swift
//  plotfolio
//
//  Created by 송영모 on 2023/05/21.
//

import SwiftUI
import ComposableArchitecture
import PhotosUI
import Vision
import AVFoundation

public struct AddPlotView: View {
    @Bindable public var store: StoreOf<AddPlotStore>
    
    @Environment(\.colorScheme) var colorScheme
    @State private var calendarId: UUID = UUID()
    @State private var isScrolled: Bool = false
    @State private var textEditorContent: String = ""
    @State private var selectedPhoto: PhotosPickerItem?
    @State private var showingImagePicker = false
    @State private var showingLiveCamera = false
    @State private var recognizedTexts: [RecognizedText] = []
    @State private var selectedImage: UIImage?
    @State private var showingTextSelectionSheet = false
    
    public var body: some View {
        VStack(spacing: 0) {
            fixedHeaderView
                .background(Color(UIColor.systemBackground))
                .shadow(color: .black.opacity(0.1), radius: 1, x: 0, y: 1)
            
            ScrollView(.vertical, showsIndicators: true) {
                VStack(spacing: 12) {
                    Rectangle()
                        .fill(Color.clear)
                        .frame(height: 10)
                    
                    quotesSection
                    
                    TextEditor(text: $store.plot.content)
                        .font(.body)
                        .frame(minHeight: 300)
                        .padding(.horizontal, 8)
                }
            }
            .background(Color(UIColor.systemBackground))
        }
        .navigationBarTitleDisplayMode(.inline)
        .onChange(of: store.plot.date) {
            calendarId = UUID()
        }
        .onChange(of: selectedPhoto) { _, newValue in
            if let selectedPhoto = newValue {
                loadImageAndRecognizeText(selectedPhoto)
            }
        }
        .sheet(isPresented: $showingTextSelectionSheet) {
            if let image = selectedImage {
                NavigationView {
                    TextSelectionView(image: image, recognizedTexts: recognizedTexts) { selectedText in
                        addQuote(with: selectedText)
                    }
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .navigationBarTrailing) {
                            Button("완료") {
                                showingTextSelectionSheet = false
                            }
                        }
                    }
                }
            }
        }
        .sheet(isPresented: $showingLiveCamera) {
            NavigationView {
                LiveCameraView { selectedText in
                    addQuote(with: selectedText)
                }
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("완료") {
                            showingLiveCamera = false
                        }
                    }
                }
            }
        }
    }
    
    private var fixedHeaderView: some View {
        VStack(spacing: 8) {
            titleField
            
            HStack(spacing: 8) {
                plotControls
                Spacer()
                plotTypeMenu
            }
        }
        .padding(12)
        .background(Color(UIColor.systemBackground))
    }
    
    private var titleField: some View {
        TextField("Title", text: $store.plot.title)
            .font(.title3)
            .fontWeight(.semibold)
    }
    
    private var plotControls: some View {
        HStack(spacing: 8) {
            starRatingView
            Text("\(store.plot.point, specifier: "%.1f")")
                .font(.footnote)
                .fontWeight(.semibold)
            resetButton
            pageProgressField
            datePicker
        }
    }
    
    private var pageProgressField: some View {
        HStack(spacing: 2) {
            TextField("123/374", text: Binding(
                get: {
                    let current = store.plot.currentPage ?? 0
                    let total = store.plot.totalPages ?? 0
                    if current == 0 && total == 0 {
                        return ""
                    }
                    return "\(current)/\(total)"
                },
                set: { newValue in
                    let components = newValue.split(separator: "/")
                    let currentPage = components.first.flatMap { Int($0) }
                    let totalPages = components.count > 1 ? Int(components[1]) : nil
                    
                    store.send(.binding(.set(\.plot.currentPage, currentPage)))
                    store.send(.binding(.set(\.plot.totalPages, totalPages)))
                }
            ))
            .textFieldStyle(PlainTextFieldStyle())
            .font(.caption2)
            .frame(width: 50)
            .multilineTextAlignment(.center)
            .overlay(
                RoundedRectangle(cornerRadius: 4)
                    .stroke(Color.gray.opacity(0.3), lineWidth: 1)
            )
            .padding(2)
            
            Text("p")
                .font(.caption2)
                .foregroundColor(.secondary)
        }
    }
    
    private var starRatingView: some View {
        StarRatingView(
            point: store.plot.point,
            onPointChanged: { point in
                store.send(.binding(.set(\.plot.point, point)))
            }
        )
    }
    
    private var resetButton: some View {
        Button(action: {
            store.send(.binding(.set(\.plot.point, 0)), animation: .default)
        }, label: {
            Image(systemName: "arrow.counterclockwise")
                .imageScale(.small)
                .foregroundColor(Color(.label))
        })
    }
    
    private var datePicker: some View {
        DatePicker(
            "",
            selection: $store.plot.date,
            displayedComponents: [.date]
        )
        .id(calendarId)
    }
    
    private var plotTypeMenu: some View {
        Menu {
            ForEach(PlotType.allCases, id: \.self) { type in
                Button(action: {
                    store.send(.binding(.set(\.plot.type, type.rawValue)), animation: .default)
                }) {
                    HStack {
                        Text(type.title)
                        if store.plot.type == type.rawValue {
                            Image(systemName: "checkmark")
                        }
                    }
                }
            }
        } label: {
            HStack(spacing: 4) {
                if let selectedType = PlotType.allCases.first(where: { $0.rawValue == store.plot.type }) {
                    Text(selectedType.title)
                        .font(.footnote)
                        .fontWeight(.medium)
                } else {
                    Text("Type")
                        .font(.footnote)
                        .fontWeight(.medium)
                        .foregroundColor(.secondary)
                }
                Image(systemName: "chevron.down")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal, 6)
            .padding(.vertical, 4)
            .background(Color.gray.opacity(0.1))
            .cornerRadius(6)
        }
    }
    
    private var quotesSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("감명 깊었던 한 줄")
                    .font(.headline)
                    .fontWeight(.semibold)
                Spacer()
                HStack(spacing: 6) {
                    PhotosPicker(selection: $selectedPhoto, matching: .images) {
                        Image(systemName: "photo.fill")
                            .foregroundColor(.blue)
                            .font(.title3)
                    }
                    
                    Button(action: {
                        showingLiveCamera = true
                    }) {
                        Image(systemName: "camera.fill")
                            .foregroundColor(.blue)
                            .font(.title3)
                    }
                    
                    Button(action: {
                        let newQuote = QuoteModel()
                        var updatedQuotes = store.plot.quotes
                        updatedQuotes.append(newQuote)
                        store.send(.binding(.set(\.plot.quotes, updatedQuotes)))
                    }) {
                        Image(systemName: "plus.circle.fill")
                            .foregroundColor(.blue)
                            .font(.title3)
                    }
                }
            }
            .padding(.horizontal, 12)
            
            if store.plot.quotes.isEmpty {
                VStack(spacing: 6) {
                    Image(systemName: "quote.bubble")
                        .font(.largeTitle)
                        .foregroundColor(.secondary)
                    Text("아직 추가된 인용구가 없습니다")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    Text("+ 버튼을 눌러 감명 깊었던 한 줄을 추가해보세요")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(Color.gray.opacity(0.05))
                .cornerRadius(10)
                .padding(.horizontal, 12)
            } else {
                ForEach(store.plot.quotes, id: \.id) { quote in
                    quoteRow(for: quote)
                }
            }
        }
    }
    
    private func quoteRow(for quote: QuoteModel) -> some View {
        HStack(spacing: 6) {
            HStack(spacing: 2) {
                Text("p.")
                    .font(.caption2)
                    .foregroundColor(.secondary)
                TextField("", value: Binding(
                    get: { quote.page },
                    set: { newValue in
                        var updatedQuotes = store.plot.quotes
                        if let index = updatedQuotes.firstIndex(where: { $0.id == quote.id }) {
                            updatedQuotes[index].page = newValue
                            store.send(.binding(.set(\.plot.quotes, updatedQuotes)))
                        }
                    }
                ), format: .number)
                .textFieldStyle(PlainTextFieldStyle())
                .font(.caption2)
                .frame(width: 30)
                .keyboardType(.numberPad)
                .multilineTextAlignment(.leading)
                .overlay(
                    RoundedRectangle(cornerRadius: 4)
                        .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                )
                .padding(2)
            }
            .frame(width: 50)
            
            TextField("감명 깊었던 한 줄", text: Binding(
                get: { quote.quote },
                set: { newValue in
                    var updatedQuotes = store.plot.quotes
                    if let index = updatedQuotes.firstIndex(where: { $0.id == quote.id }) {
                        updatedQuotes[index].quote = newValue
                        store.send(.binding(.set(\.plot.quotes, updatedQuotes)))
                    }
                }
            ))
            .textFieldStyle(PlainTextFieldStyle())
            .font(.subheadline)
            .lineLimit(1)
            .truncationMode(.tail)
            
            Button(action: {
                deleteQuote(quote)
            }) {
                Image(systemName: "trash.fill")
                    .foregroundColor(.red)
                    .font(.caption)
            }
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(Color(UIColor.secondarySystemBackground))
        .cornerRadius(6)
        .padding(.horizontal, 12)
    }
    
    private func loadImageAndRecognizeText(_ photoItem: PhotosPickerItem) {
        Task {
            guard let data = try? await photoItem.loadTransferable(type: Data.self),
                  let uiImage = UIImage(data: data) else {
                return
            }
            
            selectedImage = uiImage
            
            guard let cgImage = uiImage.cgImage else { return }
            
            let request = VNRecognizeTextRequest { request, error in
                guard let observations = request.results as? [VNRecognizedTextObservation] else {
                    return
                }
                
                let recognized = observations.compactMap { observation -> RecognizedText? in
                    guard let topCandidate = observation.topCandidates(1).first else { return nil }
                    return RecognizedText(text: topCandidate.string, boundingBox: observation.boundingBox)
                }
                
                DispatchQueue.main.async {
                    recognizedTexts = recognized
                    showingTextSelectionSheet = true
                }
            }
            
            request.recognitionLevel = VNRequestTextRecognitionLevel.accurate
            request.recognitionLanguages = ["ko-KR", "en-US"]
            
            let requestHandler = VNImageRequestHandler(cgImage: cgImage, options: [:])
            do {
                try requestHandler.perform([request])
            } catch {
                print("Failed to perform text recognition: \(error)")
            }
        }
    }
    
    private func addQuote(with text: String) {
        if !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            let newQuote = QuoteModel(quote: text.trimmingCharacters(in: .whitespacesAndNewlines))
            var updatedQuotes = store.plot.quotes
            updatedQuotes.append(newQuote)
            store.send(.binding(.set(\.plot.quotes, updatedQuotes)))
        }
        selectedPhoto = nil
        selectedImage = nil
        recognizedTexts = []
        showingTextSelectionSheet = false
        showingLiveCamera = false
    }
    
    private func deleteQuote(_ quote: QuoteModel) {
        var updatedQuotes = store.plot.quotes
        updatedQuotes.removeAll { $0.id == quote.id }
        store.send(.binding(.set(\.plot.quotes, updatedQuotes)))
    }
}

struct RecognizedText {
    let text: String
    let boundingBox: CGRect
}

struct TextSelectionView: View {
    let image: UIImage
    let recognizedTexts: [RecognizedText]
    let onSelect: (String) -> Void
    
    var body: some View {
        GeometryReader { geometry in
            let originalSize = image.size
            let scale = min(geometry.size.width / originalSize.width, geometry.size.height / originalSize.height)
            let displayedWidth = originalSize.width * scale
            let displayedHeight = originalSize.height * scale
            let offsetX = (geometry.size.width - displayedWidth) / 2
            let offsetY = (geometry.size.height - displayedHeight) / 2
            
            Image(uiImage: image)
                .resizable()
                .scaledToFit()
                .frame(width: geometry.size.width, height: geometry.size.height)
                .overlay(
                    ZStack {
                        ForEach(recognizedTexts, id: \.text) { recText in
                            let uiX = recText.boundingBox.origin.x * displayedWidth + offsetX
                            let uiY = (1 - recText.boundingBox.origin.y - recText.boundingBox.height) * displayedHeight + offsetY
                            let width = recText.boundingBox.width * displayedWidth
                            let height = recText.boundingBox.height * displayedHeight
                            
                            Rectangle()
                                .fill(Color.blue.opacity(0.3))
                                .frame(width: width, height: height)
                                .position(x: uiX + width / 2, y: uiY + height / 2)
                                .onTapGesture {
                                    onSelect(recText.text)
                                }
                        }
                    }
                )
        }
        .navigationTitle("텍스트 선택")
    }
}

struct LiveCameraView: View {
    @StateObject private var cameraModel = CameraModel()
    @State private var recognizedTexts: [RecognizedText] = []
    @State private var bufferSize: CGSize = .zero
    let onSelect: (String) -> Void
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                if let previewLayer = cameraModel.previewLayer {
                    CameraPreview(previewLayer: previewLayer)
                        .frame(width: geometry.size.width, height: geometry.size.height)
                        .onAppear {
                            previewLayer.frame = CGRect(origin: .zero, size: geometry.size)
                            cameraModel.startSession()
                            cameraModel.onTextRecognized = { texts, size in
                                recognizedTexts = texts
                                bufferSize = size
                            }
                        }
                        .onDisappear {
                            cameraModel.stopSession()
                        }
                    
                    if bufferSize != .zero {
                        let scale = min(geometry.size.width / bufferSize.width, geometry.size.height / bufferSize.height)
                        let displayedWidth = bufferSize.width * scale
                        let displayedHeight = bufferSize.height * scale
                        let offsetX = (geometry.size.width - displayedWidth) / 2
                        let offsetY = (geometry.size.height - displayedHeight) / 2
                        
                        ZStack {
                            ForEach(recognizedTexts, id: \.text) { recText in
                                let uiX = recText.boundingBox.origin.x * displayedWidth + offsetX
                                let uiY = (1 - recText.boundingBox.origin.y - recText.boundingBox.height) * displayedHeight + offsetY
                                let width = recText.boundingBox.width * displayedWidth
                                let height = recText.boundingBox.height * displayedHeight
                                
                                Rectangle()
                                    .fill(Color.blue.opacity(0.3))
                                    .frame(width: width, height: height)
                                    .position(x: uiX + width / 2, y: uiY + height / 2)
                                    .onTapGesture {
                                        onSelect(recText.text)
                                    }
                            }
                        }
                    }
                } else {
                    Color.black
                        .frame(width: geometry.size.width, height: geometry.size.height)
                }
            }
        }
        .ignoresSafeArea()
        .navigationTitle("라이브 카메라")
    }
}

class CameraModel: NSObject, ObservableObject, AVCaptureVideoDataOutputSampleBufferDelegate {
    let captureSession = AVCaptureSession()
    var previewLayer: AVCaptureVideoPreviewLayer?
    var onTextRecognized: (([RecognizedText], CGSize) -> Void)?
    
    override init() {
        super.init()
        setupCamera()
    }
    
    private func setupCamera() {
        guard let backCamera = AVCaptureDevice.default(for: .video) else { return }
        
        do {
            let input = try AVCaptureDeviceInput(device: backCamera)
            if captureSession.canAddInput(input) {
                captureSession.addInput(input)
            }
            
            let output = AVCaptureVideoDataOutput()
            output.setSampleBufferDelegate(self, queue: DispatchQueue(label: "videoQueue"))
            if captureSession.canAddOutput(output) {
                captureSession.addOutput(output)
            }
            
            if let connection = output.connection(with: .video) {
                connection.videoOrientation = .portrait
            }
            
            previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
            previewLayer?.videoGravity = .resizeAspectFill
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func startSession() {
        DispatchQueue.global(qos: .background).async {
            if !self.captureSession.isRunning {
                self.captureSession.startRunning()
            }
        }
    }
    
    func stopSession() {
        DispatchQueue.global(qos: .background).async {
            if self.captureSession.isRunning {
                self.captureSession.stopRunning()
            }
        }
    }
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
        
        let bufferWidth = CGFloat(CVPixelBufferGetWidth(pixelBuffer))
        let bufferHeight = CGFloat(CVPixelBufferGetHeight(pixelBuffer))
        let bufferSize = CGSize(width: bufferWidth, height: bufferHeight)
        
        let request = VNRecognizeTextRequest { request, error in
            guard let observations = request.results as? [VNRecognizedTextObservation] else { return }
            
            let recognized = observations.compactMap { observation -> RecognizedText? in
                guard let topCandidate = observation.topCandidates(1).first else { return nil }
                return RecognizedText(text: topCandidate.string, boundingBox: observation.boundingBox)
            }
            
            DispatchQueue.main.async {
                self.onTextRecognized?(recognized, bufferSize)
            }
        }
        
        request.recognitionLevel = VNRequestTextRecognitionLevel.accurate
        request.recognitionLanguages = ["ko-KR", "en-US"]
        
        let requestHandler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, options: [:])
        do {
            try requestHandler.perform([request])
        } catch {
            print("Failed to perform text recognition: \(error)")
        }
    }
}

struct CameraPreview: UIViewRepresentable {
    let previewLayer: AVCaptureVideoPreviewLayer
    
    func makeUIView(context: Context) -> UIView {
        let view = UIView()
        view.layer.addSublayer(previewLayer)
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
        previewLayer.frame = uiView.bounds
    }
}

struct StarRatingView: View {
    let point: Double
    let onPointChanged: (Double) -> Void
    
    var body: some View {
        let stars = HStack(spacing: 0) {
            ForEach(0..<5, id: \.self) { _ in
                Image(systemName: "star.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            }
        }
        
        stars
            .contentShape(Rectangle())
            .gesture(dragGesture)
            .frame(width: 80)
            .overlay(starOverlay(stars: stars))
            .foregroundColor(.gray)
    }
    
    private var dragGesture: some Gesture {
        DragGesture()
            .onChanged { value in
                let scaledX = max(0, min(100, value.location.x))
                let newPoint = round(scaledX / 100.0 * 5 * 10) / 10
                onPointChanged(newPoint)
            }
    }
    
    private func starOverlay(stars: some View) -> some View {
        GeometryReader { geometry in
            let width = point / 5.0 * geometry.size.width
            ZStack(alignment: .leading) {
                Rectangle()
                    .frame(width: width)
                    .foregroundColor(.yellow)
            }
        }
        .mask(stars)
    }
}
