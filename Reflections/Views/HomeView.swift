import SwiftUI
import SwiftData

struct HomeView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \ReflectionSession.date, order: .reverse) private var sessions: [ReflectionSession]
    @Binding var selectedTab: AppTab

    var body: some View {
        ScrollView {
            VStack(spacing: 40) {
                // Header
                VStack(spacing: 8) {
                    Text("Reflections")
                        .font(.reflectionSerif(42, weight: .regular))
                        .foregroundColor(.inkDark)
                    Text(formattedDate)
                        .font(.reflectionSans(14))
                        .foregroundColor(.inkLight)
                }
                .padding(.top, 40)

                // Polar chart of latest session
                if let latest = sessions.first {
                    VStack(spacing: 16) {
                        Text("Last Reflection · \(latest.date.formatted(date: .abbreviated, time: .omitted))")
                            .font(.reflectionSans(12))
                            .foregroundColor(.inkLight)
                            .textCase(.uppercase)
                            .tracking(1.2)

                        PolarChartView(data: latest.areaAverages, size: 280)

                        // Area scores row
                        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 4), spacing: 10) {
                            ForEach(LifeArea.allCases) { area in
                                let val = latest.averageRating(for: area)
                                AreaScoreBadge(area: area, value: val)
                            }
                        }
                    }
                    .padding(24)
                    .cardStyle()
                } else {
                    VStack(spacing: 14) {
                        Image(systemName: "book.closed")
                            .font(.system(size: 36))
                            .foregroundColor(.inkFaint)
                        Text("No reflections yet.")
                            .font(.reflectionSerif(18))
                            .foregroundColor(.inkMedium)
                        Text("Begin your first session to see your landscape here.")
                            .font(.reflectionSans(13))
                            .foregroundColor(.inkLight)
                            .multilineTextAlignment(.center)
                    }
                    .padding(40)
                    .cardStyle()
                }

                // Begin Reflection button
                Button {
                    selectedTab = .reflect
                } label: {
                    HStack(spacing: 10) {
                        Image(systemName: "pencil")
                        Text("Begin a Reflection")
                            .font(.reflectionSerif(16))
                    }
                    .foregroundColor(Color.parchment)
                    .padding(.horizontal, 32)
                    .padding(.vertical, 14)
                    .background(Color.inkDark)
                    .cornerRadius(8)
                }
                .buttonStyle(.plain)

                Spacer(minLength: 40)
            }
            .padding(.horizontal, 32)
        }
        .parchmentBackground()
    }

    var formattedDate: String {
        let f = DateFormatter()
        f.dateFormat = "EEEE, MMMM d, yyyy"
        return f.string(from: Date())
    }
}

struct AreaScoreBadge: View {
    let area: LifeArea
    let value: Double

    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: area.icon)
                .font(.system(size: 14))
                .foregroundColor(Color.areaColor(area))
            Text(String(format: "%.1f", value))
                .font(.reflectionSerif(15))
                .foregroundColor(.inkDark)
            Text(area.rawValue)
                .font(.reflectionSans(9))
                .foregroundColor(.inkLight)
                .lineLimit(1)
        }
        .padding(.vertical, 8)
        .frame(maxWidth: .infinity)
        .background(Color.areaColor(area).opacity(0.08))
        .cornerRadius(8)
    }
}
