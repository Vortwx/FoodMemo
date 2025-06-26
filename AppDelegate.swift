//
//  AppDelegate.swift
//  FIT3178-Project
//
//  Created by Yi Goh on 11/4/2024.
//

import UIKit
import UserNotifications

@main
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {

    var notificationsEnabled = false
    static let CATEGORY_IDENTIFIER = "foodNote.category"
    var databaseController: DatabaseProtocol?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        databaseController = CoreDataController()
        Task {
            let notificationCenter = UNUserNotificationCenter.current()
            let notificationSettings = await notificationCenter.notificationSettings()
            if notificationSettings.authorizationStatus == .notDetermined {
                let granted = try await notificationCenter.requestAuthorization(options: [.alert])
                self.notificationsEnabled = granted
                UserDefaults.standard.set(granted, forKey: "notificationEnabled")
            }
            else if notificationSettings.authorizationStatus == .authorized {
                self.notificationsEnabled = true
                UserDefaults.standard.set(true, forKey: "notificationEnabled")
            }
        }
        
            let acceptAction = UNNotificationAction(identifier: "accept", title: "Accept", options: .foreground)

            let declineAction = UNNotificationAction(identifier: "decline", title: "Decline", options: .destructive)

            let appCategory = UNNotificationCategory(identifier: AppDelegate.CATEGORY_IDENTIFIER, actions: [acceptAction, declineAction], intentIdentifiers: [], options: UNNotificationCategoryOptions(rawValue: 0))
        
            UNUserNotificationCenter.current().setNotificationCategories([appCategory])
        
        UNUserNotificationCenter.current().delegate = self
        // by default will return false
        notificationsEnabled = UserDefaults.standard.bool(forKey: "notificationEnabled")
        
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
    
    // MARK: UNUserNotificationCenterDelegate methods

    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification) async -> UNNotificationPresentationOptions {
        /// Delete message after notification is invoked
        let identifier = notification.request.identifier
        UserDefaults.standard.removeObject(forKey: identifier)
        UserDefaultObserver.shared.notifyUserDefaultDidChange()
        return [.banner]
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse) async {
        /// For debug purpose
        if response.notification.request.content.categoryIdentifier == AppDelegate.CATEGORY_IDENTIFIER {
            switch response.actionIdentifier {
                case "accept":
                    print("accepted")
                case "decline":
                    print("declined")
                default:
                    print("other")
            }
        }
        else {
            print("General notification")
        }    }

    
    func scheduleLocalNotification(plan: Plan){
        checkNotificationPermission()
        let content = UNMutableNotificationContent()
        content.title = "Upcoming Meal"

        /// dummy values
        var recipeName = ""
        var formattedDate = "&"


        if let recipe = plan.recipeMember {
            guard let name = recipe.name else{
                fatalError("Recipe without name exists")
            }
            recipeName = "\(name)"
            content.body = "Reminder for preparation: \(recipeName) is scheduled to be prepared in 1 hour."
        }
        content.sound = UNNotificationSound.default
        content.categoryIdentifier = AppDelegate.CATEGORY_IDENTIFIER
        
        if let time = plan.eatingTime {
            //** Testing only
//            let TEST = Calendar.current.date(byAdding: .second, value: 10, to: Date())
//            guard let TESTTIME = TEST else {return}
            //** Testing only
            let reminderTime = Calendar.current.date(byAdding: .hour, value: -1, to: time)
            guard let reminder = reminderTime else {
                fatalError("reminder time extraction failed")
            }
            let triggerDate = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second], from: reminder)
            
            let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDate, repeats: false)
            //----- Formatting Date for output
            let dateformatter = DateFormatter()
            dateformatter.dateFormat = "yyyy-MM-dd HH:mm"
            formattedDate = dateformatter.string(from:time)
            //-----
            /// The notification is scheduled based on plan hence it is identified by plan id
            let request = UNNotificationRequest(identifier: plan.id.uuidString, content: content, trigger: trigger)
            UNUserNotificationCenter.current().add(request) {
                error in
                if let error = error {
                    print("Error scheduling notification: \(error.localizedDescription)")
                } else {
                    /// schedule notification only if the reminder time is in the future
                    if Date() < reminder {
                        UserDefaults.standard.set([recipeName,formattedDate], forKey: plan.id.uuidString)
                        UserDefaultObserver.shared.notifyUserDefaultDidChange()
                    }
                }
            }
        }
    }
    
    func descheduleLocalNotification(plan:Plan){
        /// Remove notification from notification center
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [plan.id.uuidString])
        UserDefaults.standard.removeObject(forKey: plan.id.uuidString)
        UserDefaultObserver.shared.notifyUserDefaultDidChange()
    }
    
    /// Check if notification permission is granted
    func checkNotificationPermission(){
        let center = UNUserNotificationCenter.current()
        center.getNotificationSettings{ settings in
            switch settings.authorizationStatus {
            case .authorized:
                print("Notification permission granted")
            case .denied:
                print("Notification permission denied")
                self.showPermissionAlert()
            case .notDetermined:
                print("Notification permission not determined")
            case .provisional:
                print("Notification permission provisional")
            case .ephemeral:
                print("Notification permission ephemeral")
            @unknown default:
                fatalError("New case for UNAuthorizationStatus added")
            }
        }
    }
        
    func showPermissionAlert() {
            guard let rootViewController = UIApplication.shared.windows.first?.rootViewController else {
                return
            }
            let alert = UIAlertController(title: "Notification Permission Required", message: "Please grant permission to receive notifications.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            alert.addAction(UIAlertAction(title: "Settings", style: .default, handler: { _ in
                if let settingsUrl = URL(string: UIApplication.openSettingsURLString) {
                    if UIApplication.shared.canOpenURL(settingsUrl) {
                        UIApplication.shared.open(settingsUrl, completionHandler: nil)
                    }
                }
            }))
            rootViewController.present(alert, animated: true, completion: nil)
        }
        
}

