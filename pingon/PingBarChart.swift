import SwiftUI

struct PingBarChart: View {
    let pingResults: [Int]
    
    var body: some View {
        GeometryReader { geometry in
            HStack(alignment: .bottom, spacing: 1) {
                ForEach(0..<pingResults.count, id: \.self) { index in
                    let result = pingResults[index]
                    let height = CGFloat(result) / 100 * geometry.size.height
                    Rectangle()
                        .fill(self.color(for: result))  // Call a helper function to determine color
                        .frame(width: geometry.size.width / CGFloat(pingResults.count), height: height)
                }
            }
        }
    }
    
    // Helper function to determine color based on ping result
    private func color(for result: Int) -> Color {
        switch result {
        case ..<30:
            return .green
        case 31...90:
            return .yellow
        default:
            return .red
        }
    }
}
