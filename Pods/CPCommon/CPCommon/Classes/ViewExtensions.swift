//
//  ViewExtensions.swift
//  CPCommon
//
//  Created by Andrew on 13/06/2017.
//  Copyright © 2017 ControlPointLLP. All rights reserved.
//

import Foundation
import SVProgressHUD
import UIKit

extension SVProgressHUD {
     public class func showWithTimeout(_ timeout: Int = 5){
         SVProgressHUD.show()
         print("Starting progress dialog: \(Date())")
         DispatchQueue.main.asyncAfter(deadline: DispatchTime.from(seconds: timeout)){
            SVProgressHUD.dismiss()
            print("Ending progress dialog: \(Date())")
         }
     }
     
     public class func showTimeoutWithStatus(_ status: String, UsingTimeout timeout: Int = 5){
         SVProgressHUD.show(withStatus: status)
         print("Starting progress dialog: \(Date())")
         DispatchQueue.main.asyncAfter(deadline: DispatchTime.from(seconds: timeout)){
            SVProgressHUD.dismiss()
            print("Ending progress dialog: \(Date())")
         }
     }
}



extension UIViewController {
    public func dismissSelfAsDialogThen(
        Callback: @escaping () -> ()
        )
    {
        let s = self
        UIView.animate(
            withDuration: 0.2,
            animations:
            {
                s.view.alpha = 0.0
        },
            completion:
            { (_) in
                s.removeFromParentViewController()
                Callback()
        }
        )
    }
}


extension UIAlertController {
    public func addActions(_ actions: [UIAlertAction]) {
        actions.forEach({self.addAction($0)})
    }
}

extension UIAlertAction {
    public static func makeGenericCancelAction() -> UIAlertAction {
        return UIAlertAction.init(title: "cancel".localized, style: .cancel, handler: nil)
    }
    
    public static func makeGenericOkAction() -> UIAlertAction {
        return UIAlertAction.init(title: "ok".localized, style: .default, handler: nil)
    }
}
