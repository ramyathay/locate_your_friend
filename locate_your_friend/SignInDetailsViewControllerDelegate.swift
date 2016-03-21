//
//  SignInDelegate.swift
//  friendFinder
//

import Foundation
import UIKit
protocol SignInDetailsViewControllerDelegate: class {
    func signInViewController(controller: MapViewController, didFinishAddingUser user: String)
}
