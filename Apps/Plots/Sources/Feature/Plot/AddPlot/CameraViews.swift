//
//  LiveCameraTextScanner.swift
//  Full version – Aspect-Fit alignment for accurate overlays
//  Created 2025-07-15
//

import SwiftUI
import AVFoundation
import Vision

// MARK: - Model
struct RecognizedText: Identifiable {
    let id = UUID()
    let text: String
    let boundingBox: CGRect            // Vision normalized (origin: bottom-left)
    let confidence: Float
    let characterBoxes: [CGRect]
    let angle: Double                  // in degrees
    let lineNumber: Int

    init(text: String,
         boundingBox: CGRect,
         confidence: Float = 1.0,
         characterBoxes: [CGRect] = [],
         angle: Double = 0.0,
         lineNumber: Int = 0) {
        self.text = text
        self.boundingBox = boundingBox
        self.confidence = confidence
        self.characterBoxes = characterBoxes
        self.angle = angle
        self.lineNumber = lineNumber
    }
}

// MARK: - Live Camera View
struct LiveCameraView: View {
    @StateObject private var cameraModel = CameraModel()
    @State private var recognizedTexts: [RecognizedText] = []
    @State private var bufferSize: CGSize = .zero
    @State private var lastRecognitionTime = Date()

    let onSelect: (String) -> Void
    private let recognitionInterval: TimeInterval = 0.1

    var body: some View {
        VStack(spacing: 0) {
            textInputArea      // 상단 50%
            cameraArea         // 하단 50%
        }
        .navigationTitle("Text Scanner")
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: 상단 – 인식된 텍스트 리스트
    private var textInputArea: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Recognized Text")
                    .font(.headline)
                    .fontWeight(.semibold)
                Spacer()
                if !recognizedTexts.isEmpty {
                    Text("\(recognizedTexts.count) items")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            ScrollView {
                if recognizedTexts.isEmpty {
                    VStack(spacing: 12) {
                        Image(systemName: "text.viewfinder")
                            .font(.system(size: 40))
                            .foregroundColor(.secondary)
                        Text("Point camera at text to scan")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity, minHeight: 120)
                } else {
                    LazyVStack(alignment: .leading, spacing: 4) {
                        ForEach(groupTextsByLine(recognizedTexts), id: \.0) { lineNumber, texts in
                            VStack(alignment: .leading, spacing: 4) {
                                if lineNumber > 0 {
                                    Divider().padding(.vertical, 4)
                                }
                                ForEach(texts.sorted(by: { $0.boundingBox.minX < $1.boundingBox.minX })) { text in
                                    TextItemButton(text: text) {
                                        onSelect(text.text)
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        .padding(16)
        .frame(maxHeight: .infinity)
        .background(Color(UIColor.systemBackground))
    }

    private func groupTextsByLine(_ texts: [RecognizedText]) -> [(Int, [RecognizedText])] {
        let grouped = Dictionary(grouping: texts) { $0.lineNumber }
        return grouped.sorted { $0.key < $1.key }
    }

    // MARK: 하단 – 카메라 프리뷰
    private var cameraArea: some View {
        GeometryReader { geometry in
            ZStack {
                if let previewLayer = cameraModel.previewLayer {
                    activeCameraView(geometry: geometry, previewLayer: previewLayer)
                } else {
                    loadingCameraView
                }
            }
        }
        .frame(maxHeight: .infinity)
        .padding(16)
        .background(Color.black.opacity(0.05))
    }

    @ViewBuilder
    private func activeCameraView(
        geometry: GeometryProxy,
        previewLayer: AVCaptureVideoPreviewLayer
    ) -> some View {
        CameraPreview(previewLayer: previewLayer)
            .frame(width: geometry.size.width, height: geometry.size.height)
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .onAppear {
                // Aspect-Fit alignment
                previewLayer.frame = CGRect(origin: .zero, size: geometry.size)
                cameraModel.startSession()
                cameraModel.onTextRecognized = { texts, size in
                    let now = Date()
                    if now.timeIntervalSince(lastRecognitionTime) >= recognitionInterval {
                        recognizedTexts = texts
                        bufferSize = size
                        lastRecognitionTime = now
                    }
                }
            }
            .onDisappear { cameraModel.stopSession() }
            .overlay(
                ZStack {
                    if bufferSize != .zero && !recognizedTexts.isEmpty {
                        improvedTextOverlayView(geometry: geometry)
                    }
                    previewBorder(geometry: geometry)       // ★ 수정된 테두리
                    focusIndicatorOverlay
                }
            )
    }

    private var loadingCameraView: some View {
        RoundedRectangle(cornerRadius: 20)
            .fill(Color.black)
            .overlay(
                VStack(spacing: 16) {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .scaleEffect(1.2)
                    Text("Preparing camera...")
                        .foregroundColor(.white)
                        .font(.caption)
                }
            )
    }

    // MARK: – 화면에 맞춘 테두리
    @ViewBuilder
    private func previewBorder(geometry: GeometryProxy) -> some View {
        let params = calculateDisplayParameters(geometry: geometry)
        RoundedRectangle(cornerRadius: 20)
            .stroke(Color.blue.opacity(0.6), lineWidth: 3)
            .frame(width: params.width, height: params.height)
            .position(
                x: params.offsetX + params.width / 2,
                y: params.offsetY + params.height / 2
            )
    }

    private var focusIndicatorOverlay: some View {
        VStack {
            Spacer()
            HStack(spacing: 20) {
                Image(systemName: "viewfinder")
                    .font(.system(size: 24))
                    .foregroundColor(.white.opacity(0.8))
                Text("Align text horizontally")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.8))
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 10)
            .background(Color.black.opacity(0.6))
            .cornerRadius(10)
            .padding(.bottom, 20)
        }
    }

    // MARK: 오버레이 좌표 변환 (Aspect-Fit)
    @ViewBuilder
    private func improvedTextOverlayView(geometry: GeometryProxy) -> some View {
        let params = calculateDisplayParameters(geometry: geometry)
        ZStack {
            ForEach(recognizedTexts) { recText in
                Button(action: { onSelect(recText.text) }) {
                    ImprovedTextBox(
                        text: recText,
                        scale: params.scale,
                        displayedWidth: params.width,
                        displayedHeight: params.height,
                        offsetX: params.offsetX,
                        offsetY: params.offsetY
                    )
                }
            }
        }
    }

    private func calculateDisplayParameters(
        geometry: GeometryProxy
    ) -> (scale: CGFloat, width: CGFloat, height: CGFloat, offsetX: CGFloat, offsetY: CGFloat) {
        // Aspect-Fit: 화면 내에 전체 버퍼를 맞춤
        let scale = min(geometry.size.width / bufferSize.width,
                        geometry.size.height / bufferSize.height)
        let width  = bufferSize.width  * scale
        let height = bufferSize.height * scale
        let offsetX = (geometry.size.width  - width ) / 2
        let offsetY = (geometry.size.height - height) / 2
        return (scale, width, height, offsetX, offsetY)
    }
}

// MARK: - Text Item Button
struct TextItemButton: View {
    let text: RecognizedText
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 8) {
                Circle()
                    .fill(confidenceColor)
                    .frame(width: 6, height: 6)
                Text(text.text)
                    .font(.subheadline)
                    .foregroundColor(.primary)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.gray.opacity(0.05))
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
    }

    private var confidenceColor: Color {
        if text.confidence > 0.9 {
            return .green
        } else if text.confidence > 0.8 {
            return .orange
        } else {
            return .red
        }
    }
}

// MARK: - Improved Text Box Overlay
struct ImprovedTextBox: View {
    let text: RecognizedText
    let scale: CGFloat
    let displayedWidth: CGFloat
    let displayedHeight: CGFloat
    let offsetX: CGFloat
    let offsetY: CGFloat

    private var uiX: CGFloat {
        text.boundingBox.origin.x * displayedWidth + offsetX
    }
    private var uiY: CGFloat {
        let flippedY = 1.0 - text.boundingBox.origin.y - text.boundingBox.height
        return flippedY * displayedHeight + offsetY
    }
    private var width: CGFloat  { text.boundingBox.width  * displayedWidth }
    private var height: CGFloat { text.boundingBox.height * displayedHeight }
    private var position: CGPoint {
        CGPoint(x: uiX + width/2, y: uiY + height/2)
    }

    var body: some View {
        ZStack {
            if text.characterBoxes.count > 1 {
                complexBox
            } else {
                simpleBox
            }
        }
    }

    private var simpleBox: some View {
        Rectangle()
            .fill(Color.blue.opacity(0.2))
            .overlay(Rectangle().stroke(Color.blue, lineWidth: 2))
            .frame(width: width, height: height)
            .rotationEffect(.degrees(text.angle))
            .shadow(color: Color.blue.opacity(0.3), radius: 2)
            .position(position)
    }

    private var complexBox: some View {
        let pts = calculatePoints()
        let hull = convexHull(pts)
        return ZStack {
            Path { p in drawHullPath(&p, hull: hull) }
                .fill(Color.blue.opacity(0.2))
            Path { p in drawHullPath(&p, hull: hull) }
                .stroke(Color.blue, lineWidth: 2)
        }
        .shadow(color: Color.blue.opacity(0.3), radius: 2)
    }

    private func calculatePoints() -> [CGPoint] {
        var pts: [CGPoint] = []
        for box in text.characterBoxes {
            let x = box.origin.x * displayedWidth + offsetX
            let flippedY = 1.0 - box.origin.y - box.height
            let y = flippedY * displayedHeight + offsetY
            let w = box.width  * displayedWidth
            let h = box.height * displayedHeight
            pts += [
                CGPoint(x: x,     y: y),
                CGPoint(x: x + w, y: y),
                CGPoint(x: x + w, y: y + h),
                CGPoint(x: x,     y: y + h)
            ]
        }
        return pts
    }

    private func drawHullPath(_ path: inout Path, hull: [CGPoint]) {
        guard let first = hull.first else { return }
        path.move(to: first)
        hull.dropFirst().forEach { path.addLine(to: $0) }
        path.closeSubpath()
    }

    private func convexHull(_ points: [CGPoint]) -> [CGPoint] {
        guard points.count > 2 else { return points }
        let uniq = Array(Set(points))
        guard uniq.count > 2 else { return uniq }
        let sorted = uniq.sorted {
            if $0.y != $1.y { return $0.y < $1.y }
            return $0.x < $1.x
        }
        let start = sorted[0]
        let rest = sorted.dropFirst().sorted {
            let a1 = atan2($0.y-start.y, $0.x-start.x)
            let a2 = atan2($1.y-start.y, $1.x-start.x)
            if a1 == a2 {
                let d1 = pow($0.x-start.x,2)+pow($0.y-start.y,2)
                let d2 = pow($1.x-start.x,2)+pow($1.y-start.y,2)
                return d1 < d2
            }
            return a1 < a2
        }
        var hull: [CGPoint] = [start]
        for p in rest {
            while hull.count > 1 {
                let l = hull.last!, s = hull[hull.count-2]
                let cross = (l.x-s.x)*(p.y-s.y) - (l.y-s.y)*(p.x-s.x)
                if cross <= 0 { hull.removeLast() } else { break }
            }
            hull.append(p)
        }
        return hull
    }
}

// CGPoint → Hashable
extension CGPoint: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(x); hasher.combine(y)
    }
}

// MARK: - Camera Model
class CameraModel: NSObject, ObservableObject, AVCaptureVideoDataOutputSampleBufferDelegate {
    let captureSession = AVCaptureSession()
    var previewLayer: AVCaptureVideoPreviewLayer?
    var onTextRecognized: (([RecognizedText], CGSize) -> Void)?

    private let videoQueue = DispatchQueue(label: "videoQueue", qos: .userInitiated)
    private let recognitionQueue = DispatchQueue(label: "recognitionQueue", qos: .utility)
    private var isProcessing = false

    private var textEvidence: [String:(count:Int, boundingBox:CGRect, confidence:Float, angle:Double)] = [:]
    private let evidenceThreshold = 3
    private let maxEvidenceHistory = 30
    private var lastProcessedTime = Date()
    private let processingInterval: TimeInterval = 0.1

    override init() {
        super.init()
        setupCamera()
    }

    deinit {
        stopSession()
    }

    private func setupCamera() {
        captureSession.sessionPreset = .hd1920x1080

        guard let backCamera = AVCaptureDevice.default(for: .video) else { return }
        do {
            let input = try AVCaptureDeviceInput(device: backCamera)
            if captureSession.canAddInput(input) { captureSession.addInput(input) }

            let output = AVCaptureVideoDataOutput()
            output.videoSettings = [
                kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32BGRA
            ]
            output.setSampleBufferDelegate(self, queue: videoQueue)
            output.alwaysDiscardsLateVideoFrames = true
            if captureSession.canAddOutput(output) { captureSession.addOutput(output) }

            if let conn = output.connection(with: .video) {
                conn.videoOrientation = .portrait
                if conn.isVideoStabilizationSupported {
                    conn.preferredVideoStabilizationMode = .standard
                }
            }

            previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
            previewLayer?.videoGravity = .resizeAspect  // 🔸 Aspect-Fit

            try backCamera.lockForConfiguration()
            if backCamera.isFocusModeSupported(.continuousAutoFocus) {
                backCamera.focusMode = .continuousAutoFocus
                if backCamera.isAutoFocusRangeRestrictionSupported {
                    backCamera.autoFocusRangeRestriction = .near
                }
            }
            if backCamera.isExposureModeSupported(.continuousAutoExposure) {
                backCamera.exposureMode = .continuousAutoExposure
            }
            if backCamera.isWhiteBalanceModeSupported(.continuousAutoWhiteBalance) {
                backCamera.whiteBalanceMode = .continuousAutoWhiteBalance
            }
            backCamera.unlockForConfiguration()

        } catch {
            print("Camera setup failed:", error)
        }
    }

    func startSession() {
        recognitionQueue.async {
            if !self.captureSession.isRunning {
                self.captureSession.startRunning()
            }
        }
    }

    func stopSession() {
        recognitionQueue.async {
            if self.captureSession.isRunning {
                self.captureSession.stopRunning()
            }
        }
    }

    func captureOutput(
        _ output: AVCaptureOutput,
        didOutput sampleBuffer: CMSampleBuffer,
        from connection: AVCaptureConnection
    ) {
        let now = Date()
        guard !isProcessing,
              now.timeIntervalSince(lastProcessedTime) >= processingInterval else { return }
        isProcessing = true
        lastProcessedTime = now

        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
            isProcessing = false
            return
        }

        let w = CGFloat(CVPixelBufferGetWidth(pixelBuffer))
        let h = CGFloat(CVPixelBufferGetHeight(pixelBuffer))
        let size = CGSize(width: w, height: h)

        recognitionQueue.async { [weak self] in
            self?.performTextRecognition(on: pixelBuffer, bufferSize: size)
        }
    }

    private func performTextRecognition(on pixelBuffer: CVPixelBuffer, bufferSize: CGSize) {
        let request = VNRecognizeTextRequest { [weak self] req, err in
            defer { self?.isProcessing = false }
            guard let self = self,
                  let obs = req.results as? [VNRecognizedTextObservation],
                  err == nil else { return }

            var raws: [RecognizedText] = []
            for ob in obs {
                guard let cand = ob.topCandidates(1).first,
                      cand.confidence > 0.5 else { continue }
                let txt = cand.string.trimmingCharacters(in: .whitespacesAndNewlines)
                guard !txt.isEmpty else { continue }

                // characterBoxes
                var charBoxes: [CGRect] = []
                if let full = try? cand.boundingBox(for: txt.startIndex..<txt.endIndex) {
                    for i in 0..<txt.count {
                        let s = txt.index(txt.startIndex, offsetBy: i)
                        let e = txt.index(after: s)
                        if let cb = try? cand.boundingBox(for: s..<e) {
                            charBoxes.append(cb.boundingBox)
                        }
                    }
                }
                if charBoxes.isEmpty { charBoxes = [ob.boundingBox] }

                // angle
                let ang: Double
                if charBoxes.count > 1 {
                    let c1 = CGPoint(x: charBoxes.first!.midX, y: charBoxes.first!.midY)
                    let c2 = CGPoint(x: charBoxes.last!.midX,  y: charBoxes.last!.midY)
                    ang = atan2(c2.y-c1.y, c2.x-c1.x) * 180 / .pi
                } else { ang = 0 }

                raws.append(.init(text: txt,
                                  boundingBox: ob.boundingBox,
                                  confidence: cand.confidence,
                                  characterBoxes: charBoxes,
                                  angle: ang))
            }

            let grouped = self.sortAndGroupTexts(raws)
            let stable  = self.buildEvidence(from: grouped)
            DispatchQueue.main.async {
                self.onTextRecognized?(stable, bufferSize)
            }
        }

        // 🔸 Remove regionOfInterest to avoid ROI artifacts
        request.recognitionLevel = .accurate
        request.recognitionLanguages = ["en-US", "ko-KR"]
        request.usesLanguageCorrection = true
        request.automaticallyDetectsLanguage = true
        request.minimumTextHeight = 0.02

        do {
            try VNImageRequestHandler(cvPixelBuffer: pixelBuffer, options: [:])
                .perform([request])
        } catch {
            print("Text recognition failed:", error)
            isProcessing = false
        }
    }

    private func sortAndGroupTexts(_ texts: [RecognizedText]) -> [RecognizedText] {
        guard !texts.isEmpty else { return [] }
        let byY = texts.sorted { $0.boundingBox.midY > $1.boundingBox.midY }
        var result: [RecognizedText] = []
        var currentLine: [RecognizedText] = []
        var currentY = byY[0].boundingBox.midY
        var lineNum = 0
        let threshold: CGFloat = 0.02

        for t in byY {
            if abs(t.boundingBox.midY - currentY) < threshold {
                currentLine.append(t)
            } else {
                // flush
                for item in currentLine.sorted(by: { $0.boundingBox.minX < $1.boundingBox.minX }) {
                    result.append(RecognizedText(
                        text: item.text,
                        boundingBox: item.boundingBox,
                        confidence: item.confidence,
                        characterBoxes: item.characterBoxes,
                        angle: item.angle,
                        lineNumber: lineNum
                    ))
                }
                lineNum += 1
                currentLine = [t]
                currentY = t.boundingBox.midY
            }
        }
        // last line
        for item in currentLine.sorted(by: { $0.boundingBox.minX < $1.boundingBox.minX }) {
            result.append(RecognizedText(
                text: item.text,
                boundingBox: item.boundingBox,
                confidence: item.confidence,
                characterBoxes: item.characterBoxes,
                angle: item.angle,
                lineNumber: lineNum
            ))
        }
        return result
    }

    private func buildEvidence(from texts: [RecognizedText]) -> [RecognizedText] {
        // 수정: box → boundingBox
        var next: [String:(count: Int, boundingBox: CGRect, confidence: Float, angle: Double)] = [:]
        var seen: Set<String> = []

        for t in texts {
            let key = t.text
            seen.insert(key)

            if let e = textEvidence[key] {
                next[key] = (
                    count: min(e.count + 1, evidenceThreshold + 2),
                    boundingBox: t.boundingBox,      // 🔸 여기
                    confidence: max(e.confidence, t.confidence),
                    angle: e.angle
                )
            } else {
                next[key] = (
                    count: 1,
                    boundingBox: t.boundingBox,      // 🔸 그리고 여기
                    confidence: t.confidence,
                    angle: t.angle
                )
            }
        }

        // 프레임에서 사라진 텍스트 감쇠
        for (k, e) in textEvidence where !seen.contains(k) {
            let newCount = e.count - 2
            if newCount > 0 {
                next[k] = (
                    count: newCount,
                    boundingBox: e.boundingBox,      // 🔸 그리고 여기
                    confidence: e.confidence,
                    angle: e.angle
                )
            }
        }

        // Evidence 크기 제한
        if next.count > maxEvidenceHistory {
            let limited = Array( next
                .sorted { $0.value.count > $1.value.count }
                .prefix(maxEvidenceHistory)
            )
            next = Dictionary(uniqueKeysWithValues: limited)
        }

        textEvidence = next   // 이제 레이블이 일치하므로 할당 OK

        // threshold 이상인 것만 반환
        let confirmed: [RecognizedText] = textEvidence.compactMap { (key, e) -> RecognizedText? in
            guard e.count >= evidenceThreshold else { return nil }
            return RecognizedText(
                text: key,
                boundingBox: e.boundingBox,
                confidence: e.confidence,
                characterBoxes: [],
                angle: e.angle,
                lineNumber: 0
            )
        }

        return sortAndGroupTexts(confirmed)
    }
}

// MARK: - Camera Preview
struct CameraPreview: UIViewRepresentable {
    let previewLayer: AVCaptureVideoPreviewLayer
    func makeUIView(context: Context) -> UIView {
        let v = UIView() ; v.layer.addSublayer(previewLayer) ; return v
    }
    func updateUIView(_ uiView: UIView, context: Context) {
        DispatchQueue.main.async {
            previewLayer.frame = uiView.bounds
        }
    }
}
