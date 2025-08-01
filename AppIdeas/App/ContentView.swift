import SwiftUI

struct ContentView: View {
    @State private var selectedTab = 0
    var body: some View {
        TabView(selection: $selectedTab) {
            AppIdeaListView()
                .tabItem {
                    Label("App Ideas", systemImage: "lightbulb")
                }
                .tag(0)
                .onAppear {
                    AdManager.requestATTPermission(with: 3)
                }

            FavoritesView()
                .tabItem {
                    Label("Favorites", systemImage: "heart.fill")
                }
                .tag(1)

            MoreView()
                .tabItem {
                    Label("More", systemImage: "ellipsis.circle")
                }
                .tag(2)
                .onAppear {
                    AdManager.requestATTPermission(with: 1)
                }
        }
        .onChange(of: selectedTab) { _ in
            Haptics.shared.vibrateIfEnabled()
        }
    }
}

#Preview {
    ContentView()
}
