import Foundation


struct ActivityFilter: Equatable {
    var radiusKm: Double? = nil // nil means no radius filter
    var dateRange: DateRangeFilter = .all
    var searchText: String = ""
    var userLocation: DBLocation? = nil
    
    var isActive: Bool {
        radiusKm != nil || dateRange != .all || !searchText.isEmpty
    }
    
    // Helper to check if only search changed (for debouncing)
    func onlySearchChanged(from other: ActivityFilter) -> Bool {
        radiusKm == other.radiusKm &&
        dateRange == other.dateRange &&
        userLocation?.location.latitude == other.userLocation?.location.latitude &&
        userLocation?.location.longitude == other.userLocation?.location.longitude &&
        searchText != other.searchText
    }
    
    static func == (lhs: ActivityFilter, rhs: ActivityFilter) -> Bool {
        lhs.radiusKm == rhs.radiusKm &&
        lhs.dateRange == rhs.dateRange &&
        lhs.searchText == rhs.searchText &&
        lhs.userLocation?.location.latitude == rhs.userLocation?.location.latitude &&
        lhs.userLocation?.location.longitude == rhs.userLocation?.location.longitude
    }
}
