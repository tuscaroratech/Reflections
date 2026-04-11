import SwiftUI
import SwiftData

struct ReflectionSessionView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \ReflectionQuestion.sortOrder) private var questions: [ReflectionQuestion]
    @State private var currentAreaIndex = 0
    @State private var ratings: [UUID: Int] = [:]
    @State private var longAnswers: [UUID: String] = [:]
    @State private var sessionNotes = ""
    @State private var isComplete = false

    var currentArea: LifeArea { LifeArea.allCases[currentAreaIndex] }
    var currentQuestions: [ReflectionQuestion] {
        questions.filter { $0.areaRaw == currentArea.rawValue }
    }
    var totalAreas: Int { LifeArea.allCases.count }
    var hasQuestionsAnywhere: Bool { !questions.isEmpty }
    var canProceed: Bool {
        currentQuestions.allSatisfy { ratings[$0.id] != nil }
    }

    var body: some View {
        if isComplete {
            CompletionView(sessionNotes: $sessionNotes, onSave: saveSession, onDiscard: reset)
        } else if !hasQuestionsAnywhere {
            VStack(spacing: 16) {
                Image(systemName: "text.badge.plus")
                    .font(.system(size: 40))
                    .foregroundColor(.inkFaint)
                Text("No questions yet.")
                    .font(.reflectionSerif(20))
                    .foregroundColor(.inkMedium)
                Text("Add questions in the Questions tab before reflecting.")
                    .font(.reflectionSans(14))
                    .foregroundColor(.inkLight)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .parchmentBackground()
        } else {
            ScrollView {
                VStack(spacing: 32) {
                    // Progress header
                    VStack(spacing: 10) {
                        HStack {
                            ForEach(Array(LifeArea.allCases.enumerated()), id: \.element.id) { i, area in
                                Circle()
                                    .fill(i < currentAreaIndex ? Color.areaColor(area) : (i == currentAreaIndex ? Color.areaColor(area).opacity(0.6) : Color.inkFaint.opacity(0.4)))
                                    .frame(width: 8, height: 8)
                            }
                        }

                        HStack(spacing: 8) {
                            Image(systemName: currentArea.icon)
                                .font(.system(size: 18))
                                .foregroundColor(Color.areaColor(currentArea))
                            Text(currentArea.rawValue)
                                .font(.reflectionSerif(30))
                                .foregroundColor(.inkDark)
                        }

                        Text(currentArea.subtitle)
                            .font(.reflectionSans(14))
                            .foregroundColor(.inkLight)

                        Text("\(currentAreaIndex + 1) of \(totalAreas)")
                            .font(.reflectionSans(11))
                            .foregroundColor(.inkLight)
                            .textCase(.uppercase)
                            .tracking(1.0)
                    }
                    .padding(.top, 36)

                    if currentQuestions.isEmpty {
                        VStack(spacing: 10) {
                            Text("No questions for \(currentArea.rawValue).")
                                .font(.reflectionSans(14))
                                .foregroundColor(.inkLight)
                            Text("Add questions in the Questions tab, or skip ahead.")
                                .font(.reflectionSans(12))
                                .foregroundColor(.inkFaint)
                        }
                        .padding(24)
                        .cardStyle()
                    } else {
                        VStack(spacing: 24) {
                            ForEach(currentQuestions) { question in
                                QuestionAnswerCard(
                                    question: question,
                                    rating: Binding(
                                        get: { ratings[question.id] ?? 0 },
                                        set: { ratings[question.id] = $0 }
                                    ),
                                    longAnswer: Binding(
                                        get: { longAnswers[question.id] ?? "" },
                                        set: { longAnswers[question.id] = $0 }
                                    )
                                )
                            }
                        }
                    }

                    // Navigation
                    HStack(spacing: 16) {
                        if currentAreaIndex > 0 {
                            Button {
                                withAnimation { currentAreaIndex -= 1 }
                            } label: {
                                HStack {
                                    Image(systemName: "chevron.left")
                                    Text("Back")
                                }
                                .font(.reflectionSans(14))
                                .foregroundColor(.inkMedium)
                                .padding(.horizontal, 20)
                                .padding(.vertical, 10)
                                .background(Color.inkFaint.opacity(0.4))
                                .cornerRadius(7)
                            }
                            .buttonStyle(.plain)
                        }

                        Spacer()

                        if currentAreaIndex < totalAreas - 1 {
                            Button {
                                withAnimation { currentAreaIndex += 1 }
                            } label: {
                                HStack {
                                    Text("Next")
                                    Image(systemName: "chevron.right")
                                }
                                .font(.reflectionSans(14))
                                .foregroundColor(.parchment)
                                .padding(.horizontal, 24)
                                .padding(.vertical, 10)
                                .background(canProceed || currentQuestions.isEmpty ? Color.inkDark : Color.inkLight)
                                .cornerRadius(7)
                            }
                            .buttonStyle(.plain)
                        } else {
                            Button {
                                isComplete = true
                            } label: {
                                HStack {
                                    Image(systemName: "checkmark")
                                    Text("Finish")
                                }
                                .font(.reflectionSans(14))
                                .foregroundColor(.parchment)
                                .padding(.horizontal, 24)
                                .padding(.vertical, 10)
                                .background(Color.inkDark)
                                .cornerRadius(7)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.bottom, 40)
                }
                .padding(.horizontal, 40)
            }
            .parchmentBackground()
        }
    }

    func saveSession() {
        let session = ReflectionSession(sessionNotes: sessionNotes)
        modelContext.insert(session)
        for question in questions {
            if let rating = ratings[question.id] {
                let answer = ReflectionAnswer(
                    question: question,
                    session: session,
                    rating: rating,
                    longFormAnswer: longAnswers[question.id] ?? ""
                )
                modelContext.insert(answer)
                session.answers.append(answer)
            }
        }
        reset()
    }

    func reset() {
        currentAreaIndex = 0
        ratings = [:]
        longAnswers = [:]
        sessionNotes = ""
        isComplete = false
    }
}

struct QuestionAnswerCard: View {
    let question: ReflectionQuestion
    @Binding var rating: Int
    @Binding var longAnswer: String

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(question.text)
                .font(.reflectionSerif(16))
                .foregroundColor(.inkDark)
                .fixedSize(horizontal: false, vertical: true)

            // Star / 1-5 rating
            HStack(spacing: 0) {
                ForEach(1...5, id: \.self) { n in
                    Button {
                        rating = n
                    } label: {
                        VStack(spacing: 3) {
                            Image(systemName: n <= rating ? "circle.fill" : "circle")
                                .font(.system(size: 22))
                                .foregroundColor(n <= rating ? Color.areaColor(question.area) : Color.inkFaint)
                            Text("\(n)")
                                .font(.reflectionSans(10))
                                .foregroundColor(n <= rating ? .inkDark : .inkFaint)
                        }
                    }
                    .buttonStyle(.plain)
                    .frame(maxWidth: .infinity)
                }
            }

            if rating > 0 {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Notes (optional)")
                        .font(.reflectionSans(11))
                        .foregroundColor(.inkLight)
                        .textCase(.uppercase)
                        .tracking(0.8)

                    TextEditor(text: $longAnswer)
                        .font(.reflectionSans(13))
                        .foregroundColor(.inkDark)
                        .frame(minHeight: 80)
                        .padding(8)
                        .background(Color.inkFaint.opacity(0.25))
                        .cornerRadius(6)
                }
            }
        }
        .padding(20)
        .cardStyle()
    }
}

struct CompletionView: View {
    @Binding var sessionNotes: String
    let onSave: () -> Void
    let onDiscard: () -> Void

    var body: some View {
        ScrollView {
            VStack(spacing: 28) {
                Image(systemName: "checkmark.seal")
                    .font(.system(size: 52))
                    .foregroundColor(.studyAccent)
                    .padding(.top, 48)

                Text("Reflection Complete")
                    .font(.reflectionSerif(32))
                    .foregroundColor(.inkDark)

                Text("Take a moment to write any overall thoughts or intentions.")
                    .font(.reflectionSans(14))
                    .foregroundColor(.inkLight)
                    .multilineTextAlignment(.center)

                VStack(alignment: .leading, spacing: 8) {
                    Text("Overall Notes")
                        .font(.reflectionSans(11))
                        .foregroundColor(.inkLight)
                        .textCase(.uppercase)
                        .tracking(1.0)
                    TextEditor(text: $sessionNotes)
                        .font(.reflectionSans(14))
                        .foregroundColor(.inkDark)
                        .frame(minHeight: 120)
                        .padding(10)
                        .background(Color.inkFaint.opacity(0.3))
                        .cornerRadius(8)
                }
                .frame(maxWidth: 500)

                HStack(spacing: 16) {
                    Button("Discard", action: onDiscard)
                        .font(.reflectionSans(14))
                        .foregroundColor(.inkLight)
                        .buttonStyle(.plain)

                    Button {
                        onSave()
                    } label: {
                        HStack {
                            Image(systemName: "square.and.arrow.down")
                            Text("Save Reflection")
                        }
                        .font(.reflectionSans(14))
                        .foregroundColor(.parchment)
                        .padding(.horizontal, 28)
                        .padding(.vertical, 12)
                        .background(Color.inkDark)
                        .cornerRadius(8)
                    }
                    .buttonStyle(.plain)
                }
                .padding(.bottom, 48)
            }
            .padding(.horizontal, 40)
        }
        .parchmentBackground()
    }
}
