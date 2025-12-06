import Foundation
import RevenueCat


class SubscriptionModel: ObservableObject {
    @Published var isSubscriptionActive = false
    @Published var subscriptionDetails: String = "No active subscription"
    
    
//    init() {
//        checkSubscriptionStatus()
//    }
    
    func checkSubscriptionStatus() {
        Purchases.shared.getCustomerInfo { [weak self] (customerInfo, error) in
            guard let self = self else { return }
            
            if let error = error {
                print("Error fetching subscription info: \(error.localizedDescription)")
                self.isSubscriptionActive = false
                self.subscriptionDetails = "Error checking subscription"
                return
            }
            
            // Check if Premium entitlement exists and is active
            if let premiumEntitlement = customerInfo?.entitlements.all["Premium"],
               premiumEntitlement.isActive {
                self.isSubscriptionActive = true
                
                // Get additional subscription details
                if let expirationDate = premiumEntitlement.expirationDate {
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateStyle = .medium
                    self.subscriptionDetails = "Premium until \(dateFormatter.string(from: expirationDate))"
                } else {
                    self.subscriptionDetails = "Premium (lifetime)"
                }
            } else {
                self.isSubscriptionActive = false
                self.subscriptionDetails = "No active subscription"
                
                // Debug info
                if let entitlements = customerInfo?.entitlements.all {
                    print("Available entitlements: \(entitlements.keys.joined(separator: ", "))")
                    for (key, entitlement) in entitlements {
                        print("Entitlement \(key): isActive = \(entitlement.isActive)")
                    }
                } else {
                    print("No entitlements found")
                }
            }
        }
    }
}
