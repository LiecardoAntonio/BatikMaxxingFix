import Foundation

enum GenderCategory: String, CaseIterable, Identifiable {
    case man = "Man"
    case woman = "Woman"
    
    var id: String { self.rawValue }
}

struct ClothingItem: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let imageName: String
}

struct ClothingSection: Identifiable, Hashable {
    let id = UUID()
    let title: String
    let hasDecorativeAsset: Bool
    let items: [ClothingItem]
}

enum LibraryMockData {
    
    enum SectionTitle {
        static let batikShirts = "Batik Shirts"
        static let batikPants = "Batik Pants"
        static let outerwear = "Outerwear"
        static let casualPants = "Casual Pants"
    }
    
    static let batikShirts: [ClothingItem] = [
        ClothingItem(name: "Blue Parang Batik", imageName: "ClothingItems/blue-parang-batik-shirt"),
        ClothingItem(name: "Red Megamendung Batik", imageName: "ClothingItems/red-megamendung-batik-shirt")
    ]

    static let batikPants: [ClothingItem] = []

    static let outerwear: [ClothingItem] = [
        ClothingItem(name: "Grey Formal Blazer", imageName: "ClothingItems/grey-formal-blazer"),
        ClothingItem(name: "Olive Casual Overshirt", imageName: "ClothingItems/olive-casual-overshirt")
    ]

    static let casualPants: [ClothingItem] = [
        ClothingItem(name: "Blue Denim Jeans", imageName: "ClothingItems/blue-denim-jeans"),
        ClothingItem(name: "Grey Fleece Sweatpants", imageName: "ClothingItems/grey-fleece-sweatpants")
    ]
    
    static let myOutfits: [ClothingItem] = []
    
    static let allSections: [ClothingSection] = [
        ClothingSection(title: SectionTitle.batikShirts, hasDecorativeAsset: true, items: batikShirts),
        ClothingSection(title: SectionTitle.batikPants, hasDecorativeAsset: true, items: batikPants),
        ClothingSection(title: SectionTitle.outerwear, hasDecorativeAsset: false, items: outerwear),
        ClothingSection(title: SectionTitle.casualPants, hasDecorativeAsset: false, items: casualPants)
    ]
}
