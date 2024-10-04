

import SwiftUI

// Define the Pattern struct
struct Pattern: Identifiable {
    let id = UUID() // Unique identifier for each pattern
    let primaryColor: Color
    let secondaryColor: Color
    let type: String // Type of the pattern, e.g., "Stripes", "Polka Dots"
}

struct SavedPatternsView: View {
    @State private var savedImages: [UIImage] = []
    @State private var showActionSheet = false
    @State private var selectedImage: UIImage?
    
    enum ActionType {
        case copy, share, download, delete
    }

    var body: some View {
        ScrollView {
            LazyVGrid(columns: [GridItem(), GridItem()]) {
                ForEach(savedImages.indices, id: \.self) { index in
                    VStack {
                        Image(uiImage: savedImages[index])
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(height: 100)
                            .border(Color.gray, width: 1)
                        
                        Button("More Features") {
                            selectedImage = savedImages[index]
                            showActionSheet = true
                        }
                    }
                    .padding()
                }
            }
        }
        .navigationTitle("Saved Patterns")
        .actionSheet(isPresented: $showActionSheet) {
            ActionSheet(
                title: Text("Choose an action"),
                buttons: [
                    .default(Text("Copy")) {
                        if let image = selectedImage {
                            copyImage(image)
                        }
                    },
                    .default(Text("Share")) {
                        if let image = selectedImage {
                            shareImage(image)
                        }
                    },
                    .default(Text("Download")) {
                        if let image = selectedImage {
                            saveImageToPhotos(image)
                        }
                    },
                    .destructive(Text("Delete")) {
                        if let image = selectedImage {
                            deleteImage(image)
                        }
                    },
                    .cancel()
                ]
            )
        }
        .onAppear(perform: loadImages)
    }
    
    func copyImage(_ image: UIImage) {
        UIPasteboard.general.image = image
        showAlert(message: "Image copied to clipboard!")
    }

    func shareImage(_ image: UIImage) {
        let activityVC = UIActivityViewController(activityItems: [image], applicationActivities: nil)
        if let vc = UIApplication.shared.windows.first?.rootViewController {
            vc.present(activityVC, animated: true, completion: nil)
        }
    }

    func saveImageToPhotos(_ image: UIImage) {
        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
        showAlert(message: "Image saved to Photos!")
    }
    
    func deleteImage(_ image: UIImage) {
        if let index = savedImages.firstIndex(where: { $0 == image }) {
            savedImages.remove(at: index)
            saveImages() // Save the updated images list to UserDefaults
            showAlert(message: "Image deleted!")
        }
    }
    
    func showAlert(message: String) {
        let alert = UIAlertController(title: "Notification", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        if let vc = UIApplication.shared.windows.first?.rootViewController {
            vc.present(alert, animated: true, completion: nil)
        }
    }
    
    func loadImages() {
        if let data = UserDefaults.standard.data(forKey: "savedPatterns"),
           let imageDataArray = try? JSONDecoder().decode([Data].self, from: data) {
            savedImages = imageDataArray.compactMap { UIImage(data: $0) }
        }
    }
    
    func saveImages() {
        let imageDataArray = savedImages.compactMap { $0.pngData() }
        if let updatedImagesData = try? JSONEncoder().encode(imageDataArray) {
            UserDefaults.standard.set(updatedImagesData, forKey: "savedPatterns")
        }
    }
}
