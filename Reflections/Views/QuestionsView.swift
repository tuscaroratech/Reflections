import SwiftUI
import SwiftData

struct QuestionsView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \ReflectionQuestion.sortOrder) private var questions: [ReflectionQuestion]
    @State private var selectedArea: LifeArea = .spirit
    @State private var showingAddSheet = false
    @State private var editingQuestion: ReflectionQuestion? = nil

    var filteredQuestions: [ReflectionQuestion] {
        questions.filter { $0.areaRaw == selectedArea.rawValue }
    }

    var body: some View {
        HSplitView {
            // Left: Area list
            VStack(alignment: .leading, spacing: 0) {
                Text("Areas")
                    .font(.reflectionSans(11))
                    .foregroundColor(.inkLight)
                    .textCase(.uppercase)
                    .tracking(1.2)
                    .padding(.horizontal, 16)
                    .padding(.top, 24)
                    .padding(.bottom, 8)

                ForEach(LifeArea.allCases) { area in
                    AreaRowButton(area: area, isSelected: selectedArea == area, count: questions.filter { $0.areaRaw == area.rawValue }.count) {
                        selectedArea = area
                    }
                }
                Spacer()
            }
            .frame(minWidth: 160, maxWidth: 180)
            .parchmentBackground()

            // Right: Questions for selected area
            VStack(alignment: .leading, spacing: 0) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(selectedArea.rawValue)
                            .font(.reflectionSerif(26))
                            .foregroundColor(.inkDark)
                        Text(selectedArea.subtitle)
                            .font(.reflectionSans(13))
                            .foregroundColor(.inkLight)
                    }
                    Spacer()
                    Button {
                        showingAddSheet = true
                    } label: {
                        Label("Add Question", systemImage: "plus")
                            .font(.reflectionSans(13))
                            .foregroundColor(.studyAccent)
                    }
                    .buttonStyle(.plain)
                }
                .padding(.horizontal, 24)
                .padding(.top, 28)
                .padding(.bottom, 16)

                Divider().opacity(0.4)

                if filteredQuestions.isEmpty {
                    VStack(spacing: 12) {
                        Image(systemName: "questionmark.circle")
                            .font(.system(size: 32))
                            .foregroundColor(.inkFaint)
                        Text("No questions yet for \(selectedArea.rawValue).")
                            .font(.reflectionSerif(16))
                            .foregroundColor(.inkMedium)
                        Text("Add questions to reflect on this area of life.")
                            .font(.reflectionSans(13))
                            .foregroundColor(.inkLight)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    List {
                        ForEach(filteredQuestions) { q in
                            QuestionRow(question: q) {
                                editingQuestion = q
                            }
                        }
                        .onDelete { offsets in
                            for i in offsets {
                                modelContext.delete(filteredQuestions[i])
                            }
                        }
                    }
                    .listStyle(.plain)
                }
            }
            .parchmentBackground()
        }
        .sheet(isPresented: $showingAddSheet) {
            AddQuestionSheet(area: selectedArea)
        }
        .sheet(item: $editingQuestion) { q in
            EditQuestionSheet(question: q)
        }
    }
}

struct AreaRowButton: View {
    let area: LifeArea
    let isSelected: Bool
    let count: Int
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 10) {
                Image(systemName: area.icon)
                    .font(.system(size: 13))
                    .foregroundColor(isSelected ? Color.areaColor(area) : .inkLight)
                    .frame(width: 20)
                Text(area.rawValue)
                    .font(.reflectionSans(13))
                    .foregroundColor(isSelected ? .inkDark : .inkMedium)
                Spacer()
                if count > 0 {
                    Text("\(count)")
                        .font(.reflectionSans(11))
                        .foregroundColor(.inkLight)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 9)
            .background(isSelected ? Color.inkFaint.opacity(0.45) : Color.clear)
        }
        .buttonStyle(.plain)
    }
}

struct QuestionRow: View {
    let question: ReflectionQuestion
    let onEdit: () -> Void

    var body: some View {
        HStack(alignment: .top) {
            Image(systemName: "circle.fill")
                .font(.system(size: 5))
                .foregroundColor(.inkLight)
                .padding(.top, 6)
            Text(question.text)
                .font(.reflectionSans(14))
                .foregroundColor(.inkDark)
                .fixedSize(horizontal: false, vertical: true)
            Spacer()
            Button("Edit") {
                onEdit()
            }
            .font(.reflectionSans(12))
            .foregroundColor(.studyAccent)
            .buttonStyle(.plain)
        }
        .padding(.vertical, 6)
        .listRowBackground(Color.clear)
    }
}

struct AddQuestionSheet: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Query(sort: \ReflectionQuestion.sortOrder) private var questions: [ReflectionQuestion]
    let area: LifeArea
    @State private var text = ""

    var body: some View {
        QuestionFormSheet(title: "New Question — \(area.rawValue)", text: $text) {
            let count = questions.filter { $0.areaRaw == area.rawValue }.count
            let q = ReflectionQuestion(area: area, text: text, sortOrder: count)
            modelContext.insert(q)
            dismiss()
        } onCancel: {
            dismiss()
        }
    }
}

struct EditQuestionSheet: View {
    @Environment(\.dismiss) private var dismiss
    let question: ReflectionQuestion
    @State private var text: String

    init(question: ReflectionQuestion) {
        self.question = question
        _text = State(initialValue: question.text)
    }

    var body: some View {
        QuestionFormSheet(title: "Edit Question", text: $text) {
            question.text = text
            dismiss()
        } onCancel: {
            dismiss()
        }
    }
}

struct QuestionFormSheet: View {
    let title: String
    @Binding var text: String
    let onSave: () -> Void
    let onCancel: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text(title)
                .font(.reflectionSerif(20))
                .foregroundColor(.inkDark)

            TextEditor(text: $text)
                .font(.reflectionSans(14))
                .foregroundColor(.inkDark)
                .frame(minHeight: 100)
                .padding(8)
                .background(Color.inkFaint.opacity(0.3))
                .cornerRadius(6)

            HStack {
                Spacer()
                Button("Cancel", action: onCancel)
                    .foregroundColor(.inkMedium)
                Button("Save") { onSave() }
                    .disabled(text.trimmingCharacters(in: .whitespaces).isEmpty)
                    .foregroundColor(.studyAccent)
            }
        }
        .padding(28)
        .frame(width: 440)
        .parchmentBackground()
    }
}
