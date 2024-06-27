//
//  CropView.swift
//  TogedaTest3
//
//  Created by Borislav Lorinkov on 27.06.24.
//

import SwiftUI
import CropViewController

struct CropView: UIViewControllerRepresentable {
    var image: UIImage
    var cropSize: CGSize
    var onCrop: (UIImage) -> Void
    var onCancel: () -> Void

    class Coordinator: NSObject, CropViewControllerDelegate {
        var parent: CropView

        init(parent: CropView) {
            self.parent = parent
        }
        
        private func resizeImage(image: UIImage, targetSize: CGSize) -> UIImage {
            let size = image.size
            
            let widthRatio  = targetSize.width  / size.width
            let heightRatio = targetSize.height / size.height
            
            // Figure out what our orientation is, and use that to form the rectangle
            var newSize: CGSize
            if(widthRatio > heightRatio) {
                newSize = CGSize(width: size.width * heightRatio, height: size.height * heightRatio)
            } else {
                newSize = CGSize(width: size.width * widthRatio, height: size.height * widthRatio)
            }
            
            // This is the rect that we've calculated out and this is what is actually used below
            let rect = CGRect(origin: .zero, size: newSize)
            
            // Actually do the resizing to the rect using the ImageContext stuff
            UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
            image.draw(in: rect)
            let newImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            
            return newImage!
        }

        func cropViewController(_ cropViewController: CropViewController, didCropToImage image: UIImage, withRect cropRect: CGRect, angle: Int) {
            let resizedImage = self.resizeImage(image: image, targetSize: parent.cropSize)
            guard let compressedData = resizedImage.jpegData(compressionQuality: 0.9),
                  let compressedImage = UIImage(data: compressedData) else {
                parent.onCancel()
//                cropViewController.dismiss(animated: true, completion: nil)
                return
            }
            parent.onCrop(compressedImage)
//            cropViewController.dismiss(animated: true, completion: nil)
        }

        func cropViewController(_ cropViewController: CropViewController, didFinishCancelled cancelled: Bool) {
            parent.onCancel()
//            cropViewController.dismiss(animated: true, completion: nil)
        }
    }

    func makeCoordinator() -> Coordinator {
        return Coordinator(parent: self)
    }

    func makeUIViewController(context: Context) -> CropViewController {
        let cropViewController = CropViewController(image: image)
        cropViewController.delegate = context.coordinator
        cropViewController.customAspectRatio = cropSize
        cropViewController.aspectRatioLockEnabled = true
        return cropViewController
    }

    func updateUIViewController(_ uiViewController: CropViewController, context: Context) {}
}


