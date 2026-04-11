import SwiftUI

extension Color {
    static let parchment    = Color(red: 0.957, green: 0.933, blue: 0.886)
    static let inkDark      = Color(red: 0.188, green: 0.149, blue: 0.110)
    static let inkMedium    = Color(red: 0.420, green: 0.337, blue: 0.255)
    static let inkLight     = Color(red: 0.659, green: 0.584, blue: 0.506)
    static let inkFaint     = Color(red: 0.855, green: 0.820, blue: 0.776)
    static let studyAccent  = Color(red: 0.380, green: 0.318, blue: 0.506)

    static func areaColor(_ area: LifeArea) -> Color {
        let c = area.color
        return Color(red: c.r, green: c.g, blue: c.b)
    }
}

extension Font {
    static func reflectionSerif(_ size: CGFloat, weight: Font.Weight = .regular) -> Font {
        .custom("Georgia", size: size).weight(weight)
    }
    static func reflectionSans(_ size: CGFloat) -> Font {
        .system(size: size, design: .default)
    }
}

struct ParchmentBackground: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background(Color.parchment)
    }
}

struct CardStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background(Color.white.opacity(0.55))
            .cornerRadius(10)
            .shadow(color: Color.inkDark.opacity(0.08), radius: 6, x: 0, y: 2)
    }
}

extension View {
    func parchmentBackground() -> some View {
        modifier(ParchmentBackground())
    }
    func cardStyle() -> some View {
        modifier(CardStyle())
    }
}
