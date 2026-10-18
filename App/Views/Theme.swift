import SwiftUI

extension Color {
    static let atlasInk = Color(red: 0.065, green: 0.096, blue: 0.18)
    static let atlasBlue = Color(red: 0.29, green: 0.43, blue: 0.94)
    static let atlasViolet = Color(red: 0.63, green: 0.41, blue: 0.98)
    static let atlasTeal = Color(red: 0.10, green: 0.69, blue: 0.64)
    static let atlasSand = Color(red: 0.96, green: 0.97, blue: 0.99)
}

struct AtlasSurface<Content: View>: View {
    let content: Content
    init(@ViewBuilder content: () -> Content) { self.content = content() }
    var body: some View {
        content.padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(.white, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
            .overlay(RoundedRectangle(cornerRadius: 20).stroke(Color.black.opacity(0.045)))
    }
}

struct AtlasTitle: View {
    let title: String
    let subtitle: String
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title).font(.system(size: 27, weight: .bold, design: .rounded)).foregroundStyle(Color.atlasInk)
            Text(subtitle).font(.subheadline).foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

struct AtlasPill: View {
    let text: String
    let tint: Color
    var body: some View {
        Text(text).font(.caption2.bold()).padding(.horizontal, 10).padding(.vertical, 5)
            .foregroundStyle(tint).background(tint.opacity(0.12), in: Capsule())
    }
}

struct AtlasGateBadge: View {
    let allowed: Bool
    var body: some View {
        Label(allowed ? "Доступно" : "Закрыто", systemImage: allowed ? "checkmark.seal.fill" : "lock.fill")
            .font(.caption.weight(.semibold))
            .foregroundStyle(allowed ? Color.atlasTeal : Color.orange)
    }
}
