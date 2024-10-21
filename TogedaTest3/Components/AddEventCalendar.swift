//
//  AddEventCalendar.swift
//  TogedaTest3
//
//  Created by Borislav Lorinkov on 11.10.24.
//

import UIKit
import EventKit
import EventKitUI
import SwiftUI

struct EventEditViewController: UIViewControllerRepresentable {
    @Environment(\.dismiss) var dismiss
    @Binding var event: EKEvent?
    let eventStore: EKEventStore
    
    func makeUIViewController(context: Context) -> EKEventEditViewController {
        let controller = EKEventEditViewController()
        
        controller.eventStore = eventStore
        controller.event = event
        controller.editViewDelegate = context.coordinator
        
        return controller
    }
    
    func updateUIViewController(_ uiViewController: EKEventEditViewController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(self)
    }
    
    class Coordinator: NSObject, EKEventEditViewDelegate {
        var parent: EventEditViewController
        
        init(_ controller: EventEditViewController) {
            self.parent = controller
        }
        
        func eventEditViewController(_ controller: EKEventEditViewController, didCompleteWith action: EKEventEditViewAction) {
            parent.dismiss()
        }
    }
}

//struct AddEvent: UIViewControllerRepresentable {
//    var title: String
//    var location: String
//    var startDate: Date
//    var endDate: Date
//    var details: String
//
//    func makeUIViewController(context: Context) -> AddEventController {
//        let controller = AddEventController()
//        controller.eventTitle = title
//        controller.eventLocation = location
//        controller.eventStartDate = startDate
//        controller.eventEndDate = endDate
//        controller.eventDetails = details
//        return controller
//    }
//
//    func updateUIViewController(_ uiViewController: AddEventController, context: Context) {
//        // We need this to follow the protocol, but don't have to implement it
//        // Optionally, update the state of the view controller here
//    }
//}
//
//class AddEventController: UIViewController, EKEventEditViewDelegate {
//    let eventStore = EKEventStore()
//
//    // Properties to hold event details
//    var eventTitle: String = ""
//    var eventLocation: String = ""
//    var eventStartDate: Date = Date()
//    var eventEndDate: Date = Date()
//    var eventDetails: String = ""
//
//    func eventEditViewController(_ controller: EKEventEditViewController, didCompleteWith action: EKEventEditViewAction) {
//        controller.dismiss(animated: true, completion: nil)
//        parent?.dismiss(animated: true, completion: nil)
//    }
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        
//        // Request write-only access to the calendar
//        eventStore.requestWriteOnlyAccessToEvents { (granted, error) in
//            DispatchQueue.main.async {
//                if granted && error == nil {
//                    let eventController = EKEventEditViewController()
//                    
//                    // Create an EKEvent and populate it with the details
//                    let event = EKEvent(eventStore: self.eventStore)
//                    event.title = self.eventTitle
//                    event.location = self.eventLocation
//                    event.startDate = self.eventStartDate
//                    event.endDate = self.eventEndDate
//                    event.notes = self.eventDetails
//                    event.calendar = self.eventStore.defaultCalendarForNewEvents
//
//                    // Set the event for the EKEventEditViewController
//                    eventController.event = event
//                    eventController.eventStore = self.eventStore
//                    eventController.editViewDelegate = self
//                    eventController.modalPresentationStyle = .overCurrentContext
//                    eventController.modalTransitionStyle = .crossDissolve
//
//                    // Present the event editor
//                    self.present(eventController, animated: true, completion: nil)
//                } else {
//                    print("Access to calendar was not granted or there was an error.")
//                }
//            }
//        }
//    }
//}
