import SwiftUI

enum AppTab: String, CaseIterable {
    case home = "Home"
    case reflect = "Reflect"
    case questions = "Questions"
    case history = "History"

    var icon: String {
        switch self {
        case .home:      return "house"
        case .reflect:   return "pencil"
        case .questions: return "list.bullet"
        case .history:   return "clock"
        }
    }
}

struct ContentView: View {
    @State private var selectedTab: AppTab = .home

    var body: some View {
        NavigationSplitView(columnVisibility: .constant(.detailOnly)) {
            EmptyView()
        } detail: {
            VStack(spacing: 0) {
                // Custom tab bar
                HStack(spacing: 0) {
                    ForEach(AppTab.allCases, id: \.self) { tab in
                        TabButton(tab: tab, isSelected: selectedTab == tab) {
                            selectedTab = tab
                        }
                    }
                }
                .background(Color.inkDark)

                Divider()
                    .background(Color.inkDark.opacity(0.6))

                // Main content
                Group {
                    switch selectedTab {
                    case .home:
                        HomeView(selectedTab: $selectedTab)
                    case .reflect:
                        ReflectionSessionView()
                    case .questions:
                        QuestionsView()
                    case .history:
                        HistoryView()
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .navigationSplitViewStyle(.balanced)
    }
}

struct TabButton: View {
    let tab: AppTab
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: tab.icon)
                    .font(.system(size: 15))
                Text(tab.rawValue)
                    .font(.reflectionSans(10))
            }
            .foregroundColor(isSelected ? Color.parchment : Color.parchment.opacity(0.45))
            .frame(maxWidth: .infinity)
            .padding(.vertical, 10)
            .background(isSelected ? Color.white.opacity(0.12) : Color.clear)
        }
        .buttonStyle(.plain)
    }
}
