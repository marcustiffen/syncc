//
//  SplashView.swift
//  SYNC
//
//  Created by Marcus Tiffen (CODING) on 23/10/2024.
//

import SwiftUI

struct SplashView: View {
    
    @State private var showSignInView: Bool = false
    @State private var isActive: Bool = false
    
    var body: some View {
        ZStack {
            if self.isActive {
                NavigationStack {
                    ContentView(showSignInView: $showSignInView)
                }
            } else {
                splashView
            }
        }
        .onAppear {
            // Logic to load data first
            showSignInView = true // set to true for now
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                withAnimation {
                    self.isActive = true
                }
            }
        }
    }
    
    private var splashView: some View {
        Group {
            Rectangle()
                .fill(.blue)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .ignoresSafeArea()
            Text("Splash Screen")
                .foregroundStyle(.white)
        }
    }
}

#Preview {
    SplashView()
}
