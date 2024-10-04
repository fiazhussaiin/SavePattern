

import SwiftUI

struct CreatePatternView: View {
    @State private var primaryColor = Color.red
    @State private var secondaryColor = Color.blue
    @State private var patternType = "Stripes"
    
    @State private var savedPatterns: [Pattern] = []
    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var showActionSheet = false
    @State private var selectedPattern: Pattern?
    
    @State private var lines: [Line] = [] // To store drawn lines
    @State private var currentLine: Line = Line(points: [])
    
    var body: some View {
        VStack(spacing: 20) {
            ZStack {
                // Pattern Drawing Area
                PatternView(pattern: Pattern(primaryColor: primaryColor, secondaryColor: secondaryColor, type: patternType))
                    .frame(width: 200, height: 200)
                    .border(Color.gray, width: 1)
                    .padding(.bottom, 20)
                
                // Drawing Canvas
                Canvas { context, size in
                    for line in lines {
                        var path = Path()
                        guard let firstPoint = line.points.first else { continue }
                        path.move(to: firstPoint)
                        for point in line.points.dropFirst() {
                            path.addLine(to: point)
                        }
                        context.stroke(path, with: .color(.black), lineWidth: 2) // Drawing line with black color
                    }
                }
                .frame(width: 200, height: 200)
                .gesture(
                    DragGesture(minimumDistance: 0)
                        .onChanged { value in
                            currentLine.points.append(value.location)
                            lines.append(currentLine)
                        }
                        .onEnded { _ in
                            lines.append(currentLine)
                            currentLine = Line(points: [])
                        }
                )
            }
            
            // Color Pickers
            ColorPicker("Primary Color", selection: $primaryColor)
            ColorPicker("Secondary Color", selection: $secondaryColor)
            
            // Pattern Type Picker
            Picker("Pattern Type", selection: $patternType) {
                Text("Stripes").tag("Stripes")
                Text("Polka Dots").tag("Polka Dots")
                Text("Checkerboard").tag("Checkerboard")
            }
            .pickerStyle(SegmentedPickerStyle())
            
            // Save Button
            Button(action: savePattern) {
                Text("Save Pattern")
                    .font(.headline)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            
            // Action Buttons
            if let selectedPattern = selectedPattern {
                HStack {
                    Button(action: {
                        sharePattern(selectedPattern)
                    }) {
                        Label("Share", systemImage: "square.and.arrow.up")
                            .padding()
                            .background(Color.green)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    Button(action: {
                        copyPattern(selectedPattern)
                    }) {
                        Label("Copy", systemImage: "doc.on.doc")
                            .padding()
                            .background(Color.orange)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    Button(action: {
                        savePatternToPhotos(selectedPattern)
                    }) {
                        Label("Download", systemImage: "square.and.arrow.down")
                            .padding()
                            .background(Color.purple)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                }
                .padding(.top)
            }
        }
        .padding()
        .navigationTitle("Create Pattern")
        .alert(isPresented: $showAlert) {
            Alert(title: Text("Action Result"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
        }
        .actionSheet(isPresented: $showActionSheet) {
            ActionSheet(
                title: Text("Choose an action"),
                buttons: [
                    .default(Text("Share")) {
                        if let pattern = selectedPattern {
                            sharePattern(pattern)
                        }
                    },
                    .default(Text("Copy")) {
                        if let pattern = selectedPattern {
                            copyPattern(pattern)
                        }
                    },
                    .default(Text("Download")) {
                        if let pattern = selectedPattern {
                            savePatternToPhotos(pattern)
                        }
                    },
                    .cancel()
                ]
            )
        }
    }
    
    func savePattern() {
        let newPattern = Pattern(primaryColor: primaryColor, secondaryColor: secondaryColor, type: patternType)
        savedPatterns.append(newPattern)
        selectedPattern = newPattern
        let patternImage = createPatternImage(for: newPattern)
        
        // Convert the image to Data
        if let imageData = patternImage.pngData() {
            // Retrieve existing patterns from UserDefaults
            var savedPatternsData = UserDefaults.standard.data(forKey: "savedPatterns") ?? Data()
            var savedPatterns = loadPatterns(from: savedPatternsData)
            
            // Add new pattern data
            savedPatterns.append(imageData)
            
            // Save the updated patterns to UserDefaults
            if let updatedPatternsData = try? JSONEncoder().encode(savedPatterns) {
                UserDefaults.standard.set(updatedPatternsData, forKey: "savedPatterns")
            }
            alertMessage = "Pattern saved successfully!"
            showAlert = true
        }
    }
    
    func loadPatterns(from data: Data) -> [Data] {
        // Decode the saved pattern data
        return (try? JSONDecoder().decode([Data].self, from: data)) ?? []
    }
    
    
    func sharePattern(_ pattern: Pattern) {
        let patternImage = createPatternImage(for: pattern)
        let activityVC = UIActivityViewController(activityItems: [patternImage], applicationActivities: nil)
        if let vc = UIApplication.shared.windows.first?.rootViewController {
            vc.present(activityVC, animated: true, completion: nil)
        }
    }
    
    func copyPattern(_ pattern: Pattern) {
        let patternImage = createPatternImage(for: pattern)
        UIPasteboard.general.image = patternImage
        alertMessage = "Pattern copied to clipboard!"
        showAlert = true
    }
    
    func savePatternToPhotos(_ pattern: Pattern) {
        let patternImage = createPatternImage(for: pattern)
        UIImageWriteToSavedPhotosAlbum(patternImage, nil, nil, nil)
        alertMessage = "Pattern saved to Photos!"
        showAlert = true
    }
    
    func createPatternImage(for pattern: Pattern) -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: 200, height: 200))
        return renderer.image { ctx in
            // Pattern drawing logic
            ctx.cgContext.setFillColor(pattern.primaryColor.cgColor!)
            ctx.cgContext.fill(CGRect(x: 0, y: 0, width: 200, height: 200))
            
            // Additional drawing logic based on pattern.type and secondaryColor
            if pattern.type == "Stripes" {
                drawStripes(in: ctx.cgContext, color: pattern.secondaryColor)
            } else if pattern.type == "Polka Dots" {
                drawPolkaDots(in: ctx.cgContext, color: pattern.secondaryColor)
            } else if pattern.type == "Checkerboard" {
                drawCheckerboard(in: ctx.cgContext, color: pattern.secondaryColor)
            }
            
            // Draw the lines on top of the pattern
            ctx.cgContext.setLineWidth(2)
            ctx.cgContext.setStrokeColor(UIColor.black.cgColor)
            for line in lines {
                guard let firstPoint = line.points.first else { continue }
                ctx.cgContext.beginPath()
                ctx.cgContext.move(to: firstPoint)
                for point in line.points.dropFirst() {
                    ctx.cgContext.addLine(to: point)
                }
                ctx.cgContext.strokePath()
            }
        }
    }
    
    func drawStripes(in context: CGContext, color: Color) {
        if let cgColor = color.cgColor {
            context.setFillColor(cgColor)
            for i in stride(from: 0, to: 200, by: 20) {
                context.fill(CGRect(x: CGFloat(i), y: 0, width: 10, height: 200))
            }
        } else {
            // Handle the case where cgColor is nil
            context.setFillColor(UIColor.red.cgColor) // Fallback color
            for i in stride(from: 0, to: 200, by: 20) {
                context.fill(CGRect(x: CGFloat(i), y: 0, width: 10, height: 200))
            }
        }
    }
    
    func drawPolkaDots(in context: CGContext, color: Color) {
        if let cgColor = color.cgColor {
            context.setFillColor(cgColor)
            for x in stride(from: 20, to: 200, by: 40) {
                for y in stride(from: 20, to: 200, by: 40) {
                    context.fillEllipse(in: CGRect(x: x, y: y, width: 20, height: 20))
                }
            }
        } else {
            // Handle the case where cgColor is nil
            context.setFillColor(UIColor.red.cgColor) // Fallback color
            for x in stride(from: 20, to: 200, by: 40) {
                for y in stride(from: 20, to: 200, by: 40) {
                    context.fillEllipse(in: CGRect(x: x, y: y, width: 20, height: 20))
                }
            }
        }
    }
    
    func drawCheckerboard(in context: CGContext, color: Color) {
        if let cgColor = color.cgColor {
            context.setFillColor(cgColor)
            for x in stride(from: 0, to: 200, by: 40) {
                for y in stride(from: 0, to: 200, by: 40) {
                    if (x + y) % 80 == 0 {
                        context.fill(CGRect(x: x, y: y, width: 40, height: 40))
                    }
                }
            }
        } else {
            // Handle the case where cgColor is nil
            context.setFillColor(UIColor.red.cgColor) // Fallback color
            for x in stride(from: 0, to: 200, by: 40) {
                for y in stride(from: 0, to: 200, by: 40) {
                    if (x + y) % 80 == 0 {
                        context.fill(CGRect(x: x, y: y, width: 40, height: 40))
                    }
                }
            }
        }
    }
}

struct Line {
    var points: [CGPoint]
}







struct PatternView: View {
    let pattern: Pattern

    var body: some View {
        Image(uiImage: createPatternImage(for: pattern))
            .resizable()
            .aspectRatio(contentMode: .fit)
    }
    
    func createPatternImage(for pattern: Pattern) -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: 200, height: 200))
        return renderer.image { ctx in
            let primaryCGColor = pattern.primaryColor.cgColor ?? UIColor.red.cgColor
            ctx.cgContext.setFillColor(primaryCGColor)
            ctx.cgContext.fill(CGRect(x: 0, y: 0, width: 200, height: 200))
            
            // Additional drawing logic based on pattern.type and secondaryColor
            if pattern.type == "Stripes" {
                drawStripes(in: ctx.cgContext, color: pattern.secondaryColor)
            } else if pattern.type == "Polka Dots" {
                drawPolkaDots(in: ctx.cgContext, color: pattern.secondaryColor)
            } else if pattern.type == "Checkerboard" {
                drawCheckerboard(in: ctx.cgContext, color: pattern.secondaryColor)
            }
        }
    }

    
    func drawStripes(in context: CGContext, color: Color) {
        if let cgColor = color.cgColor {
            context.setFillColor(cgColor)
            for i in stride(from: 0, to: 200, by: 20) {
                context.fill(CGRect(x: CGFloat(i), y: 0, width: 10, height: 200))
            }
        } else {
            // Handle the case where cgColor is nil
            context.setFillColor(UIColor.red.cgColor) // Fallback color
            for i in stride(from: 0, to: 200, by: 20) {
                context.fill(CGRect(x: CGFloat(i), y: 0, width: 10, height: 200))
            }
        }
    }

    func drawPolkaDots(in context: CGContext, color: Color) {
        if let cgColor = color.cgColor {
            context.setFillColor(cgColor)
            for x in stride(from: 20, to: 200, by: 40) {
                for y in stride(from: 20, to: 200, by: 40) {
                    context.fillEllipse(in: CGRect(x: x, y: y, width: 20, height: 20))
                }
            }
        } else {
            // Handle the case where cgColor is nil
            context.setFillColor(UIColor.red.cgColor) // Fallback color
            for x in stride(from: 20, to: 200, by: 40) {
                for y in stride(from: 20, to: 200, by: 40) {
                    context.fillEllipse(in: CGRect(x: x, y: y, width: 20, height: 20))
                }
            }
        }
    }

    func drawCheckerboard(in context: CGContext, color: Color) {
        if let cgColor = color.cgColor {
            context.setFillColor(cgColor)
            for x in stride(from: 0, to: 200, by: 40) {
                for y in stride(from: 0, to: 200, by: 40) {
                    if (x + y) % 80 == 0 {
                        context.fill(CGRect(x: x, y: y, width: 40, height: 40))
                    }
                }
            }
        } else {
            // Handle the case where cgColor is nil
            context.setFillColor(UIColor.red.cgColor) // Fallback color
            for x in stride(from: 0, to: 200, by: 40) {
                for y in stride(from: 0, to: 200, by: 40) {
                    if (x + y) % 80 == 0 {
                        context.fill(CGRect(x: x, y: y, width: 40, height: 40))
                    }
                }
            }
        }
    }

}

