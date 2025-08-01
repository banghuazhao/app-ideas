//
// Created by Banghua Zhao on 08/07/2025
// Copyright Apps Bay Limited. All rights reserved.
//
  

import Foundation

struct CategoryStore {
    // Reduced set of example default categories for seeding, each prefixed with an emoji
    static let seed: [Category.Draft] = [
        .init(id: 1, title: "📚 Beginner Projects"),
        .init(id: 2, title: "💻 Intermediate Projects"),
        .init(id: 3, title: "🧠 Advanced Projects")
    ]
}
