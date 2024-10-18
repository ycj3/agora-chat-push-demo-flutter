//
//  NotificationService.swift
//  NotificationServiceExtension
//
//  Created by Carlson Yuan on 2024/10/18.
//

import UserNotifications

class NotificationService: UNNotificationServiceExtension {
    
    var contentHandler: ((UNNotificationContent) -> Void)?
    var bestAttemptContent: UNMutableNotificationContent?
    let defaults = UserDefaults(suiteName: "group.com.carlson.demo")
    
    override func didReceive(_ request: UNNotificationRequest, withContentHandler contentHandler: @escaping (UNNotificationContent) -> Void) {
        self.contentHandler = contentHandler
        guard let bestAttemptContent = (request.content.mutableCopy() as? UNMutableNotificationContent) else {
            contentHandler(request.content)
            return
        }
        
        // show media attachments
        guard let agoraExtern = bestAttemptContent.userInfo["e"] as? Dictionary<String, String>,
              let mediaURL = agoraExtern["media-url"] else {
            contentHandler(bestAttemptContent)
            return
        }
        downloadAndCreateAttachment(url: mediaURL) { attachment in
            if let attachment = attachment {
                // Attachment downloaded successfully, proceed with modifying notification content
                bestAttemptContent.attachments = [attachment]
            } else {
                // Failed to download attachment, handle error or fallback to default behavior
                print("Failed to download attachment")
            }
            contentHandler(bestAttemptContent)
        }
        
    }
    
    override func serviceExtensionTimeWillExpire() {
        if let contentHandler = contentHandler, let bestAttemptContent =  bestAttemptContent {
            contentHandler(bestAttemptContent)
        }
    }
    
    func downloadAndCreateAttachment(url: String, completionHandler: @escaping (UNNotificationAttachment?) -> Void) {
        guard let imageURL = URL(string: url) else {
            completionHandler(nil)
            return
        }

        let task = URLSession.shared.dataTask(with: imageURL) { (data, response, error) in
            guard let imageData = data, error == nil else {
                print("Failed to download image:", error?.localizedDescription ?? "Unknown error")
                completionHandler(nil)
                return
            }

            let tempDirectory = URL(fileURLWithPath: NSTemporaryDirectory())
            let attachmentURL = tempDirectory.appendingPathComponent(imageURL.lastPathComponent)

            do {
                try imageData.write(to: attachmentURL)
                let attachment = try UNNotificationAttachment(identifier: "imageAttachment", url: attachmentURL, options: nil)
                completionHandler(attachment)
            } catch {
                print("Error creating attachment: \(error.localizedDescription)")
                completionHandler(nil)
            }
        }

        task.resume()
    }

}
