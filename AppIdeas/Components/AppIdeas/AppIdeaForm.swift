import Dependencies
import SharingGRDB
import SwiftUI
import SwiftUINavigation

@Observable
@MainActor
class AppIdeaFormModel {
    @ObservationIgnored
    @Dependency(\.defaultDatabase) var database

    @ObservationIgnored
    @FetchAll(Category.all, animation: .default) var allCategories

    var appIdea: AppIdea.Draft

    let isEdit: Bool
    let onUpsert: ((AppIdea) -> Void)?

    @CasePathable
    enum Route {
        case selectCategory
        case selectEmoji
    }

    var route: Route?

    init(
        appIdea: AppIdea.Draft = AppIdea.Draft(),
        onUpsert: ((AppIdea) -> Void)? = nil
    ) {
        self.appIdea = appIdea
        self.onUpsert = onUpsert
        isEdit = appIdea.id != nil
    }

    func onTapSelectCategory() {
        route = .selectCategory
    }

    func onSelectCategory(_ category: Category?) {
        appIdea.categoryID = category?.id
        Task {
            route = nil
        }
    }
    
    func onTapSelectEmoji() {
        route = .selectEmoji
    }

    func onTapSave() {
        withErrorReporting {
            let newAppIdea =
                try database.write { db in
                    try AppIdea
                        .upsert {
                            appIdea
                        }
                        .returning { $0 }
                        .fetchOne(db)
                }

            if let newAppIdea {
                onUpsert?(newAppIdea)
            }
        }
    }
}

struct AppIdeaFormView: View {
    @State var model: AppIdeaFormModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    headerSection
                    detailsSection
                    tipsSection
                }
                .padding(.horizontal, 20)
            }
            .navigationTitle(model.isEdit ? "Edit App Idea" : "New App Idea")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(.secondary)
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        Haptics.shared.vibrateIfEnabled()
                        model.onTapSave()
                        dismiss()
                    }
                    .fontWeight(.semibold)
                    .foregroundColor(model.appIdea.title.isEmpty || model.appIdea.detail.isEmpty ? .secondary : .blue)
                    .disabled(model.appIdea.title.isEmpty || model.appIdea.detail.isEmpty)
                }
            }
            .sheet(isPresented: Binding($model.route.selectCategory)) {
                CategorySelectionSheet(
                    selectedCategory: model.appIdea.categoryID,
                    onSelect: { category in
                        model.onSelectCategory(category)
                    }
                )
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.visible)
            }
            .sheet(isPresented: Binding($model.route.selectEmoji)) {
                EmojiPickerView(
                    selectedEmoji: $model.appIdea.icon,
                    title: "Choose App Icon",
                    categoryOrder: [.objects, .activities, .food, .animals, .smileys]
                )
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.visible)
            }
        }
    }

    private var headerSection: some View {
        VStack(spacing: 16) {
            Button(action: {
                Haptics.shared.vibrateIfEnabled()
                model.onTapSelectEmoji()
            }) {
                ZStack {
                    RoundedRectangle(cornerRadius: 20)
                        .fill(
                            LinearGradient(
                                colors: [.blue.opacity(0.1), .purple.opacity(0.1)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 80, height: 80)
                    
                    Text(model.appIdea.icon)
                        .font(.system(size: 40))
                }
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(
                            LinearGradient(
                                colors: [.blue.opacity(0.3), .purple.opacity(0.3)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                )
                .overlay(
                    VStack {
                        HStack {
                            Spacer()
                            Image(systemName: "pencil.circle.fill")
                                .font(.title2)
                                .foregroundColor(.blue)
                                .background(Color.white, in: Circle())
                        }
                        Spacer()
                    }
                    .padding(4)
                )
            }
            .buttonStyle(.plain)
            
            Text("Tap to change app icon")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(.top, 20)
    }

    private var detailsSection: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack {
                Image(systemName: "pencil.and.outline")
                    .font(.title3)
                    .foregroundColor(.blue)
                Text("App Idea Details")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
            }

            VStack(spacing: 16) {
                // App Title
                VStack(alignment: .leading, spacing: 8) {
                    Text("App Title")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.primary)

                    TextField("Enter your app name", text: $model.appIdea.title)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .font(.body)
                }

                // Short Description
                VStack(alignment: .leading, spacing: 8) {
                    Text("Short Description (optional)")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.primary)

                    TextField("Brief description of your app", text: $model.appIdea.shortDescription, axis: .vertical)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .font(.body)
                        .lineLimit(2 ... 4)
                }

                // Detailed Description
                VStack(alignment: .leading, spacing: 8) {
                    Text("Detailed Description")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.primary)

                    TextField("Describe your app idea in detail", text: $model.appIdea.detail, axis: .vertical)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .font(.body)
                        .lineLimit(5 ... 10)
                }

                // Category Selection
                VStack(alignment: .leading, spacing: 8) {
                    Text("Category")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.primary)

                    Button(action: {
                        Haptics.shared.vibrateIfEnabled()
                        model.onTapSelectCategory()
                    }) {
                        HStack {
                            if let selectedCategory = model.allCategories.first(where: { $0.id == model.appIdea.categoryID }) {
                                Text(selectedCategory.title)
                                    .foregroundColor(.primary)
                                    .font(.body)
                            } else {
                                HStack(spacing: 8) {
                                    Image(systemName: "folder")
                                        .font(.body)
                                        .foregroundColor(.secondary)
                                    Text("Select Category")
                                        .foregroundColor(.secondary)
                                        .font(.body)
                                }
                            }
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 10)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.ultraThinMaterial)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(
                    LinearGradient(
                        colors: [.blue.opacity(0.1), .purple.opacity(0.1)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1
                )
        )
    }

    private var tipsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "lightbulb")
                    .font(.title3)
                    .foregroundColor(.orange)
                Text("Tips for Great App Ideas")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
            }

            VStack(spacing: 12) {
                TipRow(icon: "target", text: "Be specific about the problem your app solves")
                TipRow(icon: "person", text: "Consider your target audience")
                TipRow(icon: "star", text: "Think about unique features that set it apart")
                TipRow(icon: "gear", text: "Consider technical feasibility and complexity")
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.ultraThinMaterial)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(
                    LinearGradient(
                        colors: [.orange.opacity(0.1), .yellow.opacity(0.1)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1
                )
        )
    }
}

struct TipRow: View {
    let icon: String
    let text: String

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.subheadline)
                .foregroundColor(.orange)
                .frame(width: 20)
            Text(text)
                .font(.subheadline)
                .foregroundColor(.primary)
            Spacer()
        }
    }
}

#Preview {
    AppIdeaFormView(
        model: AppIdeaFormModel()
    )
}
