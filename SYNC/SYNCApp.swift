import SwiftUI
import Firebase
import FirebaseAuth
import UserNotifications
import FirebaseMessaging
import RevenueCat



class AppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate, MessagingDelegate {    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        // Configure Firebase
//        FirebaseApp.configure()
        configureFirebase()
        
        Purchases.logLevel = .debug
        Purchases.configure(withAPIKey: "appl_VWiXuiOGUplEsjKASiNMggahmUi")

        // Set UNUserNotificationCenter delegate
        UNUserNotificationCenter.current().delegate = self

        // Request notification permission from the user
        let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
        UNUserNotificationCenter.current().requestAuthorization(options: authOptions) { granted, error in
            if let error = error {
                print("Failed to request authorization: \(error.localizedDescription)")
            } else if granted {
                print("Notification permission granted.")
            } else {
                print("Notification permission denied.")
            }
        }

        // Register for remote notifications
        application.registerForRemoteNotifications()

        // Set FCM delegate
        Messaging.messaging().delegate = self

        return true
    }
    

    // Called when APNs successfully registers your app and returns a device token
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        // Assign APNs token to FCM
        Messaging.messaging().apnsToken = deviceToken
        print("\(deviceToken)")

        // Convert device token to a string and log it
        let tokenString = deviceToken.map { String(format: "%02.2hhx", $0) }.joined()
        print("APNs Device Token: \(tokenString)")

        // Now that the APNs token is set, request the FCM token
        Messaging.messaging().token { token, error in
            if let error = error {
                print("Error fetching FCM token: \(error.localizedDescription)")
            } else if let token = token {
                print("FCM Token: \(token)")
            }
        }
    }

    // Called if registration for remote notifications failed
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Failed to register for remote notifications: \(error.localizedDescription)")
    }

    // Handle incoming notifications while the app is in the foreground
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        // Display the notification (sound, badge, banner)
        completionHandler([.sound, .badge, .banner])
    }

    // Handle notifications when the app is tapped or backgrounded
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo

        // Handle Firebase Auth notifications (if applicable)
        if Auth.auth().canHandleNotification(userInfo) {
            completionHandler()
            return
        }

        // Handle other notifications
        print("User tapped on notification: \(userInfo)")
        
        completionHandler()
    }

    // MessagingDelegate method to receive the FCM token
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        guard let fcmToken = fcmToken else { return }
        UserDefaults.standard.set(fcmToken, forKey: "FCMToken")
        print("Firebase registration token: \(fcmToken)")
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        // Handle Firebase Auth phone number authentication
        if Auth.auth().canHandleNotification(userInfo) {
            completionHandler(.newData)  // Indicate that the notification was handled
        } else {
            // Handle other types of notifications
            print("Received notification: \(userInfo)")
            completionHandler(.noData)
        }
    }
    
    private func configureFirebase() {
        #if STAGING
        print("⚙️ Using STAGING Firebase config")
        if let filePath = Bundle.main.path(forResource: "GoogleService-Info-Staging", ofType: "plist"),
           let options = FirebaseOptions(contentsOfFile: filePath) {
            FirebaseApp.configure(options: options)
        }
        #else
        print("⚙️ Using PRODUCTION Firebase config")
        if let filePath = Bundle.main.path(forResource: "GoogleService-Info-Prod", ofType: "plist"),
           let options = FirebaseOptions(contentsOfFile: filePath) {
            FirebaseApp.configure(options: options)
        }
        #endif
    }
}



@main
struct SYNCApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    @StateObject var chatRoomsManager = ChatRoomsManager()
    @StateObject var likesReceivedViewModel = LikesReceivedViewModel()
    @StateObject var subscriptionModel = SubscriptionModel()
    
    var body: some Scene {
        WindowGroup {
            SplashView()
                .environmentObject(chatRoomsManager)
                .environmentObject(likesReceivedViewModel)
                .environmentObject(subscriptionModel)
        }
    }
}
