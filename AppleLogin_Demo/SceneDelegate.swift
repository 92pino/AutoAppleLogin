//
//  SceneDelegate.swift
//  AppleLogin_Demo
//
//  Created by jbjeong on 2023/02/27.
//

import UIKit
import AuthenticationServices

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    var window: UIWindow?
    
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        let window = UIWindow(windowScene: windowScene)
        
        // view 계층도를 코드로 잡는다.
        let viewController = ViewController()
        let navigation = UINavigationController(rootViewController: viewController)
        
        // window의 rootViewController 를 내가 만든 첫화면Controller로 설정.
        window.rootViewController = navigation
        
        // window를 설정하고 makeKeyAndVisible 설정.
        self.window = window
        window.makeKeyAndVisible()
    }
    
    func getCredentialState() {
        print(KeyChain.read())
        
        if let userID = UserDefaults.standard.string(forKey: "userID"),
           !userID.isEmpty {
            let appleIDProvider = ASAuthorizationAppleIDProvider()
            appleIDProvider.getCredentialState(forUserID: userID) { state, error in
                switch state {
                case .revoked:
                    UserDefaults.standard.removeObject(forKey: "userID")
                    print("User Identifier 값이 앱과 연결 취소")
                case .authorized:
                    print("앱과 연동 성공")
                case .notFound:
                    print("User Identifier 값을 찾을수 없음")
                default:
                    break
                }
            }
        }
    }
    
    func sceneDidBecomeActive(_ scene: UIScene) {
        getCredentialState()
    }
}

