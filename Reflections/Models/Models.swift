import Foundation
import SwiftData

enum LifeArea: String, CaseIterable, Codable, Identifiable {
    case spirit = "Spirit"
    case mind = "Mind"
    case body = "Body"
    case friends = "Friends"
    case family = "Family"
    case work = "Work"
    case mission = "Mission"
    case money = "Money"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .spirit:  return "sparkles"
        case .mind:    return "brain"
        case .body:    return "figure.walk"
        case .friends: return "person.2"
        case .family:  return "house"
        case .work:    return "briefcase"
        case .mission: return "scope"
        case .money:   return "leaf"
        }
    }

    var subtitle: String {
        switch self {
        case .spirit:  return "Inner life, faith & meaning"
        case .mind:    return "Learning, curiosity & clarity"
        case .body:    return "Health, movement & rest"
        case .friends: return "Friendship & community"
        case .family:  return "Closest relationships & home"
        case .work:    return "Craft, career & contribution"
        case .mission: return "Purpose & long-term goals"
        case .money:   return "Financial health & stewardship"
        }
    }

    var color: (r: Double, g: Double, b: Double) {
        switch self {
        case .spirit:  return (0.53, 0.42, 0.73)
        case .mind:    return (0.30, 0.52, 0.75)
        case .body:    return (0.38, 0.68, 0.50)
        case .friends: return (0.75, 0.62, 0.30)
        case .family:  return (0.72, 0.40, 0.40)
        case .work:    return (0.40, 0.62, 0.68)
        case .mission: return (0.72, 0.52, 0.30)
        case .money:   return (0.48, 0.63, 0.40)
        }
    }
}

@Model
final class ReflectionQuestion {
    var id: UUID
    var areaRaw: String
    var text: String
    var createdAt: Date
    var sortOrder: Int

    @Relationship(deleteRule: .nullify, inverse: \ReflectionAnswer.question)
    var answers: [ReflectionAnswer] = []

    init(area: LifeArea, text: String, sortOrder: Int = 0) {
        self.id = UUID()
        self.areaRaw = area.rawValue
        self.text = text
        self.createdAt = Date()
        self.sortOrder = sortOrder
    }

    var area: LifeArea {
        get { LifeArea(rawValue: areaRaw) ?? .spirit }
        set { areaRaw = newValue.rawValue }
    }
}

@Model
final class ReflectionSession {
    var id: UUID
    var date: Date
    var sessionNotes: String

    @Relationship(deleteRule: .cascade, inverse: \ReflectionAnswer.session)
    var answers: [ReflectionAnswer] = []

    init(date: Date = Date(), sessionNotes: String = "") {
        self.id = UUID()
        self.date = date
        self.sessionNotes = sessionNotes
    }

    func averageRating(for area: LifeArea) -> Double {
        let relevant = answers.filter { $0.question?.areaRaw == area.rawValue }
        guard !relevant.isEmpty else { return 0 }
        return Double(relevant.reduce(0) { $0 + $1.rating }) / Double(relevant.count)
    }

    var areaAverages: [(area: LifeArea, value: Double)] {
        LifeArea.allCases.map { area in
            (area: area, value: averageRating(for: area))
        }
    }
}

@Model
final class ReflectionAnswer {
    var id: UUID
    var rating: Int
    var longFormAnswer: String
    var question: ReflectionQuestion?
    var session: ReflectionSession?

    init(question: ReflectionQuestion, session: ReflectionSession, rating: Int = 3, longFormAnswer: String = "") {
        self.id = UUID()
        self.rating = rating
        self.longFormAnswer = longFormAnswer
        self.question = question
        self.session = session
    }
}
