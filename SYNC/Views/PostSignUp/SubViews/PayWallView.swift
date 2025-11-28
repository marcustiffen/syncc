//import Foundation
//import SwiftUI
//import RevenueCat
//
//
//
//struct PayWallView: View {
//    @Binding var isPaywallPresented: Bool
//    @State var currentOffering: Offering?
//    @State private var isPresentEULA = false
//    @State private var isPresentPrivacyPolicy = false
//    
//    @State private var isPurchasing: Bool = false
//
//    @EnvironmentObject var profileModel: ProfileModel
//    @EnvironmentObject var subscriptionModel: SubscriptionModel
//
//    var body: some View {
//        ZStack {
//            VStack(alignment: .leading, spacing: 20) {
//                Text("Upgrade to Premium")
//                    .h1Style()
//                    .foregroundStyle(.syncBlack)
//                
//                Text("Enjoy unlimited likes, more matches, advanced filters, and all our premium features without limits!")
//                    .h2Style()
//                    .foregroundStyle(.syncGrey)
//                
//                Spacer()
//                
//                if currentOffering != nil {
//                    ForEach(currentOffering!.availablePackages) { pkg in
//                        Button {
//                            withAnimation {
//                                isPurchasing = true
//                            }
//                            // BUY
//                            Purchases.shared.purchase(package: pkg) { (transaction, customerInfo, error, userCancelled) in
//                                if customerInfo?.entitlements.all["Premium"]?.isActive == true {
//                                    subscriptionModel.isSubscriptionActive = true
//                                    isPurchasing = false
//                                    isPaywallPresented = false
//                                }
//                            }
//                            print("Successful purchase of \(pkg.storeProduct.subscriptionPeriod!.periodTitle) \(pkg.storeProduct.localizedPriceString)")
//                        } label: {
//                            ZStack {
//                                Rectangle()
//                                    .frame(height: 55)
//                                    .foregroundStyle(.syncGreen)
//                                    .cornerRadius(10)
//                                
//                                Text("\(pkg.storeProduct.subscriptionPeriod!.periodTitle) \(pkg.storeProduct.localizedPriceString)")
//                                    .foregroundStyle(.syncBlack)
//                                    .h2Style()
//                            }
//                        }
//                    }
//                }
//                
//                Spacer()
//                
//                HStack {
//                    Button("Privacy Policy") {
//                        isPresentPrivacyPolicy = true
//                    }
//                    .foregroundStyle(.syncBlack)
//                    .underline()
//                    .bodyTextStyle()
//                    
//                    Spacer()
//                    
//                    Button("Terms of Use") {
//                        isPresentEULA = true
//                    }
//                    .foregroundStyle(.syncBlack)
//                    .underline()
//                    .bodyTextStyle()
//                }
//                
//                .sheet(isPresented: $isPresentPrivacyPolicy) {
//                    WebView(url: URL(string: "https://www.freeprivacypolicy.com/live/eb4dff28-4b8f-49aa-8154-179310a1ec20")!)
//                }
//                
//                .sheet(isPresented: $isPresentEULA) {
//                    WebView(url: URL(string: "https://www.apple.com/legal/internet-services/itunes/dev/stdeula/")!)
//                }
//            }
//            .padding(50)
//            
//            Rectangle()
//                .foregroundColor(Color.black)
//                .opacity(isPurchasing ? 0.5: 0.0)
//                .edgesIgnoringSafeArea(.all)
//        }
//        .onAppear {
//            Purchases.shared.getOfferings { offerings, error in
//                if let offer = offerings?.current, error == nil {
//                    currentOffering = offer
//                }
//            }
//        }
//    }
//}
//
//
//
//
//extension Package {
//    func terms(for package: Package) -> String {
//        if let intro = package.storeProduct.introductoryDiscount {
//            if intro.price == 0 {
//                return "\(intro.subscriptionPeriod.periodTitle) free trial"
//            } else {
//                return "\(package.localizedIntroductoryPriceString!) for \(intro.subscriptionPeriod.periodTitle)"
//            }
//        } else {
//            return "Unlocks Premium"
//        }
//    }
//}
//
//
//
//extension SubscriptionPeriod {
//    var durationTitle: String {
//        switch self.unit {
//        case .day: return "day"
//        case .week: return "week"
//        case .month: return "month"
//        case .year: return "year"
//        @unknown default: return "Unknown"
//        }
//    }
//    
//    var periodTitle: String {
//        let periodString = "\(self.value) \(self.durationTitle)"
//        let pluralized = self.value > 1 ?  periodString + "s" : periodString
//        return pluralized
//    }
//}



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
            // Background gradient
            LinearGradient(
                gradient: Gradient(colors: [Color.white, Color(.systemGray6)]),
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header Section
                VStack(alignment: .center, spacing: 12) {
                    Image(systemName: "crown.fill")
                        .font(.system(size: 50))
                        .foregroundStyle(.syncGreen)
                        .padding(.top, 40)
                    
                    Text("Upgrade to Premium")
                        .h1Style()
                        .foregroundStyle(.syncBlack)
                        .multilineTextAlignment(.center)
                    
                    Text("Unlock unlimited likes, exclusive filters, and premium features")
                        .h2Style()
                        .foregroundStyle(.syncGrey)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 30)
                }
                .padding(.bottom, 30)
                
                // Features List
                VStack(alignment: .leading, spacing: 16) {
                    FeatureRow(icon: "hand.thumbsup.fill", text: "Send Unlimited Syncc Requests")
                    FeatureRow(icon: "figure.run", text: "See Incoming Syncc Requests")
                    FeatureRow(icon: "slider.horizontal.3", text: "Custom Filter Options")
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 24)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color.white)
                        .shadow(color: Color.black.opacity(0.08), radius: 20, x: 0, y: 4)
                )
                .padding(.horizontal, 30)
                
                Spacer()
                
                // Package Selection
                if currentOffering != nil {
                    VStack(spacing: 12) {
                        ForEach(Array(currentOffering!.availablePackages.enumerated()), id: \.element.id) { index, pkg in
                            PackageButton(
                                package: pkg,
                                isPopular: index == 0,
                                isPurchasing: $isPurchasing,
                                action: {
                                    purchasePackage(pkg)
                                }
                            )
                        }
                    }
                    .padding(.horizontal, 30)
                }
                
                Spacer()
                
                // Footer Links
                HStack(spacing: 24) {
                    Button("Terms") {
                        isPresentEULA = true
                    }
                    .foregroundStyle(.syncGrey)
                    .bodyTextStyle()
                    
                    Text("•")
                        .foregroundStyle(.syncGrey)
                    
                    Button("Restore") {
                        restorePurchases()
                    }
                    .foregroundStyle(.syncGrey)
                    .bodyTextStyle()
                    
                    Text("•")
                        .foregroundStyle(.syncGrey)
                    
                    Button("Privacy") {
                        isPresentPrivacyPolicy = true
                    }
                    .foregroundStyle(.syncGrey)
                    .bodyTextStyle()
                }
                .padding(.bottom, 20)
                
                .sheet(isPresented: $isPresentPrivacyPolicy) {
                    WebView(url: URL(string: "https://www.freeprivacypolicy.com/live/eb4dff28-4b8f-49aa-8154-179310a1ec20")!)
                }
                
                .sheet(isPresented: $isPresentEULA) {
                    WebView(url: URL(string: "https://www.apple.com/legal/internet-services/itunes/dev/stdeula/")!)
                }
            }
            
            // Close Button
            VStack {
                HStack {
                    Spacer()
                    Button {
                        isPaywallPresented = false
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 30))
                            .foregroundStyle(.syncGrey.opacity(0.6))
                    }
                    .padding(.trailing, 20)
                    .padding(.top, 20)
                }
                Spacer()
            }
            
            // Loading Overlay
            if isPurchasing {
                Color.black.opacity(0.4)
                    .ignoresSafeArea()
                
                VStack(spacing: 16) {
                    ProgressView()
                        .scaleEffect(1.5)
                        .tint(.white)
                    Text("Processing...")
                        .foregroundStyle(.white)
                        .font(.headline)
                }
            }
        }
        .onAppear {
            Purchases.shared.getOfferings { offerings, error in
                if let offer = offerings?.current, error == nil {
                    currentOffering = offer
                }
            }
        }
    }
    
    private func purchasePackage(_ pkg: Package) {
        withAnimation {
            isPurchasing = true
        }
        
        Purchases.shared.purchase(package: pkg) { (transaction, customerInfo, error, userCancelled) in
            isPurchasing = false
            
            if customerInfo?.entitlements.all["Premium"]?.isActive == true {
                subscriptionModel.isSubscriptionActive = true
                isPaywallPresented = false
            }
        }
        print("Successful purchase of \(pkg.storeProduct.subscriptionPeriod!.periodTitle) \(pkg.storeProduct.localizedPriceString)")
    }
    
    private func restorePurchases() {
//        Purchases.shared.restorePurchases { customerInfo, error in
//            if customerInfo?.entitlements.all["Premium"]?.isActive == true {
//                subscriptionModel.isSubscriptionActive = true
//                isPaywallPresented = false
//            }
//        }
        
        Purchases.shared.restorePurchases { (customerInfo, error) in
            subscriptionModel.isSubscriptionActive = customerInfo?.entitlements.all["Premium"]?.isActive == true
        }
    }
}

// MARK: - Feature Row Component
struct FeatureRow: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 18))
                .foregroundStyle(.syncGreen)
                .frame(width: 24)
            
            Text(text)
                .bodyTextStyle()
                .foregroundStyle(.syncBlack)
            
            Spacer()
        }
    }
}


struct PackageButton: View {
    let package: Package
    let isPopular: Bool
    @Binding var isPurchasing: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            ZStack(alignment: .topTrailing) {
                VStack(spacing: 8) {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(package.storeProduct.subscriptionPeriod!.periodTitle)
                                .font(.system(size: 18, weight: .bold))
                                .foregroundStyle(.syncBlack)
                            
                            if let intro = package.storeProduct.introductoryDiscount {
                                Text(intro.price == 0 ? "Free Trial" : "Special Offer")
                                    .font(.system(size: 12, weight: .medium))
                                    .foregroundStyle(.syncGreen)
                            }
                        }
                        
                        Spacer()
                        
                        Text(package.storeProduct.localizedPriceString)
                            .font(.system(size: 22, weight: .bold))
                            .foregroundStyle(.syncBlack)
                    }
                }
                .padding(20)
                .frame(maxWidth: .infinity)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.white)
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                        )
                )
                
                if isPopular {
                    Text("MOST POPULAR")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 4)
                        .background(
                            Capsule()
                                .fill(Color.syncGreen)
                        )
                        .offset(x: -12, y: -8)
                }
            }
        }
        .disabled(isPurchasing)
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
