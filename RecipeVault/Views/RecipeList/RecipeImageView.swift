import SwiftUI

/// Displays a recipe's image or a placeholder icon.
struct RecipeImageView: View {
    let imageData: Data?
    var size: CGFloat = 44

    var body: some View {
        Group {
            if let imageData, let cgImage = Self.makeCGImage(from: imageData) {
                Image(decorative: cgImage, scale: 1)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } else {
                Image(systemName: "fork.knife.circle.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .foregroundStyle(.secondary)
                    .padding(size * 0.15)
            }
        }
        .frame(width: size, height: size)
        .background(.quaternary)
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }

    private static func makeCGImage(from data: Data) -> CGImage? {
        #if canImport(UIKit)
        return UIImage(data: data)?.cgImage
        #elseif canImport(AppKit)
        guard let nsImage = NSImage(data: data) else { return nil }
        return nsImage.cgImage(forProposedRect: nil, context: nil, hints: nil)
        #endif
    }
}

#Preview {
    HStack {
        RecipeImageView(imageData: nil)
        RecipeImageView(imageData: nil, size: 80)
    }
    .padding()
}
