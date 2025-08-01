import Dependencies
import MarkdownUI
import SharingGRDB
import SwiftUI
import SwiftUINavigation

@Observable
@MainActor
class AppIdeaDetailModel {
    @ObservationIgnored
    @Dependency(\.defaultDatabase) var database

    var appIdea: AppIdea

    @CasePathable
    enum Route {
        case editingAppIdea
        case showingDeleteAlert(AppIdea)
    }

    var route: Route?

    var copiedToClipboard = false

    init(appIdea: AppIdea) {
        self.appIdea = appIdea
    }

    var category: Category? {
        try? database.read { db in
            try? Category
                .all
                .where { $0.id.is(appIdea.categoryID) }
                .fetchOne(db)
        }
    }

    func onCopy() {
        UIPasteboard.general.string = appIdea.detail
        copiedToClipboard = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.copiedToClipboard = false
        }
    }

    func onFavorite() {
        withErrorReporting {
            var updatedAppIdea = appIdea
            updatedAppIdea.isFavorite.toggle()
            try database.write { db in
                try AppIdea.update(updatedAppIdea).execute(db)
            }
            appIdea = updatedAppIdea
        }
    }

    func onEdit() {
        route = .editingAppIdea
    }

    func onDeleteRequest() {
        route = .showingDeleteAlert(appIdea)
    }

    func confirmDelete(action: () -> Void) {
        withErrorReporting {
            try database.write { db in
                try AppIdea.delete(appIdea).execute(db)
            }
        }
        action()
    }

    func onUpdate(_ newAppIdea: AppIdea) {
        withAnimation {
            route = nil
            appIdea = newAppIdea
        }
    }
}

struct AppIdeaDetailView: View {
    @State var model: AppIdeaDetailModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Hero Header Card
                VStack(alignment: .leading, spacing: 16) {
                    HStack(alignment: .top, spacing: 16) {
                        // App icon with emoji
                        ZStack {
                            RoundedRectangle(cornerRadius: 16)
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
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(
                                    LinearGradient(
                                        colors: [.blue.opacity(0.3), .purple.opacity(0.3)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ),
                                    lineWidth: 1
                                )
                        )

                        VStack(alignment: .leading, spacing: 8) {
                            Text(model.appIdea.title)
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.primary)
                                .lineLimit(2)

                            if !model.appIdea.shortDescription.isEmpty {
                                Text(model.appIdea.shortDescription)
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                    .lineLimit(3)
                            }

                            // Badges
                            if let category = model.category {
                                Text(category.title)
                                    .font(.caption)
                                    .fontWeight(.medium)
                                    .foregroundColor(.blue)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(
                                        Capsule()
                                            .fill(.gray.opacity(0.1))
                                    )
                            }
                        }

                        Spacer()

                        Button(action: {
                            Haptics.shared.vibrateIfEnabled()
                            model.onFavorite()
                        }) {
                            Image(systemName: model.appIdea.isFavorite ? "heart.fill" : "heart")
                                .foregroundColor(model.appIdea.isFavorite ? .red : .gray)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(20)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(.ultraThinMaterial)
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(
                                    LinearGradient(
                                        colors: [.blue.opacity(0.2), .purple.opacity(0.2)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ),
                                    lineWidth: 1
                                )
                        )
                )
                
                // Quick Launch LLMs
                VStack(alignment: .leading, spacing: 10) {
                    Text("Ask AI to build")
                        .font(AppFont.headline)
                        .foregroundColor(.secondary)
                        .padding(.bottom, 2)
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: AppSpacing.small) {
                            LLMQuickLaunchButton(
                                icon: "message.fill",
                                label: "ChatGPT",
                                background: .chatGPT,
                                foreground: .white,
                                url: URL(string: "https://chatgpt.com/?prompt=\(model.appIdea.detail.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")")!
                            )
                            LLMQuickLaunchButton(
                                icon: "bolt.fill",
                                label: "Grok",
                                background: .grok,
                                foreground: .white,
                                url: URL(string: "https://grok.x.ai/?q=\(model.appIdea.detail.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")")!
                            )
                            LLMQuickLaunchButton(
                                icon: "sun.max.fill",
                                label: "Claude",
                                background: .claude,
                                foreground: .black,
                                url: URL(string: "https://claude.ai/chat?prompt=\(model.appIdea.detail.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")")!
                            )
                            LLMQuickLaunchButton(
                                icon: "questionmark.circle.fill",
                                label: "Perplexity",
                                background: .perplexity,
                                foreground: .white,
                                url: URL(string: "https://www.perplexity.ai/?q=\(model.appIdea.detail.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")")!
                            )
                            LLMQuickLaunchButton(
                                icon: "sparkles",
                                label: "Gemini",
                                background: .gemini,
                                foreground: .white,
                                url: URL(string: "https://gemini.google.com/app?prompt=\(model.appIdea.detail.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")")!
                            )
                        }
                        .padding(.vertical, 2)
                    }
                }

                // Description Card
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Image(systemName: "doc.text")
                            .font(.title3)
                            .foregroundColor(.purple)
                        Text("Description")
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(.primary)
                        Spacer()
                        Button(action: {
                            Haptics.shared.vibrateIfEnabled()
                            model.onCopy()
                        }) {
                            ZStack {
                                Image(systemName: "doc.on.doc")
                                    .opacity(model.copiedToClipboard ? 0 : 1)
                                Image(systemName: "checkmark")
                                    .opacity(model.copiedToClipboard ? 1 : 0)
                            }
                            .foregroundColor(model.copiedToClipboard ? .green : .gray)
                        }
                        .buttonStyle(.plain)
                    }
                    Markdown(model.appIdea.detail)
                        .markdownTheme(.gitHub)
                }
                .padding(20)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(
                            LinearGradient(
                                colors: [.blue.opacity(0.2), .purple.opacity(0.2)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                )

                // Metadata Card
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Image(systemName: "info.circle")
                            .font(.title3)
                            .foregroundColor(.orange)
                        Text("Details")
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(.primary)
                        Spacer()
                    }

                    VStack(spacing: 16) {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Last Updated")
                                    .font(.caption)
                                    .fontWeight(.medium)
                                    .foregroundColor(.secondary)
                                Text(model.appIdea.updatedAt, style: .date)
                                    .font(.body)
                                    .fontWeight(.medium)
                                    .foregroundColor(.primary)
                            }
                            Spacer()
                            VStack(alignment: .trailing, spacing: 4) {
                                Text("Characters")
                                    .font(.caption)
                                    .fontWeight(.medium)
                                    .foregroundColor(.secondary)
                                Text("\(model.appIdea.detail.count)")
                                    .font(.body)
                                    .fontWeight(.medium)
                                    .foregroundColor(.primary)
                            }
                        }
                    }
                }
                .padding(20)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(.ultraThinMaterial)
                )
            }
            .padding(20)
        }
        .navigationTitle("App Idea")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Menu {
                    Button(action: {
                        Haptics.shared.vibrateIfEnabled()
                        model.onEdit()
                    }) {
                        Label("Edit", systemImage: "pencil")
                    }
                    Button(action: {
                        Haptics.shared.vibrateIfEnabled()
                        model.onCopy()
                    }) {
                        Label("Copy Description", systemImage: "doc.on.doc")
                    }
                    Button(action: {
                        Haptics.shared.vibrateIfEnabled()
                        model.onFavorite()
                    }) {
                        Label(model.appIdea.isFavorite ? "Unfavorite" : "Favorite", systemImage: model.appIdea.isFavorite ? "heart.slash" : "heart")
                    }
                    Divider()
                    Button(role: .destructive, action: {
                        Haptics.shared.vibrateIfEnabled()
                        model.onDeleteRequest()
                    }) {
                        Label("Delete", systemImage: "trash")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                        .font(.title3)
                        .foregroundColor(.secondary)
                }
            }
        }
        .sheet(isPresented: Binding($model.route.editingAppIdea)) {
            AppIdeaFormView(
                model: AppIdeaFormModel(
                    appIdea: AppIdea.Draft(model.appIdea)
                ) { newAppIdea in
                    model.onUpdate(newAppIdea)
                }
            )
        }
        .alert(
            item: $model.route.showingDeleteAlert,
            title: { _ in
                Text("Delete App Idea")
            },
            actions: { _ in
                Button("Delete", role: .destructive) {
                    Haptics.shared.vibrateIfEnabled()
                    model.confirmDelete {
                        dismiss()
                    }
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

#Preview {
    NavigationStack {
        AppIdeaDetailView(
            model: AppIdeaDetailModel(
                appIdea: AppIdea(
                    id: 1,
                    title: "Fitness Tracker Pro",
                    shortDescription: "A comprehensive fitness tracking app with AI-powered workout recommendations",
                    detail: """
                    # Fitness Tracker Pro

                    This app will revolutionize how people track their fitness journey.

                    ## Key Features
                    - **AI-powered workout recommendations** based on user goals and progress
                    - **Real-time progress tracking** with detailed analytics
                    - **Social features** for motivation and community building
                    - **Integration with wearable devices** for seamless data collection

                    ## Target Audience
                    - Fitness enthusiasts
                    - Beginners looking to start their fitness journey
                    - People who want data-driven workout plans

                    ## Technical Stack
                    - iOS native development with SwiftUI
                    - Machine learning for workout recommendations
                    - Cloud sync for cross-device access
                    """,
                    isFavorite: true,
                    updatedAt: Date(),
                    categoryID: 1
                )
            )
        )
    }
}
