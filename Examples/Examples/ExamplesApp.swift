//
//  ExamplesApp.swift
//  Examples
//
//  Created by Guilherme Souza on 22/12/22.
//

import GoogleSignIn
import Supabase
import SwiftUI

class AppDelegate: UIResponder, UIApplicationDelegate {
  func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
  ) -> Bool {
    supabase.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
    supabase.application(app, open: url, options: options)
  }

  func application(_: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options _: UIScene.ConnectionOptions) -> UISceneConfiguration {
    let configuration = UISceneConfiguration(name: nil, sessionRole: connectingSceneSession.role)
    configuration.delegateClass = SceneDelegate.self
    return configuration
  }
}

class SceneDelegate: UIResponder, UISceneDelegate {
  func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
    supabase.scene(scene, openURLContexts: URLContexts)
  }
}

@main
struct ExamplesApp: App {
  @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

  var body: some Scene {
    WindowGroup {
      RootView()
        .environment(AuthController())
    }
  }
}

let supabase = SupabaseClient(
  supabaseURL: Secrets.supabaseURL,
  supabaseKey: Secrets.supabaseAnonKey,
  options: .init(
    auth: .init(redirectToURL: Constants.redirectToURL),
    global: .init(
      logger: ConsoleLogger()
    )
  )
)

struct ConsoleLogger: SupabaseLogger {
  func log(message: SupabaseLogMessage) {
    print(message)
  }
}
