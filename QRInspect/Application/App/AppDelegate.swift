//
//  AppDelegate.swift
//  QRInspect
//
//  Created by Сергей Майбродский on 07.03.2023.
//

import UIKit
import IQKeyboardManagerSwift
import Firebase
import UserNotifications
import FirebaseCore


@main
class AppDelegate: UIResponder, UIApplicationDelegate, MessagingDelegate, UNUserNotificationCenterDelegate {

    var window: UIWindow?

    let gcmMessageIDKey = "gcm.message_id"

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        //keyboard lib
        IQKeyboardManager.shared.enable = true

        if UserDefaults.standard.value(forKey: "isRegistered") == nil {
            UserDefaults.standard.set(false, forKey: "isRegistered")
            UserDefaults.standard.set(0, forKey: "id")
            UserDefaults.standard.set("", forKey: "login")
            UserDefaults.standard.set("", forKey: "firstName")
            UserDefaults.standard.set("", forKey: "lastName")
            UserDefaults.standard.set("", forKey: "patronymic")
            UserDefaults.standard.set("", forKey: "avatar")
            UserDefaults.standard.set(Data(), forKey: "position")
            UserDefaults.standard.set(0, forKey: "userType")
            UserDefaults.standard.set(Data(), forKey: "company")
            UserDefaults.standard.set(Data(), forKey: "group")
            
            UserDefaults.standard.set(false, forKey: "isStartWork")
            
            UserDefaults.standard.set("", forKey: "firebaseToken")
        }
        
        //notfications
        FirebaseApp.configure()
        
        Messaging.messaging().delegate = self
        
        
            UNUserNotificationCenter.current().delegate = self
            let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
            
            UNUserNotificationCenter.current().requestAuthorization(options: authOptions) { (_, error) in
                guard error == nil else{
                    print(error!.localizedDescription)
                    return
                }
            }
            
            
            
            //Solicit permission from the user to receive notifications
            UNUserNotificationCenter.current().requestAuthorization(options: authOptions) { (_, error) in
                guard error == nil else{
                    print(error!.localizedDescription)
                    return
                }
            }
        
        Messaging.messaging().token { token, error in
            if let error = error {
                print("Error fetching FCM registration token: \(error)")
            } else if let token = token {
                print("FCM registration token: \(token)")
                UserDefaults.standard.set(token, forKey: "firebaseToken")
            }
        }
        
        
        application.registerForRemoteNotifications()
        
        return true
    }
    

    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any]) {
        if let messageID = userInfo[gcmMessageIDKey] {
            print("Message ID: \(messageID)")
        }
        print(userInfo)
        
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
      }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Unable to register for remote notifications: \(error.localizedDescription)")
    }
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        print("Firebase registration token: \(fcmToken ?? "is nil")")
    }
    
    func messaging(_ messaging: Messaging, didReceive remoteMessage: MessagingDelegate) {
        print("Received data message: \(remoteMessage.description)")
    }
    
    
    // MARK: UISceneSession Lifecycle
    
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
    
    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
    }

}
