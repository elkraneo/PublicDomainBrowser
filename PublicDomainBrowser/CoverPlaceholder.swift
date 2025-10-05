import SwiftUI

struct CoverPlaceholder: View {
    let size: CGSize

    init(width: CGFloat = 60, height: CGFloat = 90) {
        self.size = CGSize(width: width, height: height)
    }

    var body: some View {
        RoundedRectangle(cornerRadius: 6)
            .fill(Color.secondary.opacity(0.15))
            .overlay {
                Image(systemName: "book")
                    .font(.title2)
                    .foregroundStyle(.secondary)
            }
            .frame(width: size.width, height: size.height)
    }
}
