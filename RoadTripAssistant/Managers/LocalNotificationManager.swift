//
//  LocalNotificationManager.swift
//  RoadTripAssistant
//
//  Created by Isabel Pebaqué on 2019-04-30.
//  Copyright © 2019 Isabel Pebaqué. All rights reserved.
//

import UIKit
import MapKit
import UserNotifications


class LocalNotificationManager: UIView {
    
    static let shared = LocalNotificationManager()
    let locationManager = CLLocationManager()

    
    func setupLocalNotification(annotation: MKMapItem) {
        
        let userActions = "User Actions"
        
        let content = UNMutableNotificationContent()
        content.title = "Du har en match!"
        content.subtitle = annotation.name!
        content.body = "Färdbeskrivning"
        content.sound = .default
        content.categoryIdentifier = userActions
        content.userInfo = ["notificationLongitude" : annotation.placemark.coordinate.longitude, "notificationLatitude" : annotation.placemark.coordinate.latitude, "notificationName" : annotation.name!]
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        
        let uuidString = UUID().uuidString
        let request = UNNotificationRequest(identifier: uuidString, content: content, trigger: trigger)
        
        let navigationAction = UNNotificationAction(identifier: "navigation", title: "Färdbeskrivning", options: .foreground)
        let category = UNNotificationCategory(identifier: userActions, actions: [navigationAction], intentIdentifiers: [], options: [])
        
        UNUserNotificationCenter.current().setNotificationCategories([category])
        UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
        
    }
}
