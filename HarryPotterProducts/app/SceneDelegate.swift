//
//  SceneDelegate.swift
//  HarryPotterProducts
//

import UIKit
import SwiftUI

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession,
               options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = scene as? UIWindowScene
            else { return }

        // not adding UI elements if testing
        guard NSClassFromString("XCTestCase") == nil else { return }

        // `ListViewController` is our starting/main view controller
        // wrapped in a nav controller
        let listController = ListViewController()
        let navController = UINavigationController(rootViewController: listController)

        let window = UIWindow(windowScene: windowScene)
        window.rootViewController = navController
        self.window = window
        window.makeKeyAndVisible()
    }
}
