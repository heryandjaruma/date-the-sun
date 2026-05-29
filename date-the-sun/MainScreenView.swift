//
//  MainScreenView.swift
//  date-the-sun
//
//  "Main Screen Option 1 (Neutral)" — greeting, UV index, the full-body Sun
//  mascot and a contextual speech bubble over a soft blue-glow background.
//

import SwiftUI

struct MainScreenView: View {
    var userName: String = "UJ"

    /// Tapping the UV pill cycles Kiran through these moods.
    private let moodCycle: [KiranMood] = [.neutral, .happy, .toxic]

    @State private var mood: KiranMood = .neutral

    private var message: String {
        mood == .neutral
            ? "Sun's out, it's gentle today. Perfect weather for a light stroll."
            : mood.line
    }

    var body: some View {
        ZStack(alignment: .top) {
            SkyGlowBackground(tint: mood.glow)
                .ignoresSafeArea()

            // Kiran, full-body and centered. The float runs on its own phase
            // loop so it keeps going when the mood (and artwork) changes.
            GeometryReader { geo in
                PhaseAnimator([false, true]) { lift in
                    SunCharacterView(mood: mood)
                        .scaledToFit()
                        .frame(width: geo.size.width * 0.80)
                        .frame(maxWidth: .infinity, alignment: .top)
                        .offset(y: geo.size.height * 0.15)
                        .rotationEffect(.degrees(lift ? -1.3 : 1.3), anchor: .bottom)
                        .offset(y: lift ? -6 : 6)
                } animation: { _ in
                    .easeInOut(duration: 2.4)
                }
            }
            .ignoresSafeArea()

            // Speech bubble over the chest, on the left.
            GeometryReader { geo in
                SpeechBubble(text: message)
                    .frame(width: min(178, geo.size.width * 0.46))
                    .position(x: geo.size.width * 0.29, y: geo.size.height * 0.55)
            }

            // Greeting + UV pill.
            VStack(spacing: 12) {
                Text("\(greeting), \(userName)")
                    .font(.system(size: 30, weight: .heavy))
                    .foregroundStyle(Palette.ink)
                    .multilineTextAlignment(.center)
                    .minimumScaleFactor(0.7)
                    .lineLimit(2)

                UVIndexBadge(value: mood.uvIndex, iconColor: mood.accent)
                    .contentShape(Capsule())
                    .onTapGesture {
                        withAnimation(.easeInOut(duration: 0.45)) {
                            let i = moodCycle.firstIndex(of: mood) ?? 0
                            mood = moodCycle[(i + 1) % moodCycle.count]
                        }
                    }
            }
            .frame(maxWidth: .infinity)
            .padding(.horizontal, 24)
        }
    }

    private var greeting: String {
        switch Calendar.current.component(.hour, from: Date()) {
        case 5..<12:  return "Good morning"
        case 12..<17: return "Good afternoon"
        case 17..<22: return "Good evening"
        default:      return "Good night"
        }
    }
}

// MARK: - UV Index pill

struct UVIndexBadge: View {
    var value: Int
    var iconColor: Color = Color(hex: 0xF26A1B)

    var body: some View {
        HStack(spacing: 7) {
            Image(systemName: "sun.max.fill")
                .font(.system(size: 18, weight: .bold))
                .foregroundStyle(iconColor)
            Text("UV Index")
            Text("\(value)")
                .contentTransition(.numericText())
        }
        .font(.system(size: 20, weight: .bold))
        .foregroundStyle(Palette.ink)
        .padding(.horizontal, 22)
        .padding(.vertical, 9)
        .background(
            Capsule()
                .fill(Palette.pill)
                .overlay(Capsule().stroke(Palette.pillStroke, lineWidth: 1))
                .shadow(color: Palette.pillStroke.opacity(0.4), radius: 6, y: 3)
        )
    }
}

// MARK: - Speech bubble

struct SpeechBubble: View {
    var text: String

    var body: some View {
        Text(text)
            .font(.system(size: 16, weight: .medium))
            .foregroundStyle(Palette.subInk)
            .fixedSize(horizontal: false, vertical: true)
            .padding(.horizontal, 18)
            .padding(.top, 14)
            .padding(.bottom, 14 + 14) // leave room for the tail
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                SpeechBubbleShape(tailAnchor: 0.7)
                    .fill(Palette.shirt)
                    .shadow(color: .black.opacity(0.12), radius: 10, y: 4)
            )
    }
}

// MARK: - Backgrounds

/// White canvas with a soft glow behind the character, tinted to Kiran's mood.
struct SkyGlowBackground: View {
    var tint: Color = Color(hex: 0x86C2EC)

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [tint.opacity(0.22), .white],
                startPoint: .top,
                endPoint: .bottom
            )
            RadialGradient(
                colors: [
                    tint.opacity(0.55),
                    tint.opacity(0.18),
                    .clear,
                ],
                center: UnitPoint(x: 0.5, y: 0.42),
                startRadius: 8,
                endRadius: 330
            )
        }
    }
}

struct FieldBackground: View {
    var body: some View {
        ZStack {
            LinearGradient(
                stops: [
                    .init(color: Palette.skyTop, location: 0.0),
                    .init(color: Palette.skyBottom, location: 0.32),
                    .init(color: Palette.fieldTop, location: 0.58),
                    .init(color: Palette.fieldBottom, location: 1.0),
                ],
                startPoint: .top,
                endPoint: .bottom
            )

            // Soft flower-field bokeh.
            Canvas { context, size in
                let dots: [(CGFloat, CGFloat, CGFloat, Color)] = [
                    (0.12, 0.72, 10, .white),
                    (0.22, 0.86, 7,  Palette.pill),
                    (0.35, 0.78, 9,  .white),
                    (0.5,  0.9,  8,  Palette.pants),
                    (0.66, 0.74, 11, .white),
                    (0.8,  0.85, 7,  Palette.sash),
                    (0.9,  0.7,  9,  .white),
                    (0.08, 0.9,  8,  Palette.pill),
                    (0.45, 0.68, 7,  .white),
                    (0.74, 0.92, 9,  .white),
                ]
                for (fx, fy, r, color) in dots {
                    let rect = CGRect(
                        x: size.width * fx - r,
                        y: size.height * fy - r,
                        width: r * 2,
                        height: r * 2
                    )
                    context.fill(Path(ellipseIn: rect), with: .color(color.opacity(0.45)))
                }
            }
            .blur(radius: 2)
        }
    }
}

#Preview {
    MainScreenView()
}
