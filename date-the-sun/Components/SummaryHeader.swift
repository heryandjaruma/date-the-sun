import SwiftUI

/// The Summary screen's top bar: the current date and a circular calendar button.
struct SummaryHeader: View {
    let dateText: String
    @State private var selectedDate = Date()
    @State private var isShowingCalendar = false
    
    // Optional: Pass the selected date back to a parent view/view model if needed
    var onDateChanged: (Date) -> Void = { _ in }
    
    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d MMMM yyyy"
        return formatter.string(from: selectedDate)
    }

    var body: some View {
        // We use a ZStack at the root layer to allow the pop-up to sit globally on top
        ZStack {
            HStack {
                Text(formattedDate)
                    .font(.system(size: 30, weight: .heavy))
                    .foregroundStyle(Palette.ink)

                Spacer()

                Button(action: {
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.75)) {
                        isShowingCalendar = true
                    }
                }) {
                    Image(systemName: "calendar")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(.white)
                        .frame(width: 44, height: 44)
                        .background(Circle().fill(Palette.cardHeader))
                        .scaleEffect(isShowingCalendar ? 0.92 : 1.0)
                }
                .buttonStyle(.plain)
            }
            
            // 👇 TRUE POP-UP OVERLAY LAYER
            if isShowingCalendar {
                Group {
                    // 1. Semi-transparent dimming backdrop background
                    Color.black.opacity(0.4)
                        .ignoresSafeArea()
                        .onTapGesture {
                            dismissPopup() // Tap outside the card to close it safely
                        }
                    
                    // 2. The Pop-up Card centered on screen
                    CustomCalendarView(selectedDate: $selectedDate, isPresented: $isShowingCalendar)
                        .padding(20)
                        .background(
                            RoundedRectangle(cornerRadius: 24)
                                .fill(Palette.canvas)
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 24)
                                .stroke(Palette.ink.opacity(0.1), lineWidth: 1)
                        )
                        .shadow(color: Color.black.opacity(0.2), radius: 20, x: 0, y: 10)
                        .padding(.horizontal, 24) // Keeps margins off screen bounds
                        .transition(.scale(scale: 0.85).combined(with: .opacity)) // Beautiful pop-up animation effect
                }
                .zIndex(100) // Forces the pop-up to stay in front of everything else
            }
        }
    }
    
    private func dismissPopup() {
        withAnimation(.spring(response: 0.25, dampingFraction: 0.8)) {
            isShowingCalendar = false
            onDateChanged(selectedDate)
        }
    }
}

// MARK: - Redesigned Calendar Subview
struct CustomCalendarView: View {
    @Binding var selectedDate: Date
    @Binding var isPresented: Bool
    
    var body: some View {
        VStack(spacing: 16) {
            // Header Bar inside the calendar pop-up
            HStack {
                Text("Select Date")
                    .font(.headline)
                    .foregroundColor(Palette.ink)
                Spacer()
                Button("Done") {
                    withAnimation(.spring(response: 0.25, dampingFraction: 0.8)) {
                        isPresented = false
                    }
                }
                .font(.subheadline)
                .bold()
                .foregroundColor(Palette.cardHeader)
            }
            .padding([.top, .horizontal])
            
            // The actual Graphical Grid Calendar
            DatePicker(
                "",
                selection: $selectedDate,
                displayedComponents: [.date]
            )
            .datePickerStyle(.graphical)
            .accentColor(Palette.cardHeader)
            .padding(.horizontal)
            .padding(.bottom, 8)
            .id(selectedDate)
        }
        .frame(maxWidth: 340) // Constrains size on wide devices
    }
}

#Preview {
    SummaryHeader(dateText: "16 May 2026")
        .padding()
        .background(Palette.canvas)
}
