//
//  ViewController.swift
//  ios-base
//
//  Created by Rootstrap on 15/2/16.
//  Copyright © 2016 Rootstrap. All rights reserved.
//

import UIKit
import FBSDKLoginKit
import SwiftyJSON

class FirstViewController: UIViewController {
  // MARK: - Outlets
  @IBOutlet weak var facebookSign: UIButton!
  @IBOutlet weak var signIn: UIButton!
  @IBOutlet weak var signUp: UIButton!

  // MARK: Lifecycle
  override func viewDidLoad() {
    super.viewDidLoad()
    setUI()
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    navigationController?.setNavigationBarHidden(true, animated: true)
  }

  // MARK: - Setters
  func setUI() {
    facebookSign.setTitle("FACEBOOK CONNECT".localized, for: .normal)
    signIn.setTitle("LOG IN".localized, for: .normal)
    signUp.setTitle("Don’t have an account? Let’s create one".localized, for: .normal)

    [signIn, facebookSign].forEach({ $0?.setRoundBorders(22) })
  }

  // MARK: Actions
  @IBAction func facebookLogin() {
    UIApplication.showNetworkActivity()
    let fbLoginManager = FBSDKLoginManager()
    //Logs out before login, in case user changes facebook accounts
    fbLoginManager.logOut()
    fbLoginManager.logIn(withReadPermissions: ["email"], from: self) { (result, error) -> Void in
      guard error == nil else {
        self.showMessageError(title: "Oops..", errorMessage: "Something went wrong, try again later.")
        UIApplication.hideNetworkActivity()
        return
      }
      if result?.grantedPermissions == nil || result?.isCancelled ?? true {
        UIApplication.hideNetworkActivity()
      } else if !(result?.grantedPermissions.contains("email"))! {
        UIApplication.hideNetworkActivity()
        self.showMessageError(title: "Oops..", errorMessage: "It seems that you haven't allowed Facebook to provide your email address.")
      } else {
        self.facebookLoginCallback()
      }
    }
  }

  // MARK: Facebook callback methods
  func facebookLoginCallback() {
    //Optionally store params (facebook user data) locally.
    guard FBSDKAccessToken.current() != nil else {
      return
    }
    UserAPI.loginWithFacebook(token: FBSDKAccessToken.current().tokenString,
     success: { _ in
      UIApplication.hideNetworkActivity()
      self.performSegue(withIdentifier: "goToMainView", sender: nil)
    }, failure: { error in
      UIApplication.hideNetworkActivity()
      self.showMessageError(title: "Error", errorMessage: error._domain)
    })
  }
}
