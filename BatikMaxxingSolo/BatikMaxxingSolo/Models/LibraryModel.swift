import Foundation

enum GenderCategory: String, CaseIterable, Identifiable {
    case man = "Man"
    case woman = "Woman"

    var id: String { self.rawValue }
}

/// Item yang tampil di grid library — bisa berasal dari koleksi bawaan
/// (asset di bundle) atau upload user (record SwiftData).
struct ClothingItem: Identifiable, Hashable {
    enum Source: Hashable {
        case bundled(assetName: String)
        case userUpload(id: UUID, imageData: Data)
    }

    let name: String
    let source: Source

    /// ID stabil: asset name untuk bawaan (unik & permanen — tidak seperti
    /// UUID() yang berubah setiap app jalan), UUID record untuk upload.
    var id: String {
        switch source {
        case .bundled(let assetName): return assetName
        case .userUpload(let id, _): return id.uuidString
        }
    }
}

struct ClothingSection: Identifiable, Hashable {
    let title: String
    let hasDecorativeAsset: Bool
    let gender: GenderCategory
    let items: [ClothingItem]

    var id: String { "\(gender.rawValue)-\(title)" }
}

enum BundledOutfitCatalog {

    enum SectionTitle {
        static let batikShirts = "Batik Shirts"
        static let batikPants = "Batik Pants"
        static let outerwear = "Outerwear"
        static let casualPants = "Casual Pants"
    }

    // MARK: - Man

    static let manSections: [ClothingSection] = [
        ClothingSection(
            title: SectionTitle.batikShirts,
            hasDecorativeAsset: true,
            gender: .man,
            items: [
                ClothingItem(name: "Blue Parang Batik", source: .bundled(assetName: "ClothingItems/blue-parang-batik-shirt")),
                ClothingItem(name: "Red Megamendung Batik", source: .bundled(assetName: "ClothingItems/red-megamendung-batik-shirt"))
            ]
        ),
        ClothingSection(
            title: SectionTitle.batikPants,
            hasDecorativeAsset: true,
            gender: .man,
            items: []
        ),
        ClothingSection(
            title: SectionTitle.outerwear,
            hasDecorativeAsset: false,
            gender: .man,
            items: [
                ClothingItem(name: "Grey Formal Blazer", source: .bundled(assetName: "ClothingItems/grey-formal-blazer")),
                ClothingItem(name: "Olive Casual Overshirt", source: .bundled(assetName: "ClothingItems/olive-casual-overshirt"))
            ]
        ),
        ClothingSection(
            title: SectionTitle.casualPants,
            hasDecorativeAsset: false,
            gender: .man,
            items: [
                ClothingItem(name: "Blue Denim Jeans", source: .bundled(assetName: "ClothingItems/blue-denim-jeans")),
                ClothingItem(name: "Grey Fleece Sweatpants", source: .bundled(assetName: "ClothingItems/grey-fleece-sweatpants"))
            ]
        )
    ]

    // MARK: - Woman
    // TODO: isi dengan asset koleksi woman saat sudah tersedia
    static let womanSections: [ClothingSection] = []

    static func sections(for gender: GenderCategory) -> [ClothingSection] {
        switch gender {
        case .man: return manSections
        case .woman: return womanSections
        }
    }
}
