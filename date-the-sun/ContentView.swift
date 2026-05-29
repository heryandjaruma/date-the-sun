//
//  ContentView.swift
//  date-the-sun
//
//  Created by Heryan Djaruma on 28/05/26.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @State private var selection: AppTab = .today
    @Namespace private var tabNamespace

    var body: some View {
        ZStack(alignment: .bottom) {
            switch selection {
            case .today:
                MainScreenView()
            case .summary:
                SummaryView()
            }

            FloatingTabBar(selection: $selection, namespace: tabNamespace)
                .padding(.bottom, 6)
        }
        .ignoresSafeArea(.keyboard)
    }
}

#Preview {
    ContentView()
}
