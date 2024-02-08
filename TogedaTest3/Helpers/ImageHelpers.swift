//
//  ImageHelpers.swift
//  TogedaTest3
//
//  Created by Borislav Lorinkov on 5.02.24.
//

import UIKit

func compressImageIfNeeded(image: UIImage, limitKB: Int = 500) -> Data? {
    // Convert the initial image to JPEG with the highest quality
    var compressionQuality: CGFloat = 1.0
    var imageData = image.jpegData(compressionQuality: compressionQuality)
    
    // Calculate the image size in kilobytes
    let imageSizeKB = imageData?.count ?? 0 / 1024
    
    // While the image is larger than the limit, reduce the quality
    while imageSizeKB > limitKB && compressionQuality > 0 {
        compressionQuality -= 0.1
        imageData = image.jpegData(compressionQuality: compressionQuality)
    }
    
    return imageData
}
