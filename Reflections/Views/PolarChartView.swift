import SwiftUI

struct PolarChartView: View {
    let data: [(area: LifeArea, value: Double)]
    var showLabels: Bool = true
    var size: CGFloat = 300

    private let areas = LifeArea.allCases
    private let rings: [Double] = [0.2, 0.4, 0.6, 0.8, 1.0]

    var body: some View {
        ZStack {
            gridLayer
            dataLayer
            if showLabels { labelLayer }
        }
        .frame(width: size, height: size)
    }

    // MARK: - Grid
    private var gridLayer: some View {
        Canvas { ctx, sz in
            let center = CGPoint(x: sz.width / 2, y: sz.height / 2)
            let maxR = sz.width / 2 * 0.70

            // Rings
            for fraction in rings {
                let r = maxR * fraction
                var ringPath = Path()
                for (i, _) in areas.enumerated() {
                    let angle = angle(for: i)
                    let pt = point(center: center, angle: angle, radius: r)
                    if i == 0 { ringPath.move(to: pt) } else { ringPath.addLine(to: pt) }
                }
                ringPath.closeSubpath()
                ctx.stroke(ringPath, with: .color(Color.inkLight.opacity(0.35)), lineWidth: 0.5)
            }

            // Spokes
            for i in areas.indices {
                let ang = angle(for: i)
                var spoke = Path()
                spoke.move(to: center)
                spoke.addLine(to: point(center: center, angle: ang, radius: maxR))
                ctx.stroke(spoke, with: .color(Color.inkLight.opacity(0.30)), lineWidth: 0.5)
            }
        }
    }

    // MARK: - Data polygon
    private var dataLayer: some View {
        Canvas { ctx, sz in
            let center = CGPoint(x: sz.width / 2, y: sz.height / 2)
            let maxR = sz.width / 2 * 0.70

            var poly = Path()
            for (i, area) in areas.enumerated() {
                let val = (data.first { $0.area == area }?.value ?? 0) / 5.0
                let r = maxR * val
                let pt = point(center: center, angle: angle(for: i), radius: r)
                if i == 0 { poly.move(to: pt) } else { poly.addLine(to: pt) }
            }
            poly.closeSubpath()

            ctx.fill(poly, with: .color(Color.studyAccent.opacity(0.22)))
            ctx.stroke(poly, with: .color(Color.studyAccent.opacity(0.75)), lineWidth: 1.5)

            // Dots
            for (i, area) in areas.enumerated() {
                let val = (data.first { $0.area == area }?.value ?? 0) / 5.0
                let r = maxR * val
                let pt = point(center: center, angle: angle(for: i), radius: r)
                let dotRect = CGRect(x: pt.x - 3.5, y: pt.y - 3.5, width: 7, height: 7)
                ctx.fill(Path(ellipseIn: dotRect), with: .color(Color.studyAccent))
            }
        }
    }

    // MARK: - Labels
    private var labelLayer: some View {
        GeometryReader { geo in
            let center = CGPoint(x: geo.size.width / 2, y: geo.size.height / 2)
            let maxR = geo.size.width / 2 * 0.70
            let labelR = maxR * 1.22

            ForEach(Array(areas.enumerated()), id: \.element.id) { i, area in
                let ang = angle(for: i)
                let pt = point(center: center, angle: ang, radius: labelR)
                VStack(spacing: 2) {
                    Image(systemName: area.icon)
                        .font(.system(size: 9))
                    Text(area.rawValue)
                        .font(.reflectionSans(9))
                }
                .foregroundColor(.inkMedium)
                .frame(width: 52, height: 32)
                .position(x: pt.x, y: pt.y)
            }
        }
    }

    // MARK: - Helpers
    private func angle(for index: Int) -> Double {
        Double(index) * .pi * 2.0 / Double(areas.count) - .pi / 2.0
    }

    private func point(center: CGPoint, angle: Double, radius: CGFloat) -> CGPoint {
        CGPoint(
            x: center.x + CGFloat(cos(angle)) * radius,
            y: center.y + CGFloat(sin(angle)) * radius
        )
    }
}
