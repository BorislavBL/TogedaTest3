//import SwiftUI
//
//@available(iOS 15.0, *)
//struct AuroraView: View {
//    // Increase this to make all circles larger
//    private let scale: CGFloat = 1.6
//
//    var body: some View {
//        TimelineView(.animation) { timeline in
//            let t = timeline.date.timeIntervalSinceReferenceDate
//
//            Canvas { context, size in
//                // Normal compositing so overlaps mix into new hues (no whitening)
//                context.blendMode = .normal
//
//                for blob in AuroraBlob.presets {
//                    let c = blob.center(in: size, time: t)
//                    let r = blob.radius(in: size, time: t, scale: scale)
//
//                    // Radial gradient that fades to transparent at the edge
//                    let shader = GraphicsContext.Shading.radialGradient(
//                        Gradient(stops: gradientStops(for: blob.colors)),
//                        center: c,
//                        startRadius: 0,
//                        endRadius: r
//                    )
//
//                    // Perfect circle
//                    let rect = CGRect(x: c.x - r, y: c.y - r, width: r * 2, height: r * 2)
//
//                    context.opacity = 0.85
//                    context.fill(Path(ellipseIn: rect), with: shader)
//                }
//            }
//            .blur(radius: 32)
//            .saturation(1.1)
//            .brightness(0)
//            .overlay(
//                LinearGradient(
//                    colors: [.black.opacity(0.25), .clear, .black.opacity(0.25)],
//                    startPoint: .top, endPoint: .bottom
//                )
//            )
//            .ignoresSafeArea()
//            .drawingGroup()
//        }
//    }
//}
//
//// Helper to build transparent-edge gradients per blob
//@available(iOS 15.0, *)
//private func gradientStops(for colors: [Color]) -> [Gradient.Stop] {
//    switch colors.count {
//    case 0:
//        return [.init(color: .clear, location: 1.0)]
//    case 1:
//        return [
//            .init(color: colors[0].opacity(0.65), location: 0.0),
//            .init(color: colors[0].opacity(0.00), location: 1.0)
//        ]
//    default:
//        return [
//            .init(color: colors.first!.opacity(0.65), location: 0.0),
//            .init(color: colors[min(colors.count - 1, 1)].opacity(0.35), location: 0.55),
//            .init(color: colors.last!.opacity(0.00), location: 1.0)
//        ]
//    }
//}
//
//private struct AuroraBlob: Identifiable {
//    let id = UUID()
//    let colors: [Color]
//    let speed: Double
//    let phase: Double
//    let baseScale: CGFloat
//
//    func center(in size: CGSize, time: TimeInterval) -> CGPoint {
//        // Lissajous-like drift
//        let x = size.width  * (0.5 + 0.42 * CGFloat(sin(time * speed * 0.9 + phase)))
//        let y = size.height * (0.5 + 0.35 * CGFloat(cos(time * speed * 1.1 + phase * 0.7)))
//        return CGPoint(x: x, y: y)
//    }
//
//    // Now supports a global 'scale' to make circles bigger/smaller
//    func radius(in size: CGSize, time: TimeInterval, scale: CGFloat = 1.0) -> CGFloat {
//        let base = min(size.width, size.height) * baseScale * scale
//        let pulse = 0.1 * sin(time * speed * 0.6 + phase) // gentle breathing
//        return base * (1.0 + CGFloat(pulse))
//    }
//
//    // Circles of different colors drifting around
//    static let presets: [AuroraBlob] = [
//        .init(colors: [.green, .cyan],        speed: 0.12, phase: 0.0, baseScale: 0.45),
//        .init(colors: [.mint, .teal, .blue],  speed: 0.10, phase: 1.7, baseScale: 0.42),
//        .init(colors: [.indigo, .purple],     speed: 0.08, phase: 3.1, baseScale: 0.48),
//        .init(colors: [.pink, .purple],       speed: 0.09, phase: 4.6, baseScale: 0.38),
//        .init(colors: [.yellow, .orange],     speed: 0.07, phase: 2.4, baseScale: 0.40)
//    ]
//}

import SwiftUI
import CoreImage
import CoreImage.CIFilterBuiltins

// MARK: - Premium Aurora Background

@available(iOS 15.0, *)
public struct PremiumAuroraBackground: View {
    @Environment(\.colorScheme) private var scheme
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    // Tweak these for your brand/vibe
    private let globalScale: CGFloat = 2.65   // overall size of circles
    private let blurRadius: CGFloat  = 0.6     // softness of edges
    private let mixOpacity: Double   = 0.66   // per-blob opacity (keeps color rich but calm)

    public init() {}

    public var body: some View {
        ZStack {
            // Base wash that plays well with Stripe blues/purples
            (scheme == .dark ? Color(red: 0.06, green: 0.07, blue: 0.11)
             : Color(hex: 0xb0ffd7))
                .ignoresSafeArea()
//             Color(red: 0.94, green: 0.96, blue: 0.99))
            
//            (scheme == .dark ? Color(.green)
//             : Color(.green))
//                .ignoresSafeArea()

            // IMPORTANT: Split schedules so types match (fixes your error)
            if reduceMotion {
                TimelineView(.periodic(from: .now, by: 10_000)) { _ in
                    AuroraCanvas(
                        time: 0,
                        globalScale: globalScale,
                        blurRadius: blurRadius,
                        mixOpacity: mixOpacity
                    )
                    .background(.red)
                }
            } else {
                TimelineView(.animation) { timeline in
                    let t = timeline.date.timeIntervalSinceReferenceDate
                    AuroraCanvas(
                        time: t,
                        globalScale: globalScale,
                        blurRadius: blurRadius,
                        mixOpacity: mixOpacity
                    )
                }
            }
        }
        .compositingGroup()
    }
}

// MARK: - Canvas that draws the animated circles

@available(iOS 15.0, *)
private struct AuroraCanvas: View {
    @Environment(\.colorScheme) private var scheme

    let time: TimeInterval
    let globalScale: CGFloat
    let blurRadius: CGFloat
    let mixOpacity: Double

    var body: some View {
        Canvas { context, size in
            context.blendMode = .normal // mix hues, no brighten-to-white

            for blob in AuroraBlob.presets(for: scheme) {
                let c = blob.center(in: size, time: time)
                let r = blob.radius(in: size, time: time, scale: globalScale)

                let colors = blob.premiumColors(at: time)       // subtle hue drift
                let stops  = gradientStopsPremium(for: colors)

                let shader = GraphicsContext.Shading.radialGradient(
                    Gradient(stops: stops),
                    center: c,
                    startRadius: 0,
                    endRadius: r
                )

                // Circles (calm/premium)
                let rect = CGRect(x: c.x - r, y: c.y - r, width: r * 2, height: r * 2)

                context.opacity = mixOpacity
                context.fill(Path(ellipseIn: rect), with: shader)
            }
        }
        .blur(radius: blurRadius)
        .saturation(1.12)
        .contrast(1.04)
        .mask(spotlightMask())                         // keeps center a touch brighter
        .overlay(legibilityScrim(), alignment: .center)
        .overlay(SubtleNoise().opacity(0.035).blendMode(.softLight))
        .ignoresSafeArea()
        .drawingGroup()
//        .background(.blue)
    }

    // Soft center spotlight → edges quieter for UI focus
    private func spotlightMask() -> some View {
        RadialGradient(
            gradient: Gradient(stops: [
                .init(color: .white,              location: 0.00),
                .init(color: .white,              location: 0.55),
                .init(color: .white.opacity(0.0), location: 1.00)
            ]),
            center: .center,
            startRadius: 0,
            endRadius: 800
        )
    }

    // Subtle top/bottom scrim for text/controls contrast
    private func legibilityScrim() -> some View {
        LinearGradient(
            colors: [
                .black.opacity(scheme == .dark ? 0.16 : 0.10),
                .clear,
                .black.opacity(scheme == .dark ? 0.20 : 0.12)
            ],
            startPoint: .top,
            endPoint: .bottom
        )
        .blendMode(.multiply)
        .ignoresSafeArea()
    }
}

// MARK: - Gradient stops (premium, restrained)

@available(iOS 15.0, *)
private func gradientStopsPremium(for colors: [Color]) -> [Gradient.Stop] {
    let a = colors.indices.contains(0) ? colors[0] : .white
    let b = colors.indices.contains(1) ? colors[1] : a
    let c = colors.indices.contains(2) ? colors[2] : b

    return [
        .init(color: a.opacity(0.82), location: 0.00),  // luminous core
        .init(color: b.opacity(0.50), location: 0.45),  // soft mid band
        .init(color: c.opacity(0.22), location: 0.78),  // faint tint near edge
        .init(color: c.opacity(0.00), location: 1.00)   // transparent edge for clean mixes
    ]
}

// MARK: - Blob model

@available(iOS 15.0, *)
private struct AuroraBlob: Identifiable {
    let id = UUID()

    // Color animation
    let baseHue: Double   // 0...1
    let hueDrift: Double  // small swing for premium subtlety
    let hueSpeed: Double

    // Motion/size
    let speed: Double
    let phase: Double
    let baseScale: CGFloat

    func center(in size: CGSize, time: TimeInterval) -> CGPoint {
        // Smooth Lissajous drift
        let x = size.width  * (0.5 + 0.42 * CGFloat(sin(time * speed * 0.9 + phase)))
        let y = size.height * (0.5 + 0.35 * CGFloat(cos(time * speed * 1.1 + phase * 0.7)))
        return CGPoint(x: x, y: y)
    }

    func radius(in size: CGSize, time: TimeInterval, scale: CGFloat = 1.0) -> CGFloat {
        let base = min(size.width, size.height) * baseScale * scale
        let pulse = 0.08 * sin(time * speed * 0.6 + phase) // gentler breathing
        return base * (1.0 + CGFloat(pulse))
    }

    func premiumColors(at time: TimeInterval) -> [Color] {
        // High brightness, moderated saturation, tiny hue drift
        let h0 = normalizedHue(baseHue + sin(time * hueSpeed + phase) * hueDrift)
        let h1 = normalizedHue(h0 + 0.035)
        let h2 = normalizedHue(h0 - 0.045)

        let c0 = Color(hue: h0, saturation: 0.82, brightness: 0.99)
        let c1 = Color(hue: h1, saturation: 0.78, brightness: 0.97)
        let c2 = Color(hue: h2, saturation: 0.76, brightness: 0.96)
        return [c0, c1, c2]
    }

    static func presets(for scheme: ColorScheme) -> [AuroraBlob] {
        // Blue/indigo/teal with a restrained magenta accent
        // Slightly different sizes so density feels consistent across themes
        let s: CGFloat = (scheme == .dark) ? 0.46 : 0.50

        return [
            //         baseHue hueDrift hueSpeed speed   phase baseScale
            .init(baseHue: 0.60, hueDrift: 0.030, hueSpeed: 0.08, speed: 0.095, phase: 0.0, baseScale: s + 0.04), // cyan→blue
            .init(baseHue: 0.69, hueDrift: 0.028, hueSpeed: 0.07, speed: 0.085, phase: 1.9, baseScale: s + 0.01), // blue→indigo
            .init(baseHue: 0.76, hueDrift: 0.026, hueSpeed: 0.07, speed: 0.080, phase: 3.2, baseScale: s + 0.06), // indigo→violet
            .init(baseHue: 0.87, hueDrift: 0.024, hueSpeed: 0.09, speed: 0.090, phase: 4.4, baseScale: s - 0.02), // subtle magenta
            .init(baseHue: 0.48, hueDrift: 0.028, hueSpeed: 0.08, speed: 0.082, phase: 2.7, baseScale: s + 0.03)  // teal
        ]
    }
}

// MARK: - Utilities

private func normalizedHue(_ h: Double) -> Double {
    var x = h.truncatingRemainder(dividingBy: 1.0)
    if x < 0 { x += 1.0 }
    return x
}

// MARK: - Ultra-subtle film grain (prevents color banding)

@available(iOS 15.0, *)
private struct SubtleNoise: View {
    private static let image: Image = {
        let context = CIContext(options: nil)
        let noise = CIFilter.randomGenerator().outputImage!
            .cropped(to: CGRect(x: 0, y: 0, width: 1024, height: 1024))
        let cg = context.createCGImage(noise, from: noise.extent)!
        return Image(decorative: cg, scale: 1, orientation: .up)
    }()

    var body: some View {
        SubtleNoise.image
            .resizable()
            .scaledToFill()
            .ignoresSafeArea()
            .allowsHitTesting(false)
    }
}
