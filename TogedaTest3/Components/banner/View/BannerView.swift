////
////  BannerView.swift
////  TogedaTest3
////
////  Created by Borislav Lorinkov on 28.07.25.
////
//
import SwiftUI

struct BannerView: View {
    @EnvironmentObject var bannerService: BannerService
    @State private var showAllText: Bool = false
    @State private var progress: CGFloat = 0
    @State private var timer: Timer?
    @State private var startTime: Date = Date()
    @State private var remainingTime: TimeInterval
    @State private var isPaused = false

    let banner: BannerType
    let displayDuration: TimeInterval = 3

    init(banner: BannerType) {
        self.banner = banner
        _remainingTime = State(initialValue: displayDuration)
    }

    var body: some View {
        VStack {
            Group {
                bannerContent()
            }
        }
        .onAppear {
            guard !banner.isPersistent else { return }
            resetAndStartTimer()
        }
        .onChange(of: bannerService.shouldRestartTimer) { newValue, oldValue in
            if newValue != oldValue {
                if !banner.isPersistent {
                    resetAndStartTimer()
                }
            }
        }
        .onDisappear {
            timer?.invalidate()
        }
        .transition(.asymmetric(insertion: .move(edge: .top), removal: .move(edge: .top)))
        .offset(y: bannerService.dragOffset.height)
        .gesture(
            DragGesture()
                .onChanged { gesture in
                    if gesture.translation.height < 0 {
                        bannerService.dragOffset = gesture.translation
                    }
                }
                .onEnded { _ in
                    if bannerService.dragOffset.height < -30 {
                        withAnimation {
                            bannerService.removeBanner()
                        }
                    } else {
                        print("No triggered here")
                        bannerService.dragOffset = .zero
                    }
                }
        )
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .padding(.horizontal)
        
    }

    private func bannerContent() -> some View {
        VStack(spacing: 0) {
            HStack(spacing: 10) {
                Image(systemName: banner.imageName)
                    .padding(5)

                VStack(spacing: 5) {
                    Text(banner.message)
                        .foregroundColor(.white)
                        .fontWeight(.semibold)
                        .font(banner.message.count > 25 ? .caption : .footnote)
                        .multilineTextAlignment(.leading)
                        .lineLimit(showAllText ? nil : 2)

                    if banner.message.count > 100 && banner.isPersistent {
                        Image(systemName: showAllText ? "chevron.compact.up" : "chevron.compact.down")
                            .foregroundColor(Color.white.opacity(0.6))
                            .fontWeight(.light)
                    }
                }

                if banner.isPersistent {
                    Button {
                        withAnimation {
                            bannerService.removeBanner()
                        }
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                    }
                }
            }
            .foregroundColor(.white)
            .padding(8)
            .padding(.trailing, 2)

            // Progress bar
            if !banner.isPersistent {
                GeometryReader { geometry in
                    Rectangle()
                        .fill(Color.white.opacity(0.6))
                        .frame(width: geometry.size.width * progress, height: 4)
                        .background(Color.white.opacity(0.2))
                }
                .frame(height: 4)
                .cornerRadius(2)
                .padding(.horizontal, 6)
                .padding(.bottom, 4)
            }
        }
        .background(banner.backgroundColor)
        .cornerRadius(10)
        .simultaneousGesture(TapGesture().onEnded {
            togglePause()
        })
        .simultaneousGesture(LongPressGesture().onEnded { _ in
            togglePause()
        })
        .onTapGesture {
            withAnimation {
                showAllText.toggle()
            }
        }
    }

    // MARK: - Timer Handling

    private func startTimer() {
        startTime = Date()
        timer = Timer.scheduledTimer(withTimeInterval: 0.02, repeats: true) { _ in
            let elapsed = Date().timeIntervalSince(startTime)
            let newProgress = min(CGFloat((displayDuration - remainingTime + elapsed) / displayDuration), 1.0)
            progress = newProgress

            if newProgress >= 1.0 {
                timer?.invalidate()
                withAnimation {
                    bannerService.bannerType = nil
                }
            }
        }
    }

    private func togglePause() {
        if isPaused {
            // Resume
            startTime = Date()
            startTimer()
        } else {
            // Pause
            timer?.invalidate()
            let elapsed = Date().timeIntervalSince(startTime)
            remainingTime -= elapsed
        }
        isPaused.toggle()
    }
    
    private func resetAndStartTimer() {
        timer?.invalidate()
        progress = 0
        isPaused = false
        remainingTime = displayDuration
        startTime = Date()

        timer = Timer.scheduledTimer(withTimeInterval: 0.02, repeats: true) { _ in
            let elapsed = Date().timeIntervalSince(startTime)
            let newProgress = min(CGFloat((displayDuration - remainingTime + elapsed) / displayDuration), 1.0)
            progress = newProgress

            if newProgress >= 1.0 {
                timer?.invalidate()
                withAnimation {
                    bannerService.bannerType = nil
                }
            }
        }
    }

}

#Preview {
    BannerView(banner: .success(message: "Success indeed", isPersistent: true))
        .environmentObject(BannerService())
}


