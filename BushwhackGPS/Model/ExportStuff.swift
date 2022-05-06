//
//  ExportStuff.swift
//  BushwhackGPS
//
//  Created by William Hause on 4/14/22.
//

//
// Example Usage:   ExportStuff.share(items: ["This is my text"])

//
// Code came from here but I needed to update a line and
// add Extensions to UIApplication to get the rootViewController
//https://stackoverflow.com/questions/56819360/swiftui-exporting-or-sharing-files?answertab=oldest#tab-top
// and
//https://www.hackingwithswift.com/read/3/2/uiactivityviewcontroller-explained
//
// NOTE: The Subject Line class doesn't seem to work quite right yet.
//

import SwiftUI

struct ExportStuff {

//    @discardableResult // remove warning if the calling code doesn't use the return value
//    static func shareDELETE_ME_NOW(items: [Any],
//               excludedActivityTypes: [UIActivity.ActivityType]? = nil) -> Bool {
//
//        guard let rootVC = UIApplication.shared.rootViewController
//        else {
//            MyLog.debug("wdh ExportStuff.share unable to get rootViewController")
//            return false
//        }
//
//        let vc = UIActivityViewController(
//            activityItems: items,
//            applicationActivities: nil //[] //nil
//        )
//        vc.excludedActivityTypes = excludedActivityTypes
//        vc.popoverPresentationController?.sourceView = rootVC.view
//        rootVC.present(vc, animated: true) // Error "Attempt to present UIActivityViewController ... which is already presenting"
//        MyLog.debug("ExportStuff.share() Done Exporting")
//        return true
//    }
    
    
    
    // If your RootViewController is already presenting another ViewController, then you must
    // use the sectind ViewController to present this Thrid view controller.
    // A ViewController can only present ONE modal ViewController on top of itself
    // Therefore we allow the caller to pass in the ViewController that we should use.
    @discardableResult // remove warning if the calling code doesn't use the return value
    static func share(items: [Any],
               excludedActivityTypes: [UIActivity.ActivityType]? = nil) -> Bool {
                    
//        guard let topViewController = getTopViewController()
        guard let topViewController = UIApplication.shared.topViewController()
        else {
            MyLog.debug("wdh ExportStuff.share unable to get rootViewController")
            return false
        }
                
        let vc = UIActivityViewController(
            activityItems: items,
            applicationActivities: nil //[] //nil
        )
        vc.excludedActivityTypes = excludedActivityTypes
        vc.popoverPresentationController?.sourceView = topViewController.view
        topViewController.present(vc, animated: true) // Error "Attempt to present UIActivityViewController ... which is already presenting"
        MyLog.debug("ExportStuff.share() Done Exporting")
        return true
    }


}

// Optional Class for setting a Subject Line to share with an email app
// This must implement the UIActivityItemSource protocol
// NOTE: THIS CLASS IS NOT WORKING RIGHT YET WITH SOME EMAIL APPS like Google and yahoo
// the usage should be to construct this with your subject line and pass it in the array of items to share
// To continue debugging, google the error messages generated when exporting to Yahoo email
// https://www.hackingwithswift.com/articles/118/uiactivityviewcontroller-by-example
class SubjectLine: NSObject, UIActivityItemSource {
    var mSubjectLine: String
    
    init(_ subjectLine: String) {
        mSubjectLine = subjectLine
    }
    
    // This is used only so UIKit knows the type of data you want to share.
    // This func must return a dummy sample of the same data type that the second func returns
    func activityViewControllerPlaceholderItem(_ activityViewController: UIActivityViewController) -> Any {
        return "wdh2 Dummy String Sample"
    }
    
    // NOTE: You must make the activityViewControllerPlaceholderItem
    // func return a dummy value of the same type that this func returns
    // The Value returned by this func WILL BE SHARED
    func activityViewController(_ activityViewController: UIActivityViewController, itemForActivityType activityType: UIActivity.ActivityType?) -> Any? {
        return "" //Return an empty string so dummy text isn't shared
    }
    
    // Return the subject line
    func activityViewController(_ activityViewController: UIActivityViewController, subjectForActivityType activityType: UIActivity.ActivityType?) -> String {
        return mSubjectLine
    }
}


//
// NOTE: This Extension is used to get the RootViewController
// needed in the code above to share/export to other apps
//
// Code From Here:
//   https://stackoverflow.com/questions/26667009/get-top-most-uiviewcontroller/26667122#26667122
//
extension UIApplication {
    func topViewController() -> UIViewController? {
        var topViewController: UIViewController? = nil
        if #available(iOS 13, *) {
            for scene in connectedScenes {
                if let windowScene = scene as? UIWindowScene {
                    for window in windowScene.windows {
                        if window.isKeyWindow {
                            topViewController = window.rootViewController
                        }
                    }
                }
            }
        } else {
            topViewController = keyWindow?.rootViewController
        }
        while true {
            if let presented = topViewController?.presentedViewController {
                topViewController = presented
            } else if let navController = topViewController as? UINavigationController {
                topViewController = navController.topViewController
            } else if let tabBarController = topViewController as? UITabBarController {
                topViewController = tabBarController.selectedViewController
            } else {
                // Handle any other third party container in `else if` if required
                break
            }
        }
        return topViewController
    }
}


//
// NOTE: This Extension is used to get the RootViewController
// needed in the code above to share with other apps
//
//extension UIApplication {
//  var currentKeyWindow: UIWindow? {
//    UIApplication.shared.connectedScenes
//      .filter { $0.activationState == .foregroundActive }
//      .map { $0 as? UIWindowScene }
//      .compactMap { $0 }
//      .first?.windows
//      .filter { $0.isKeyWindow }
//      .first
//  }
//
//  var rootViewController: UIViewController? {
//    currentKeyWindow?.rootViewController
//  }
//}

