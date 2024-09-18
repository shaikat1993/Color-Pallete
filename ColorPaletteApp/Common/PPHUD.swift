//
//  PPHUD.swift
//  Common
//
//  Created by Shamsur Rahman on 29/5/22.
//  Copyright © 2022 Pathao Inc. All rights reserved.
//

import UIKit
import SVProgressHUD

func inMain(closure: @escaping () -> Void) {
    if !Thread.isMainThread {
        DispatchQueue.main.async {
            closure()
        }
    } else {
        closure()
    }
}

public struct PPHUD {
    public static let delay: TimeInterval = 2.0
    
    public static func show() {
        inMain {
             SVProgressHUD.show()
        }
    }
    
    public static func isVisible() -> Bool {
        SVProgressHUD.isVisible()
    }
    
    public static func show(withStatus status: String?) {
        inMain {
            SVProgressHUD.setMaximumDismissTimeInterval(delay)
            SVProgressHUD.show(withStatus: status)
        }
    }

    public static func dismiss() {
        inMain {
            SVProgressHUD.dismiss()
        }
    }

    public static func showSuccess(withStatus status: String) {
        inMain {
            SVProgressHUD.setMaximumDismissTimeInterval(delay)
            SVProgressHUD.showSuccess(withStatus: status)
        }
    }
    
    public static func showError(withStatus status: String) {
        inMain {
            SVProgressHUD.setMaximumDismissTimeInterval(delay)
            SVProgressHUD.showError(withStatus: status)
        }
    }
}
