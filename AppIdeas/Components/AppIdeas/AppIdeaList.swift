import Dependencies
import SharingGRDB
import SwiftUI
import SwiftUINavigation

@Observable
@MainActor
class AppIdeaListModel {
    var searchText = ""
    enum SortOption: String, CaseIterable, Identifiable {
        case `default` = "Default"
        case updatedAt = "Updated Date"
        case title = "Title"
        case characterLengthAsc = "Character Length ↑"
        case characterLengthDesc = "Character Length ↓"
        var id: String { rawValue }
    }

    @ObservationIgnored
    @Shared(.appStorage("selectedCategory")) var selectedCategory: Category.ID?

    var sortOption: SortOption = .default
    var isDefault: Bool {
        sortOption == .default
    }

    @ObservationIgnored
    @FetchAll(
        AppIdea.all
        , animation: .default) var appIdeas

    @ObservationIgnored
    @Dependency(\.defaultDatabase) var database

    @CasePathable
    enum Route {
        case showingAddAppIdea
        case editingAppIdea(AppIdea)
        case showingDeleteAlert(AppIdea)
        case selectCategory
    }

    var route: Route?

    var filteredAppIdeas: [AppIdea] {
        var appIdeas = appIdeas
        if let selectedCategory {
            appIdeas = appIdeas.filter { $0.categoryID == selectedCategory }
        }

        // Search
        if !searchText.isEmpty {
            appIdeas = searchAppIdeas(query: searchText)
        }
        // Sort
        switch sortOption {
        case .updatedAt:
            appIdeas = appIdeas.sorted { $0.updatedAt > $1.updatedAt }
        case .title:
            appIdeas = appIdeas.sorted { $0.title.localizedCaseInsensitiveCompare($1.title) == .orderedAscending }
        case .characterLengthAsc:
            appIdeas = appIdeas.sorted { $0.detail.count < $1.detail.count }
        case .characterLengthDesc:
            appIdeas = appIdeas.sorted { $0.detail.count > $1.detail.count }
        default:
            break
        }
        return appIdeas
    }

    func searchAppIdeas(query: String) -> [AppIdea] {
        guard !query.isEmpty else { return appIdeas }

        let lowercasedQuery = query.lowercased()
        return appIdeas.filter { appIdea in
            appIdea.title.lowercased().contains(lowercasedQuery) ||
                appIdea.shortDescription.lowercased().contains(lowercasedQuery) ||
                appIdea.detail.lowercased().contains(lowercasedQuery)
        }
    }

    func onTapSelectCategory() {
        route = .selectCategory
    }

    func onSelectCategory(_ category: Category?) {
        withAnimation {
            $selectedCategory.withLock {
                $0 = category?.id
            }
        }
        Task {
            route = nil
        }
    }

    func onFavorite(_ appIdea: AppIdea) {
        withErrorReporting {
            var updatedAppIdea = appIdea
            updatedAppIdea.isFavorite.toggle()
            try database.write { db in
                try AppIdea
                    .update(updatedAppIdea)
                    .execute(db)
            }
        }
    }

    func onEdit(_ appIdea: AppIdea) {
        route = .editingAppIdea(appIdea)
    }

    func onDeleteRequest(_ appIdea: AppIdea) {
        route = .showingDeleteAlert(appIdea)
    }

    func confirmDelete(_ appIdea: AppIdea) {
        withErrorReporting {
            try database.write { db in
                try AppIdea.delete(appIdea).execute(db)
            }
        }
    }
}

struct AppIdeaListView: View {
    @State private var model = AppIdeaListModel()

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // List content
                if model.filteredAppIdeas.isEmpty {
                    VStack(spacing: 20) {
                        Spacer()

                        VStack(spacing: 16) {
                            Image(systemName: "lightbulb")
                                .font(.system(size: 60))
                                .foregroundColor(.blue.opacity(0.6))

                            VStack(spacing: 8) {
                                Text("No App Ideas Yet")
                                    .font(.title2)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.primary)

                                Text("Start creating your first app idea to get started")
                                    .font(.body)
                                    .foregroundColor(.secondary)
                                    .multilineTextAlignment(.center)
                            }
                        }

                        Button(action: {
                            Haptics.shared.vibrateIfEnabled()
                            model.route = .showingAddAppIdea
                        }) {
                            HStack(spacing: 8) {
                                Image(systemName: "plus.circle.fill")
                                    .font(.title3)
                                Text("Create Your First App Idea")
                                    .font(.headline)
                                    .fontWeight(.semibold)
                            }
                            .foregroundColor(.white)
                            .padding(.horizontal, 24)
                            .padding(.vertical, 12)
                            .background(
                                LinearGradient(
                                    colors: [.blue, .purple],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .clipShape(Capsule())
                        }
                        .buttonStyle(.plain)

                        Spacer()
                    }
                    .padding()
                } else {
                    List(model.filteredAppIdeas) { appIdea in
                        NavigationLink(
                            destination: AppIdeaDetailView(
                                model: AppIdeaDetailModel(appIdea: appIdea)
                            )
                        ) {
                            AppIdeaRowView(
                                appIdea: appIdea,
                                onFavorite: { model.onFavorite(appIdea) }
                            )
                            .contextMenu {
                                Button(action: {
                                    Haptics.shared.vibrateIfEnabled()
                                    model.onEdit(appIdea)
                                }) {
                                    Label("Edit", systemImage: "pencil")
                                }
                                Button(action: {
                                    Haptics.shared.vibrateIfEnabled()
                                    model.onFavorite(appIdea)
                                }) {
                                    Label(appIdea.isFavorite ? "Unfavorite" : "Favorite", systemImage: appIdea.isFavorite ? "heart.slash" : "heart")
                                }
                                Button(role: .destructive, action: {
                                    Haptics.shared.vibrateIfEnabled()
                                    model.onDeleteRequest(appIdea)
                                }) {
                                    Label("Delete", systemImage: "trash")
                                }
                            }
                        }
                        .listRowSeparator(.hidden)
                        .listRowInsets(EdgeInsets(top: 8, leading: 20, bottom: 8, trailing: 20))
                        .listRowBackground(Color.clear)
                    }
                    .listStyle(PlainListStyle())
                }
            }
            .scrollDismissesKeyboard(.immediately)
            .searchable(text: $model.searchText, prompt: "Search app ideas...")
            .navigationTitle("App Ideas")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    HStack(spacing: 12) {
                        // Sort Menu
                        Menu {
                            Section(header: Text("Sort By")) {
                                Picker("Sort", selection: $model.sortOption) {
                                    ForEach(AppIdeaListModel.SortOption.allCases) { option in
                                        Text(option.rawValue).tag(option)
                                    }
                                }
                            }
                        } label: {
                            HStack(spacing: 4) {
                                Image(systemName: model.isDefault ? "arrow.up.arrow.down" : "arrow.up.arrow.down.circle.fill")
                                    .font(.system(size: 16, weight: .medium))
                                Text("Sort")
                                    .font(.caption)
                                    .fontWeight(.medium)
                            }
                            .foregroundColor(model.isDefault ? .secondary : .blue)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(
                                Capsule()
                                    .fill(model.isDefault ? .gray.opacity(0.1) : .blue.opacity(0.1))
                            )
                        }

                        // Category Filter Button
                        Button(action: {
                            Haptics.shared.vibrateIfEnabled()
                            model.onTapSelectCategory()
                        }) {
                            HStack(spacing: 4) {
                                Image(systemName: model.selectedCategory != nil ? "line.3.horizontal.decrease.circle.fill" : "line.3.horizontal.decrease.circle")
                                    .font(.system(size: 16, weight: .medium))
                                Text("Category")
                                    .font(.caption)
                                    .fontWeight(.medium)
                            }
                            .foregroundColor(model.selectedCategory != nil ? .blue : .secondary)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(
                                Capsule()
                                    .fill(model.selectedCategory != nil ? .blue.opacity(0.1) : .gray.opacity(0.1))
                            )
                        }
                    }
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        Haptics.shared.vibrateIfEnabled()
                        model.route = .showingAddAppIdea
                    }) {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                            .foregroundColor(.blue)
                    }
                }
            }
            .sheet(isPresented: Binding($model.route.showingAddAppIdea)) {
                AppIdeaFormView(
                    model: AppIdeaFormModel { _ in
                        model.route = nil
                    }
                )
            }
            .sheet(isPresented: Binding($model.route.selectCategory)) {
                CategorySelectionSheet(
                    selectedCategory: model.selectedCategory,
                    onSelect: { category in
                        model.onSelectCategory(category)
                    }
                )
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.visible)
            }
            .sheet(item: $model.route.editingAppIdea, id: \.self) { appIdea in
                AppIdeaFormView(
                    model: AppIdeaFormModel(
                        appIdea: AppIdea.Draft(appIdea)
                    ) { _ in
                        model.route = nil
                    }
                )
            }
            .alert(
                item: $model.route.showingDeleteAlert,
                title: { _ in
                    Text("Delete App Idea")
                },
                actions: { appIdea in
                    Button("Delete", role: .destructive) {
                        Haptics.shared.vibrateIfEnabled()
                        model.confirmDelete(appIdea)
                    }
                    Button("Cancel", role: .cancel) {
                        Haptics.shared.vibrateIfEnabled()
                    }
                },
                message: { appIdea in
                    Text("Are you sure you want to delete \(appIdea.title)? This action cannot be undone.")
                }
            )
        }
    }
}

#Preview {
    AppIdeaListView()
        .environmentObject(DataManager())
}
