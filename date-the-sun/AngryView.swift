//
//  AngryView.swift
//  date-the-sun
//
//  Created by I Gusti Ngurah Bagus Ferry Mahayudha on 29/05/26.
//

import SwiftUI

struct AngryView: View {
    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM d, yyyy" // MMMM = Full Month name, d = Day, yyyy = Year
        return formatter.string(from: Date())
    }
    
    var body: some View {
        
        ZStack {
            
            Color(red: 1.0, green: 0.94, blue: 0.94)
                    .ignoresSafeArea()
                
            // 2. The glowing circular/elliptical gradient layer
            GeometryReader { geometry in
                EllipticalGradient(
                    colors: [Color.red.opacity(0.35), Color.clear], // 👈 Changed from .blue to .red
                    center: .center
                )
                // Make the gradient shape a massive circle/ellipse relative to the screen width
                .frame(width: geometry.size.width * 1.5, height: geometry.size.width * 1.5)
                // Blur the gradient edges heavily to make it look like light bleeding out
                .blur(radius: 60)
                // Position it slightly offset to the right where the character stands
                .position(x: geometry.size.width * 0.8, y: geometry.size.height * 0.6)
            }
            .ignoresSafeArea()
            
            VStack {
                
                Spacer()
                
                HStack {
                    Spacer()
                    Image("angry_kiran_1") // Your asset
                        .resizable()
                        .scaledToFit()
                        .frame(width: 500, height: 800)
                        .offset(x: 10, y: 70)
                }
            }
            .ignoresSafeArea(edges: .bottom)
            
            // 3. Floating UI Overlay Layer (Front layer of content)
            VStack(spacing: 16) {
                // Header
                HStack(alignment: .lastTextBaseline) {
                    Text("Today")
                        .font(.largeTitle)
                        .bold()
                    Spacer()
                    Text(formattedDate)
                        .foregroundColor(.secondary)
                }
                .padding(.horizontal)
                .frame(width: UIScreen.main.bounds.width)
                
                UVBadgeView()
                .padding()
                
                Spacer()
                
                // Middle area: Dialogue bubble pushed over to the left
                HStack {
                    DialogueBubbleView(text: "You’re spending way too much time with me, do you want to get burned or something?")
                        .frame(maxWidth: 190) // Constrain width so it wraps beautifully
                        .padding(.leading, 65)
                        .offset(y: -60)
                    Spacer() // Pushes bubble to the left away from character center
                }
                
                Spacer() // Keeps space clear for your TabView at the very bottom
            }
        }
    }
}

#Preview {
    AngryView()
}
