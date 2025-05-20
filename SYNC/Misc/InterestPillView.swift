//
//  InterestPillView.swift
//  SYNC
//
//  Created by Marcus Tiffen (CODING) on 17/12/2024.
//

import Foundation
import SwiftUI

struct InterestPillView: View {
    
    var emoji: String
    var name: String
    var backgroundColour: Color
    var foregroundColour: Color
    
    var body: some View {
        HStack(spacing: 2) {
            Text(emoji)
            Text(name)
        }
        .lineLimit(1)
        .bodyTextStyle()
        .padding(.vertical, 6)
        .padding(.horizontal, 12)
        .foregroundStyle(foregroundColour)
        .background(backgroundColour)
        .clipShape(.rect(cornerRadius: 32))
    }
}


//struct ProfileCardPillView: View {
//    var emoji: String
//    var name: String
//    var backgroundColour: Color
//    var foregroundColour: Color
//    
//    var body: some View {
//        HStack(spacing: 2) {
//            Text(emoji)
//            Text(name)
//        }
//        .lineLimit(1)
////        .font(.callout)
////        .fontWeight(.medium)
//        .font(.system(size: 16))
//        .padding(.vertical, 6)
//        .padding(.horizontal, 12)
//        .foregroundStyle(foregroundColour)
//        .background(backgroundColour)
//        .clipShape(.rect(cornerRadius: 32))
//    }
//}
