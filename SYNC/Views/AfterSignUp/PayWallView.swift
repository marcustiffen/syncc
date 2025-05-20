import Foundation
import SwiftUI
import RevenueCat



struct PayWallView: View {
    @Binding var isPaywallPresented: Bool
    @State var currentOffering: Offering?
    @State private var isPresentEULA = false
    @State private var isPresentPrivacyPolicy = false
    
    @State private var isPurchasing: Bool = false

    @EnvironmentObject var profileModel: ProfileModel
    @EnvironmentObject var subscriptionModel: SubscriptionModel

    var body: some View {
        ZStack {
            VStack(alignment: .leading, spacing: 20) {
                Text("Upgrade to Premium")
                    .h1Style()
                    .foregroundStyle(.syncBlack)
                
                Text("Enjoy unlimited likes, more matches, advanced filters, and all our premium features—without limits!")
                    .h2Style()
                    .foregroundStyle(.syncGrey)
                
                Spacer()
                
                if currentOffering != nil {
                    ForEach(currentOffering!.availablePackages) { pkg in
                        Button {
                            isPurchasing = true
                            // BUY
                            Purchases.shared.purchase(package: pkg) { (transaction, customerInfo, error, userCancelled) in
                                if customerInfo?.entitlements.all["Premium"]?.isActive == true {
                                    subscriptionModel.isSubscriptionActive = true
                                    isPurchasing = false
                                    isPaywallPresented = false
                                }
                            }
                            print("Successful purchase of \(pkg.storeProduct.subscriptionPeriod!.periodTitle) \(pkg.storeProduct.localizedPriceString)")
                        } label: {
                            ZStack {
                                Rectangle()
                                    .frame(height: 55)
                                    .foregroundStyle(.syncGreen)
                                    .cornerRadius(10)
                                
                                Text("\(pkg.storeProduct.subscriptionPeriod!.periodTitle) \(pkg.storeProduct.localizedPriceString)")
                                    .foregroundStyle(.syncBlack)
                                    .h2Style()
                            }
                        }
                    }
                }
                
                Spacer()
                
                HStack {
                    Button("Privacy Policy") {
                        isPresentPrivacyPolicy = true
                    }
                    .foregroundStyle(.syncBlack)
                    .underline()
                    .bodyTextStyle()
                    
                    Spacer()
                    
                    Button("Terms of Use") {
                        isPresentEULA = true
                    }
                    .foregroundStyle(.syncBlack)
                    .underline()
                    .bodyTextStyle()
                }
                
                .sheet(isPresented: $isPresentPrivacyPolicy) {
                    WebView(url: URL(string: "https://www.freeprivacypolicy.com/live/eb4dff28-4b8f-49aa-8154-179310a1ec20")!)
                }
                
                .sheet(isPresented: $isPresentEULA) {
                    WebView(url: URL(string: "https://www.apple.com/legal/internet-services/itunes/dev/stdeula/")!)
                }
            }
            
            Rectangle()
                .foregroundColor(Color.black)
                .opacity(isPurchasing ? 0.5: 0.0)
                .edgesIgnoringSafeArea(.all)
        }
        .padding(50)
        .onAppear {
            Purchases.shared.getOfferings { offerings, error in
                if let offer = offerings?.current, error == nil {
                    currentOffering = offer
                }
            }
        }
    }
}




extension Package {
    func terms(for package: Package) -> String {
        if let intro = package.storeProduct.introductoryDiscount {
            if intro.price == 0 {
                return "\(intro.subscriptionPeriod.periodTitle) free trial"
            } else {
                return "\(package.localizedIntroductoryPriceString!) for \(intro.subscriptionPeriod.periodTitle)"
            }
        } else {
            return "Unlocks Premium"
        }
    }
}



extension SubscriptionPeriod {
    var durationTitle: String {
        switch self.unit {
        case .day: return "day"
        case .week: return "week"
        case .month: return "month"
        case .year: return "year"
        @unknown default: return "Unknown"
        }
    }
    
    var periodTitle: String {
        let periodString = "\(self.value) \(self.durationTitle)"
        let pluralized = self.value > 1 ?  periodString + "s" : periodString
        return pluralized
    }
}
