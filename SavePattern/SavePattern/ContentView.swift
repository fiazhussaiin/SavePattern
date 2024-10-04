

import SwiftUI

struct ContentView: View {

        var body: some View {
            NavigationView {
                ZStack {
                    LinearGradient(gradient: Gradient(colors: [Color.orange, Color.pink]), startPoint: .top, endPoint: .bottom)
                        .edgesIgnoringSafeArea(.all)
                    
                    VStack(spacing: 30) {
                        Text("Welcome to SavePattern")
                            .font(.largeTitle)
                            .foregroundColor(.white)
                        
                        NavigationLink(destination: CreatePatternView()) {
                            Text("Create New Pattern")
                                .font(.headline)
                                .padding()
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(15)
                        }
                        
                        NavigationLink(destination: SavedPatternsView()) {
                            Text("View Saved Patterns")
                                .font(.headline)
                                .padding()
                                .background(Color.green)
                                .foregroundColor(.white)
                                .cornerRadius(15)
                        }
                    }
                }
                .navigationTitle("SavePattern")
            }
        }
    }
#Preview {
    ContentView()
}
