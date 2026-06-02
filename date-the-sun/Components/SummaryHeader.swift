import SwiftUI

/// The Summary screen's top bar: the current date and a circular calendar button.
struct SummaryHeader: View {
    let dateText: String
    // 👇 Accept a binding flag to change the button state visual effects
    @Binding var isShowingCalendar: Bool
    // 👇 The trigger to notify the parent view to show the pop-up
    var onCalendarTap: () -> Void

    var body: some View {
        HStack {
            Text(dateText)
                .font(.system(size: 30, weight: .heavy))
                .foregroundStyle(Palette.ink)

            Spacer()

            Button(action: {
                onCalendarTap()
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
    }
}

// MARK: - Redesigned Calendar Subview (Kept here for reuse)
struct CustomCalendarView: View {
    @Binding var selectedDate: Date
    @Binding var isPresented: Bool
    
    var body: some View {
        VStack(spacing: 16) {
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
        .frame(maxWidth: 340)
    }
}

#Preview {
    SummaryHeader(
        dateText: "16 May 2026",
        isShowingCalendar: .constant(false),
        onCalendarTap: {}
    )
    .padding()
    .background(Palette.canvas)
}
