//
//  SummaryView.swift
//  date-the-sun
//
//  The "Summary" tab — a daily/weekly recap: Kiran's mood card, a 24-hour
//  sun-exposure dial, and a protection checklist.
//

import SwiftUI

struct SummaryView: View {
    @State private var isWeekly = false
    @State private var sunscreenDone = true
    @State private var clothingDone = false

    var body: some View {
        ZStack {
            Palette.paper.ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 16) {
                    DateHeader()
                    PeriodToggle(isWeekly: $isWeekly)
                    HeroCard()
                    SunExposureCard()
                    ProtectionLogCard(sunscreenDone: $sunscreenDone,
                                      clothingDone: $clothingDone)
                }
                .padding(.horizontal, 18)
                .padding(.top, 4)
                .padding(.bottom, 120)   // clear the floating tab bar
            }
        }
    }
}

// MARK: - Header

private struct DateHeader: View {
    private var dateText: String {
        let f = DateFormatter()
        f.dateFormat = "d MMMM yyyy"
        return f.string(from: Date())
    }

    var body: some View {
        HStack {
            Text(dateText)
                .font(.system(size: 26, weight: .heavy))
                .foregroundStyle(Palette.ink)
            Spacer()
            Image(systemName: "calendar")
                .font(.system(size: 18, weight: .semibold))
                .foregroundStyle(Palette.paper)
                .frame(width: 44, height: 44)
                .background(Circle().fill(Palette.cardHeader))
        }
    }
}

private struct PeriodToggle: View {
    @Binding var isWeekly: Bool

    var body: some View {
        HStack(spacing: 10) {
            segment("Daily", selected: !isWeekly) { isWeekly = false }
            segment("Weekly", selected: isWeekly) { isWeekly = true }
            Spacer(minLength: 0)
        }
    }

    private func segment(_ title: String, selected: Bool, _ action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(selected ? Palette.paper : Palette.ink)
                .frame(width: 128)
                .padding(.vertical, 9)
                .background(
                    Capsule()
                        .fill(selected ? Palette.cardHeader : .clear)
                        .overlay(Capsule().stroke(Palette.ink.opacity(0.3),
                                                  lineWidth: selected ? 0 : 1.3))
                )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Hero card

private struct HeroCard: View {
    private let cardHeight: CGFloat = 286
    private let kiranWidth: CGFloat = 150

    var body: some View {
        ZStack(alignment: .bottom) {
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(Palette.heroBlue)
                .frame(height: cardHeight)
                .overlay(alignment: .topLeading) {
                    Text("What a happy day — especially with you")
                        .font(.system(size: 30, weight: .heavy))
                        .foregroundStyle(Palette.ink)
                        .lineSpacing(2)
                        .frame(width: 180, alignment: .leading)
                        .padding(24)
                }

            // Kiran pops out the top of the card, body bleeding to the bottom edge.
            SunCharacterView(mood: .neutral)
                .scaledToFit()
                .frame(width: kiranWidth)
                .frame(maxWidth: .infinity, alignment: .trailing)
                .offset(x: 16)
        }
    }
}

// MARK: - Sun-exposure card

private struct SunExposureCard: View {
    var body: some View {
        SectionCard(title: "Sun Exposure", icon: "sun.max.fill", bodyColor: Palette.limeCard) {
            VStack(spacing: 16) {
                SunDial()
                HStack(spacing: 14) {
                    legend("Outdoor Time", Palette.outdoorTime)
                    legend("Indoor Time", Palette.indoorTime)
                    legend("UV Index Peak", Palette.uvPeak)
                }
                .font(.system(size: 11, weight: .semibold))
                .foregroundStyle(Palette.ink)
            }
            .padding(.vertical, 6)
        }
    }

    private func legend(_ title: String, _ color: Color) -> some View {
        HStack(spacing: 5) {
            Circle().fill(color).frame(width: 9, height: 9)
            Text(title)
        }
    }
}

/// A 24-hour dial: midnight at top, 6h right, noon bottom, 18h left.
private struct SunDial: View {
    private let ringDiameter: CGFloat = 156
    private let ringWidth: CGFloat = 16

    var body: some View {
        ZStack {
            Circle()
                .stroke(Color.white.opacity(0.5), lineWidth: ringWidth)
                .frame(width: ringDiameter, height: ringDiameter)

            // Indoor (blue)
            arc(19.2, 23.8, Palette.indoorTime)
            arc(0.2, 5.8, Palette.indoorTime)
            arc(11.2, 12.8, Palette.indoorTime)
            // Outdoor (pink)
            arc(6.2, 10.8, Palette.outdoorTime)
            arc(13.2, 18.8, Palette.outdoorTime)
            // UV index peak (orange) — thinner outer ring
            arc(10.4, 14.6, Palette.uvPeak, diameter: 188, width: 7)

            // Clock face
            Circle()
                .fill(Palette.paper)
                .frame(width: 116, height: 116)
                .overlay(Circle().stroke(Palette.ink.opacity(0.08), lineWidth: 1))

            Group {
                Text("24").offset(y: -46)
                Text("6").offset(x: 46)
                Text("12").offset(y: 46)
                Text("18").offset(x: -46)
            }
            .font(.system(size: 14, weight: .bold))
            .foregroundStyle(Palette.ink.opacity(0.65))
        }
        .frame(width: 200, height: 200)
    }

    private func arc(_ from: Double, _ to: Double, _ color: Color,
                     diameter: CGFloat? = nil, width: CGFloat? = nil) -> some View {
        Circle()
            .trim(from: from / 24, to: to / 24)
            .stroke(color, style: StrokeStyle(lineWidth: width ?? ringWidth, lineCap: .round))
            .frame(width: diameter ?? ringDiameter, height: diameter ?? ringDiameter)
            .rotationEffect(.degrees(-90))
    }
}

// MARK: - Protection log card

private struct ProtectionLogCard: View {
    @Binding var sunscreenDone: Bool
    @Binding var clothingDone: Bool

    var body: some View {
        SectionCard(title: "Protection Log", icon: "shield.fill", bodyColor: Palette.pinkCard) {
            VStack(spacing: 12) {
                ProtectionRow(icon: "drop.fill",
                              title: "Sunscreen",
                              subtitle: "Apply before going outside",
                              done: $sunscreenDone)
                ProtectionRow(icon: "tshirt.fill",
                              title: "Protective Clothing",
                              subtitle: "Use hat and long-sleeved shirt",
                              done: $clothingDone)
            }
        }
    }
}

private struct ProtectionRow: View {
    let icon: String
    let title: String
    let subtitle: String
    @Binding var done: Bool

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 18))
                .foregroundStyle(Palette.ink)
                .frame(width: 26)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 15, weight: .bold))
                    .foregroundStyle(Palette.ink)
                Text(subtitle)
                    .font(.system(size: 12))
                    .foregroundStyle(Palette.ink.opacity(0.55))
            }

            Spacer()

            Button {
                withAnimation(.easeInOut(duration: 0.2)) { done.toggle() }
            } label: {
                Image(systemName: done ? "circle.inset.filled" : "circle")
                    .font(.system(size: 23))
                    .foregroundStyle(done ? Palette.ink : Palette.ink.opacity(0.35))
            }
            .buttonStyle(.plain)
        }
        .padding(14)
        .background(RoundedRectangle(cornerRadius: 16, style: .continuous).fill(Palette.paper))
    }
}

// MARK: - Reusable section card (dark header + colored body)

private struct SectionCard<Content: View>: View {
    let title: String
    let icon: String
    let bodyColor: Color
    @ViewBuilder var content: () -> Content

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 14, weight: .semibold))
                Text(title)
                    .font(.system(size: 16, weight: .bold))
                Spacer()
                Image(systemName: "questionmark")
                    .font(.system(size: 11, weight: .bold))
                    .frame(width: 22, height: 22)
                    .background(Circle().stroke(Palette.paper.opacity(0.55), lineWidth: 1.3))
            }
            .foregroundStyle(Palette.paper)
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .frame(maxWidth: .infinity)
            .background(Palette.cardHeader)

            content()
                .frame(maxWidth: .infinity)
                .padding(16)
                .background(bodyColor)
        }
        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
    }
}

#Preview {
    SummaryView()
}
