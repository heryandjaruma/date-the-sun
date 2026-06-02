import SwiftUI

/// The Summary dashboard: a date header, a Daily/Weekly toggle, and the
/// matching daily or weekly content over a cream background.
struct SummaryView: View {
    @ObservedObject var viewModel: SummaryViewModel
    @Namespace private var periodNamespace

    // Root-level states to host the pop-up overlay context
    @State private var selectedDate = Date()
    @State private var isShowingCalendar = false

    init(viewModel: SummaryViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        ZStack {
            Palette.canvas.ignoresSafeArea()

            // The main background dashboard layer
            ScrollView {
                VStack(spacing: 20) {
                    // Pass layout hooks up from the header bar component
                    SummaryHeader(
                        dateText: headerText,
                        isShowingCalendar: $isShowingCalendar
                    ) {
                        withAnimation(.spring(response: 0.35, dampingFraction: 0.75)) {
                            isShowingCalendar = true
                        }
                    }

                    PeriodToggle(selection: $viewModel.selectedPeriod, namespace: periodNamespace)

                    switch viewModel.selectedPeriod {
                    case .daily:  dailyContent
                    case .weekly: weeklyContent
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 8)
                .padding(.bottom, 100) // clear the floating tab bar
            }
            .disabled(isShowingCalendar) // Optional: freezes background scrolling while open
            .id(viewModel.currentDate)
            .onAppear {
                self.selectedDate = viewModel.currentDate
            }
            // CENTRALIZED MONITOR: Handles both opening and closing states of the calendar popup
            .onChange(of: isShowingCalendar) { oldValue, newValue in
                if newValue {
                    // If the calendar just popped open, sync state with the view model
                    self.selectedDate = viewModel.currentDate
                } else {
                    // If the calendar closed (via Done button OR background tap), update the view model!
                    viewModel.updateForDate(selectedDate)
                }
            }

            // TRUE GLOBAL POP-UP OVERLAY LAYER (Now at root level!)
            if isShowingCalendar {
                Group {
                    // 1. Full-screen dimming backdrop background
                    Color.black.opacity(0.4)
                        .ignoresSafeArea()
                        .onTapGesture {
                            dismissPopup()
                        }
                    
                    // 2. Centered Pop-up Card panel setup
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
                        .padding(.horizontal, 24)
                        .transition(.scale(scale: 0.85).combined(with: .opacity))
                }
                .zIndex(100) // Guarantees pop-up floats completely above everything
            }
        }
    }

    private var headerText: String {
        switch viewModel.selectedPeriod {
        case .daily:  viewModel.dateText
        case .weekly: viewModel.weekLabel
        }
    }

    private func dismissPopup() {
        withAnimation(.spring(response: 0.25, dampingFraction: 0.8)) {
            isShowingCalendar = false
            // Note: viewModel.updateForDate(selectedDate) is now handled automatically by .onChange above
        }
    }

    @ViewBuilder
    private var dailyContent: some View {
        HeroCharacterCard(headline: viewModel.headline, mood: viewModel.mood)
        SunExposureCard(intervals: viewModel.intervals)
        ProtectionLogCard(items: viewModel.protectionItems) { item in
            viewModel.toggleProtection(item)
        }
    }

    @ViewBuilder
    private var weeklyContent: some View {
        HeroCharacterCard(headline: viewModel.weeklyHeadline, mood: viewModel.weeklyMood)
        WeeklyExposureChart(days: viewModel.weekDays)
        ProtectionWeekGrid(rows: viewModel.protectionWeek)
    }
}

#Preview {
    SummaryView(viewModel: SummaryViewModel())
}
