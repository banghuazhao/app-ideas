//
// Created by Banghua Zhao on 01/08/2025
// Copyright Apps Bay Limited. All rights reserved.
//

import Foundation
import SharingGRDB

@Table
struct AppIdea: Identifiable, Hashable {
    let id: Int
    var title: String = ""
    var icon: String = "💻"
    var shortDescription: String = ""
    var detail: String = ""
    var isFavorite: Bool = false
    var updatedAt: Date = Date()
    var categoryID: Category.ID? = nil
}

extension AppIdea.Draft: Identifiable, Hashable {}
