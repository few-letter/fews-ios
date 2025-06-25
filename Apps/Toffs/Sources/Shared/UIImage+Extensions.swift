//
//  UIImage+Extensions.swift
//  Toffs
//
//  Created by 송영모 on 6/25/25.
//

import UIKit
import Foundation

// MARK: - Image Conversion Error
public enum ImageConversionError: Error {
    case imageNotFound
    case pngConversionFailed
}

// MARK: - UIImage Extension
extension UIImage {
    /// UIImage를 다운샘플링하여 PNG Data로 변환하는 헬퍼 메서드
    /// - Parameter uiImage: 변환할 UIImage (optional)
    /// - Parameter maxSize: 최대 크기 (기본값: 1024)
    /// - Parameter compressionQuality: 압축 품질 (기본값: 0.8)
    /// - Returns: 다운샘플링된 PNG 형식의 Data
    /// - Throws: ImageConversionError
    public static func convertToPNG(
        uiImage: UIImage?,
        maxSize: CGFloat = 1024,
        compressionQuality: CGFloat = 0.8
    ) throws -> Data {
        guard let image = uiImage else {
            throw ImageConversionError.imageNotFound
        }
        
        // 다운샘플링 적용
        let downsampledImage = image.downsample(to: maxSize)
        
        // JPEG로 먼저 압축한 후 PNG로 변환 (파일 크기 최적화)
        guard let jpegData = downsampledImage.jpegData(compressionQuality: compressionQuality),
              let compressedImage = UIImage(data: jpegData),
              let pngData = compressedImage.pngData() else {
            throw ImageConversionError.pngConversionFailed
        }
        
        return pngData
    }
    
    /// 이미지를 지정된 최대 크기로 다운샘플링
    /// - Parameter maxSize: 최대 크기 (가로 또는 세로 중 큰 값 기준)
    /// - Returns: 다운샘플링된 UIImage
    public func downsample(to maxSize: CGFloat) -> UIImage {
        let size = self.size
        
        // 이미 작은 이미지는 그대로 반환
        if max(size.width, size.height) <= maxSize {
            return self
        }
        
        // 비율 유지하면서 리사이징
        let aspectRatio = size.width / size.height
        let newSize: CGSize
        
        if size.width > size.height {
            newSize = CGSize(width: maxSize, height: maxSize / aspectRatio)
        } else {
            newSize = CGSize(width: maxSize * aspectRatio, height: maxSize)
        }
        
        // 고품질 리사이징
        let renderer = UIGraphicsImageRenderer(size: newSize)
        return renderer.image { _ in
            self.draw(in: CGRect(origin: .zero, size: newSize))
        }
    }
    
    /// Data로부터 UIImage를 생성하는 편의 이니셜라이저
    /// - Parameter imageData: 이미지 Data
    public convenience init?(from imageData: Data?) {
        guard let data = imageData,
              !data.isEmpty else {
            return nil
        }
        self.init(data: data)
    }
}

