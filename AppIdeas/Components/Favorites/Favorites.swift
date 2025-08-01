import SharingGRDB
import SwiftUI
import SwiftUINavigation

@Observable
@MainActor
class FavoritesViewModel {
    var selectedTab = 0

    @ObservationIgnored
    @FetchAll(
        AppIdea.all
            .where(\.isFavorite)
        , animation: .default) var favoriteAppIdeas

    @ObservationIgnored
    @Dependency(\.defaultDatabase) var database

    @ObservationIgnored
    @Dependency(\.purchaseManager) var purchaseManager

    @CasePathable
    enum Route {
        case editingAppIdea(AppIdea)
        case showingDeleteAppIdeaAlert(AppIdea)
    }

    var route: Route?

    // App Idea actions
    func onEdit(_ appIdea: AppIdea) {
        route = .editingAppIdea(appIdea)
    }

    func onDeleteRequest(_ appIdea: AppIdea) {
        route = .showingDeleteAppIdeaAlert(appIdea)
    }

    func confirmDelete(_ appIdea: AppIdea) {
        withErrorReporting {
            try database.write { db in
                try AppIdea.delete(appIdea).execute(db)
            }
        }
    }

    func onUpdate(_ newAppIdea: AppIdea) {
        withErrorReporting {
            try database.write { db in
                try AppIdea.update(newAppIdea).execute(db)
            }
        }
    }

    func onFavorite(_ appIdea: AppIdea) {
        withErrorReporting {
            var updatedAppIdea = appIdea
            updatedAppIdea.isFavorite.toggle()
            try database.write { db in
                try AppIdea.update(updatedAppIdea).execute(db)
            }
        }
    }
}

struct FavoritesView: View {
    @State private var model = FavoritesViewModel()

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                if model.favoriteAppIdeas.isEmpty {
                    EmptyFavoritesView(
                        title: "No Favorite App Ideas",
                        message: "App ideas you favorite will appear here",
                        systemImage: "heart"
                    )
                } else {
                    List(model.favoriteAppIdeas) { appIdea in
                        NavigationLink(
                            destination: AppIdeaDetailView(
                                model: AppIdeaDetailModel(appIdea: appIdea)
                            )
                        ) {
                            AppIdeaRowView(appIdea: appIdea) {
                                model.onFavorite(appIdea)
                            }
                            .contextMenu {
                                Button(action: { model.onEdit(appIdea) }) {
                                    Label("Edit", systemImage: "pencil")
                                }
                                Button(action: { model.onFavorite(appIdea) }) {
                                    Label(appIdea.isFavorite ? "Unfavorite" : "Favorite", systemImage: appIdea.isFavorite ? "heart.slash" : "heart")
                                }
                                Button(role: .destructive, action: { model.onDeleteRequest(appIdea) }) {
                                    Label("Delete", systemImage: "trash")
                                }
                            }
                        }
                    }
                    .listStyle(PlainListStyle())
                }
                if !model.purchaseManager.isPremiumUserPurchased {
                    BannerView()
                        .frame(height: 50)
                        .padding(.bottom, 16)
                }
            }
            .navigationTitle("Favorites")
            .navigationBarTitleDisplayMode(.inline)
            // App Idea sheets/alerts
            .sheet(item: $model.route.editingAppIdea, id: \.self) { appIdea in
                AppIdeaFormView(
                    model: AppIdeaFormModel(appIdea: AppIdea.Draft(appIdea)) { _ in
                        model.route = nil
                    }
                )
            }
            .alert(
                item: $model.route.showingDeleteAppIdeaAlert,
                title: { _ in Text("Delete App Idea") },
                actions: { appIdea in
                    Button("Delete", role: .destructive) {
                        model.confirmDelete(appIdea)
                    }
                    Button("Cancel", role: .cancel) {}
                },
                message: { appIdea in
                    Text("Are you sure you want to delete \(appIdea.title)? This action cannot be undone.")
                }
            )
        }
    }
}

struct EmptyFavoritesView: View {
    let title: String
    let message: String
    let systemImage: String

    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: systemImage)
                .font(.system(size: 60))
                .foregroundColor(.gray)

            Text(title)
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(.primary)

            Text(message)
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.gray.opacity(0.05))
    }
}
