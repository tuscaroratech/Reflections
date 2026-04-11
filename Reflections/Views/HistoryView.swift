import SwiftUI
import SwiftData

struct HistoryView: View {
    @Query(sort: \ReflectionSession.date, order: .reverse) private var sessions: [ReflectionSession]
    @State private var selectedSession: ReflectionSession? = nil

    var body: some View {
        HSplitView {
            // Session list
            VStack(alignment: .leading, spacing: 0) {
                Text("Past Reflections")
                    .font(.reflectionSerif(22))
                    .foregroundColor(.inkDark)
                    .padding(.horizontal, 18)
                    .padding(.top, 26)
                    .padding(.bottom, 14)

                if sessions.isEmpty {
                    VStack(spacing: 10) {
                        Image(systemName: "clock")
                            .font(.system(size: 28))
                            .foregroundColor(.inkFaint)
                        Text("No history yet.")
                            .font(.reflectionSans(13))
                            .foregroundColor(.inkLight)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    List(sessions, selection: $selectedSession) { session in
                        SessionListRow(session: session)
                            .tag(session)
                            .listRowBackground(selectedSession?.id == session.id ? Color.inkFaint.opacity(0.5) : Color.clear)
                    }
                    .listStyle(.plain)
                    .onAppear {
                        if selectedSession == nil { selectedSession = sessions.first }
                    }
                }
            }
            .frame(minWidth: 180, maxWidth: 220)
            .parchmentBackground()

            // Detail
            if let session = selectedSession {
                SessionDetailView(session: session)
            } else {
                Text("Select a reflection")
                    .font(.reflectionSans(14))
                    .foregroundColor(.inkLight)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .parchmentBackground()
            }
        }
    }
}

struct SessionListRow: View {
    let session: ReflectionSession

    var body: some View {
        VStack(alignment: .leading, spacing: 3) {
            Text(session.date.formatted(date: .abbreviated, time: .omitted))
                .font(.reflectionSerif(14))
                .foregroundColor(.inkDark)
            Text(session.date.formatted(date: .omitted, time: .shortened))
                .font(.reflectionSans(11))
                .foregroundColor(.inkLight)
        }
        .padding(.vertical, 4)
    }
}

struct SessionDetailView: View {
    let session: ReflectionSession

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 28) {
                // Header
                VStack(alignment: .leading, spacing: 6) {
                    Text(session.date.formatted(date: .complete, time: .omitted))
                        .font(.reflectionSerif(26))
                        .foregroundColor(.inkDark)
                    if !session.sessionNotes.isEmpty {
                        Text(session.sessionNotes)
                            .font(.reflectionSans(13))
                            .foregroundColor(.inkMedium)
                            .italic()
                    }
                }

                // Polar chart
                HStack {
                    Spacer()
                    PolarChartView(data: session.areaAverages, size: 260)
                    Spacer()
                }
                .padding(20)
                .cardStyle()

                // Answers grouped by area
                ForEach(LifeArea.allCases) { area in
                    let areaAnswers = session.answers.filter { $0.question?.areaRaw == area.rawValue }
                    if !areaAnswers.isEmpty {
                        AreaAnswerSection(area: area, answers: areaAnswers, avgRating: session.averageRating(for: area))
                    }
                }

                Spacer(minLength: 40)
            }
            .padding(.horizontal, 28)
            .padding(.top, 28)
        }
        .parchmentBackground()
    }
}

struct AreaAnswerSection: View {
    let area: LifeArea
    let answers: [ReflectionAnswer]
    let avgRating: Double

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 8) {
                Image(systemName: area.icon)
                    .foregroundColor(Color.areaColor(area))
                Text(area.rawValue)
                    .font(.reflectionSerif(18))
                    .foregroundColor(.inkDark)
                Spacer()
                Text(String(format: "avg %.1f", avgRating))
                    .font(.reflectionSans(12))
                    .foregroundColor(.inkLight)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(Color.areaColor(area).opacity(0.12))
                    .cornerRadius(5)
            }

            ForEach(answers) { answer in
                VStack(alignment: .leading, spacing: 6) {
                    if let q = answer.question {
                        Text(q.text)
                            .font(.reflectionSans(13))
                            .foregroundColor(.inkMedium)
                    }
                    HStack(spacing: 4) {
                        ForEach(1...5, id: \.self) { n in
                            Image(systemName: n <= answer.rating ? "circle.fill" : "circle")
                                .font(.system(size: 9))
                                .foregroundColor(n <= answer.rating ? Color.areaColor(area) : Color.inkFaint)
                        }
                        Text("(\(answer.rating)/5)")
                            .font(.reflectionSans(11))
                            .foregroundColor(.inkLight)
                    }
                    if !answer.longFormAnswer.isEmpty {
                        Text(answer.longFormAnswer)
                            .font(.reflectionSans(13))
                            .foregroundColor(.inkDark)
                            .fixedSize(horizontal: false, vertical: true)
                            .padding(10)
                            .background(Color.inkFaint.opacity(0.25))
                            .cornerRadius(6)
                    }
                }
                .padding(.leading, 4)

                if answer.id != answers.last?.id {
                    Divider().opacity(0.3)
                }
            }
        }
        .padding(18)
        .cardStyle()
    }
}
