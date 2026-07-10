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
        static let casualPants = "Casual Pants"
        static let outerwear = "Outerwear"
    }
    
    static let batikShirts: [ClothingItem] = [
        ClothingItem(name: "Blue Parang Batik", imageName: "blue-parang-batik-shirt"),
        ClothingItem(name: "Red Megamendung Batik", imageName: "red-megamendung-batik-shirt")
    ]
    
    static let casualPants: [ClothingItem] = [
        ClothingItem(name: "Blue Denim Jeans", imageName: "blue-denim-jeans"),
        ClothingItem(name: "Grey Fleece Sweatpants", imageName: "grey-fleece-sweatpants")
    ]
    
    static let outerwear: [ClothingItem] = [
        ClothingItem(name: "Grey Formal Blazer", imageName: "grey-formal-blazer"),
        ClothingItem(name: "Olive Casual Overshirt", imageName: "olive-casual-overshirt")
    ]
    
    static let allSections: [ClothingSection] = [
        ClothingSection(title: SectionTitle.batikShirts, hasDecorativeAsset: false, items: batikShirts),
        ClothingSection(title: SectionTitle.casualPants, hasDecorativeAsset: false, items: casualPants),
        ClothingSection(title: SectionTitle.outerwear, hasDecorativeAsset: false, items: outerwear)
    ]
}
