//
//  DialogueBubbleView.swift
//  date-the-sun
//
//  Created by I Gusti Ngurah Bagus Ferry Mahayudha on 29/05/26.
//

import SwiftUI

struct DialogueBubbleView: View {
    let text: String
    
    var body: some View {
        Text(text)
            .font(.system(size: 15, weight: .medium)) // Slightly smaller text font helps too!
            .foregroundColor(.black)
            .multilineTextAlignment(.center)
            .lineSpacing(3)
            
            // 👇 Reduce these numbers to shrink the bubble's footprint
            .padding(.horizontal, 14) // Down from 20
            .padding(.vertical, 10)   // Down from 16
            
            .background(
                RoundedRectangle(cornerRadius: 14, style: .continuous) // Slightly reduced radius for smaller bubble
                    .fill(Color.white)
                    .shadow(color: Color.black.opacity(0.12), radius: 12, x: 0, y: 6)
            )
    }
}

#Preview {
    DialogueBubbleView(text: "Halo")
}
