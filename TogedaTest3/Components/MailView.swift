//
//  MailView.swift
//  TogedaTest3
//
//  Created by Borislav Lorinkov on 6.11.24.
//

import SwiftUI
import MessageUI
import UIKit
import SystemConfiguration.CaptiveNetwork

struct MailView: UIViewControllerRepresentable {
    @Environment(\.presentationMode) var presentationMode
    let recipient: String
    let user: Components.Schemas.UserInfoDto?
    
    // Fetch the app version and build number
    func appVersion() -> String {
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "N/A"
        let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "N/A"
        return "Version \(version) (Build \(build))"
    }
    
    // Get device model and iOS version
    func deviceInfo() -> String {
        let model = UIDevice.current.modelName
        let osVersion = UIDevice.current.systemVersion
        return "\(model) - iOS \(osVersion)"
    }
    
    
    func bodyMessage() -> String{
        if let user = self.user{
            return """
        Please let us know how we can assist you. 

        ---------------------------------
        User Email: \(user.email)
        User ID: \(user.id)
        App: \(appVersion())
        Device: \(deviceInfo())
        ---------------------------------
        """
        } else {
            return """
            It appears we were unable to retrieve some of your information. To help us assist you, please include the email address associated with your account in this message.
            
            ---------------------------------
            User Email: Write your email here
            App: \(appVersion())
            Device: \(deviceInfo())
            ---------------------------------
            """
        }
    }

    func makeUIViewController(context: Context) -> MFMailComposeViewController {
        let mailComposeVC = MFMailComposeViewController()
        mailComposeVC.mailComposeDelegate = context.coordinator
        mailComposeVC.setToRecipients([recipient])
        mailComposeVC.setSubject("Contacting from the Togeda App")
        mailComposeVC.setMessageBody(bodyMessage(), isHTML: false)
        return mailComposeVC
    }

    func updateUIViewController(_ uiViewController: MFMailComposeViewController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, MFMailComposeViewControllerDelegate {
        var parent: MailView

        init(_ parent: MailView) {
            self.parent = parent
        }

        func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
            controller.dismiss(animated: true)
            parent.presentationMode.wrappedValue.dismiss()
        }
    }
}

extension UIDevice {
    var modelName: String {
        var systemInfo = utsname()
        uname(&systemInfo)
        let machineMirror = Mirror(reflecting: systemInfo.machine)
        let identifier = machineMirror.children.compactMap { element in
            element.value as? Int8 }
            .map { String(UnicodeScalar(UInt8($0))) }
            .joined()
        
        // Add a dictionary mapping identifiers to model names
        let deviceModels = [
            "iPhone15,3": "iPhone 14 Pro",
            "iPhone15,2": "iPhone 14",
            "iPhone14,2": "iPhone 13 Pro",
            "iPhone13,4": "iPhone 12 Pro Max",
            // Add other models as needed
        ]
        
        return deviceModels[identifier] ?? identifier
    }
}
