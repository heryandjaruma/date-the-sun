//
//  UVBadgeView.swift
//  date-the-sun
//
//  Created by I Gusti Ngurah Bagus Ferry Mahayudha on 29/05/26.
//

import SwiftUI

struct UVBadgeView: View {
    var body: some View {
        HStack(spacing: 6) {
            // Sun Icon (SF Symbols)
            Image(systemName: "sun.max")
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(Color(red: 0.95, green: 0.82, blue: 0.29)) // Custom gold/yellow
            
            // Styled Text Group
            Text("**UV 3** Moderate")
                .fontWeight(.regular)
                .foregroundColor(.white)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 6)
        .background(
            Capsule()
                .fill(Color(red: 0.93, green: 0.53, blue: 0.18)) // Main orange background
        )
        .overlay(
            Capsule()
                .stroke(Color(red: 0.70, green: 0.35, blue: 0.08), lineWidth: 1.5) // Darker orange border
        )
        .shadow(color: Color.black.opacity(0.15), radius: 4, x: 0, y: 3) // Soft floating shadow
    }
}

#Preview {
    UVBadgeView()
}
