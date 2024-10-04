

import SwiftUI

@main
struct SavePatternApp: App {
    var body: some Scene {
        WindowGroup {
            SplashScreen()
        }
    }
}

struct SplashScreen: View {
    @State private var isActive = false
    
    var body: some View {
        VStack {
            if isActive {
                ContentView()
            } else {
                Image("logo")
                    .resizable()
                    .frame(width: 250, height: 250)
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                            withAnimation {
                                isActive = true
                            }
                        }
                    }
            }
        }
    }
}
