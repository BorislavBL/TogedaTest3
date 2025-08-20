//
//  BannerService.swift
//  TogedaTest3
//
//  Created by Borislav Lorinkov on 28.07.25.
//

import SwiftUI

enum BannerType: Equatable {
    case success(message: String, isPersistent: Bool = false)
    case error(message: String, isPersistent: Bool = false)
    case warning(message: String, isPersistent: Bool = false)
    // ... Computed Properties
    var backgroundColor: Color {
        switch self {
        case .success: return Color.green
        case .warning: return Color.yellow
        case .error: return Color.red
        }
    }

    var imageName: String {
        switch self {
        case .success: return "checkmark.circle.fill"
        case .warning: return "exclamationmark.triangle.fill"
        case .error: return "xmark.circle.fill"
        }
    }
    
    var message: String {
        switch self {
        case let .success(message, _), let .warning(message, _), let .error(message, _):
            return message
        }
    }
    var isPersistent: Bool {
        switch self {
        case let .success(_, isPersistent), let .warning(_, isPersistent), let .error(_, isPersistent):
            return isPersistent
        }
    }
}


class BannerService: ObservableObject {
    @Published var dragOffset = CGSize.zero
    @Published var bannerType: BannerType?
    @Published var isPresent = false
    let maxDragOffsetHeight: CGFloat = -50.0
    @Published var shouldRestartTimer = false
    // ... Methods
    func setBanner(banner: BannerType) {
        removeBanner()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
            self.shouldRestartTimer.toggle()
            withAnimation(.linear) {
                self.bannerType = banner
                self.isPresent = true
            }
        }

    }

    func removeBanner() {
        DispatchQueue.main.async {
            withAnimation {
                self.bannerType = nil
                self.dragOffset = .zero
                self.isPresent = false
            }
        }
    }
}
