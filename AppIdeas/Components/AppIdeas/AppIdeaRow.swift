import SharingGRDB
import SwiftUI

struct AppIdeaRowView: View {
    let appIdea: AppIdea
    let onFavorite: () -> Void

    @State private var copied = false

    @Dependency(\.defaultDatabase) private var database

    var category: Category? {
        try? database.read { db in
            try? Category
                .all
                .where { $0.id.is(appIdea.categoryID) }
                .fetchOne(db)
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            // Header with title and action buttons
            HStack(alignment: .top, spacing: 10) {
                // App icon with emoji
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(
                            LinearGradient(
                                colors: [.blue.opacity(0.1), .purple.opacity(0.1)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 50, height: 50)
                    
                    Text(appIdea.icon)
                        .font(.system(size: 24))
                }
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(
                            LinearGradient(
                                colors: [.blue.opacity(0.3), .purple.opacity(0.3)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                )

                // Content
                VStack(alignment: .leading, spacing: 6) {
                    Text(appIdea.title)
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                        .lineLimit(1)
                        .minimumScaleFactor(0.6)
                        .multilineTextAlignment(.leading)

                    if !appIdea.shortDescription.isEmpty {
                        Text(appIdea.shortDescription)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .lineLimit(2)
                            .multilineTextAlignment(.leading)
                            .minimumScaleFactor(0.6)
                    }
                }

                Spacer()

                // Action buttons
                VStack(spacing: 5) {
                    Button(action: {
                        Haptics.shared.vibrateIfEnabled()
                        onFavorite()
                    }) {
                        Image(systemName: appIdea.isFavorite ? "heart.fill" : "heart")
                            .font(.system(size: 15, weight: .medium))
                            .foregroundColor(appIdea.isFavorite ? .red : .gray)
                            .frame(width: 28, height: 28)
                            .background(
                                Circle()
                                    .fill(appIdea.isFavorite ? .red.opacity(0.1) : .gray.opacity(0.1))
                            )
                    }
                    .buttonStyle(.plain)

                    Button(action: {
                        Haptics.shared.vibrateIfEnabled()
                        UIPasteboard.general.string = appIdea.detail
                        copied = true
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                            copied = false
                        }
                    }) {
                        ZStack {
                            Image(systemName: "doc.on.doc")
                                .font(.system(size: 15, weight: .medium))
                                .opacity(copied ? 0 : 1)
                            Image(systemName: "checkmark")
                                .font(.system(size: 15, weight: .medium))
                                .opacity(copied ? 1 : 0)
                        }
                        .foregroundColor(copied ? .green : .gray)
                        .frame(width: 28, height: 28)
                        .background(
                            Circle()
                                .fill(copied ? .green.opacity(0.1) : .gray.opacity(0.1))
                        )
                    }
                    .buttonStyle(.plain)
                }
            }

            // Category badge
            if let category {
                HStack {
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
                    Spacer()
                }
            }
        }
        .padding(16)
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
}

#Preview {
    VStack(spacing: 16) {
        AppIdeaRowView(
            appIdea: AppIdea(
                id: 1,
                title: "Fitness Tracker Pro",
                shortDescription: "A comprehensive fitness tracking app with AI-powered workout recommendations",
                detail: "This app will revolutionize how people track their fitness journey. It includes AI-powered workout recommendations, real-time progress tracking, social features for motivation, and integration with wearable devices.",
                isFavorite: true,
                updatedAt: Date(),
                categoryID: 1
            ),
            onFavorite: {}
        )

        AppIdeaRowView(
            appIdea: AppIdea(
                id: 2,
                title: "Smart Home Controller",
                shortDescription: "Centralized control for all your smart home devices",
                detail: "A unified app to control all smart home devices from different manufacturers. Features include voice control, automation rules, energy monitoring, and remote access.",
                isFavorite: false,
                updatedAt: Date().addingTimeInterval(-86400),
                categoryID: 2
            ),
            onFavorite: {}
        )
    }
    .padding()
    .background(Color(.systemGroupedBackground))
}
