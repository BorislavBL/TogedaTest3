//
//  InternalServerErrorView.swift
//  TogedaTest3
//
//  Created by Borislav Lorinkov on 1.07.25.
//

import SwiftUI
struct InternalServerErrorView: View {
    // Parent view-model decides when to show / hide this sheet
    @ObservedObject var vm: ContentViewModel

    // Scene phase lets us know when the app returns to foreground
    @Environment(\.scenePhase) private var scenePhase

    // Back-off state
    @State private var delay: TimeInterval = 5
    private let maxDelay: TimeInterval = 10

    // Keep a handle so we can cancel the loop
    @State private var recoveryTask: Task<Void, Never>?

    // MARK: - View
    var body: some View {
        VStack(spacing: 30) {
            Text("🧑‍💻").font(.system(size: 120))

            Text("We hit a snag")
                .font(.title2)
                .bold()

            Text("""
                 Our servers are taking a quick break.
                 We’ll reconnect automatically, \
                 but you can try again anytime.
                 """)
                .multilineTextAlignment(.center)
                .font(.body.weight(.semibold))
                .foregroundStyle(.gray)
                .padding(.bottom, UIScreen.main.bounds.height * 0.2)

            Button("Try Again Now") {
                manualRetry()
            }
            .bold()
            .frame(maxWidth: .infinity, minHeight: 60)
            .background(Color("blackAndWhite"))
            .foregroundColor(Color("testColor"))
            .cornerRadius(10)
        }
        .padding(.horizontal)
        .frame(maxHeight: .infinity, alignment: .center)
        .background(.bar)
        // ----- lifecycle hooks -----
        .onAppear { startPolling() }
        .onDisappear {
            cancelPolling()
        }
        .onChange(of: scenePhase) { phase in
            if phase == .active {               // app became foreground
                immediateRetry()
            }
        }
    }

    // MARK: - Polling helpers
    private func startPolling() {
        guard recoveryTask == nil else { return }    // already running
        recoveryTask = Task {
            while !Task.isCancelled {
                if await tryRecover() { return }     // success → sheet dismisses
                try? await Task.sleep(
                    nanoseconds: UInt64(delay * 1_000_000_000)
                )
                delay = maxDelay                     // 5 s once, then 10 s
            }
        }
    }

    private func cancelPolling() {
        recoveryTask?.cancel()
        recoveryTask = nil
    }

    // Try once and decide what to do
    @discardableResult
    private func tryRecover() async -> Bool {
        do {
            if let _ = try await APIClient.shared.hasBasicInfo() {
                await vm.validateTokensAndCheckState()
                await MainActor.run { vm.internalServerError = false }
                return true                          // ✅ succeed → stop loop
            }
        } catch APIClientError.internalServerError {
            // still down – ignore
        } catch {
            // network or other error – ignore
        }
        return false                                 // keep looping
    }

    // Called when the user presses the button
    private func manualRetry() {
        cancelPolling()          // reset delay & back-off
        delay = 5
        startPolling()           // will try immediately once below
    }

    // Called when app returns to foreground
    private func immediateRetry() {
        Task { _ = await tryRecover() }   // fire-and-forget
    }
}


#Preview {
    InternalServerErrorView(vm: ContentViewModel())
}

