//
//  PhotoPIcker.swift
//  TogedaTest3
//
//  Created by Borislav Lorinkov on 27.06.24.
//

//import SwiftUI
//import TOCropViewController
//
//struct PhotoPicker: UIViewControllerRepresentable {
//    @Binding var selectedImage: UIImage
//
//    func makeUIViewController(context: Context) -> some UIViewController {
//        let picker = UIImagePickerController()
//        picker.delegate = context.coordinator
//        picker.allowsEditing = false // Disable default editing
//        return picker
//    }
//
//    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {}
//
//    func makeCoordinator() -> Coordinator {
//        return Coordinator(photoPicker: self)
//    }
//
//    final class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate, TOCropViewControllerDelegate {
//        let photoPicker: PhotoPicker
//
//        init(photoPicker: PhotoPicker) {
//            self.photoPicker = photoPicker
//        }
//
//        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
//            if let image = info[.originalImage] as? UIImage {
//                picker.dismiss(animated: true) {
//                    self.presentCropViewController(with: image)
//                }
//            } else {
//                picker.dismiss(animated: true)
//            }
//        }
//
//        func presentCropViewController(with image: UIImage) {
//            let cropViewController = TOCropViewController(image: image)
//            cropViewController.delegate = self
//            cropViewController.aspectRatioPreset = .presetCustom // Custom aspect ratio
//            cropViewController.customAspectRatio = CGSize(width: 4, height: 3) // Your desired aspect ratio
//            cropViewController.aspectRatioLockEnabled = true
//            cropViewController.resetAspectRatioEnabled = false
//
//            let keyWindow = UIApplication.shared.connectedScenes
//                .filter { $0.activationState == .foregroundActive }
//                .compactMap { $0 as? UIWindowScene }
//                .first?.windows
//                .filter { $0.isKeyWindow }
//                .first
//
//            keyWindow?.rootViewController?.present(cropViewController, animated: true, completion: nil)
//        }
//
//        func cropViewController(_ cropViewController: TOCropViewController, didCropTo image: UIImage, with cropRect: CGRect, angle: Int) {
//            guard let data = image.jpegData(compressionQuality: 0.9), let compressedImage = UIImage(data: data) else {
//                return
//            }
//            photoPicker.selectedImage = compressedImage
//            cropViewController.dismiss(animated: true, completion: nil)
//        }
//
//        func cropViewController(_ cropViewController: TOCropViewController, didFinishCancelled cancelled: Bool) {
//            cropViewController.dismiss(animated: true, completion: nil)
//        }
//    }
//}

import SwiftUI
import PhotosUI
import CropViewController

struct PhotoPicker: UIViewControllerRepresentable {
    @Binding var selectedImage: UIImage?
    @Binding var finalImage: UIImage?
    
    var cropSize: CGSize
    
    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        var parent: PhotoPicker
        
        init(parent: PhotoPicker) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let image = info[.originalImage] as? UIImage {
                picker.dismiss(animated: true) {
//                    self.presentCropView(with: image)
                    self.parent.selectedImage = image
                }
            } else {
                picker.dismiss(animated: true)
            }
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            picker.dismiss(animated: true, completion: nil)
        }
        
//        private func presentCropView(with image: UIImage) {
//            let cropView = CropView(image: image, cropSize: parent.cropSize) { croppedImage in
//                self.parent.selectedImage = croppedImage
//                self.parent.finalImage = croppedImage
//            } onCancel: {
//                // Handle cancellation if needed
//                self.parent.selectedImage = nil
//                self.parent.finalImage = nil
//            }
//            
//            if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
//               let window = scene.windows.first,
//               let rootViewController = window.rootViewController {
//                let cropViewController = UIHostingController(rootView: cropView)
//                rootViewController.present(cropViewController, animated: true, completion: nil)
//            }
//        }
    }
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(parent: self)
    }
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
}
