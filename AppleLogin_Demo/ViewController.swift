//
//  ViewController.swift
//  AppleLogin_Demo
//
//  Created by jbjeong on 2023/02/27.
//

import UIKit
import AuthenticationServices
import RxSwift
import RxCocoa
import SnapKit

class ViewController: UIViewController {
    let disposeBag = DisposeBag()
    
    let SNSLoginStackView = UIStackView()
    let appleLoginButton = ASAuthorizationAppleIDButton()
    
    override func loadView() {
        super.loadView()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupLayout()
        setupControl()
    }
    
    func setupLayout() {
        self.view.addSubview(SNSLoginStackView)
        SNSLoginStackView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        SNSLoginStackView.addArrangedSubview(appleLoginButton)
        
        if let userID = UserDefaults.standard.string(forKey: "userID") {
            appleLoginButton.isHidden = !userID.isEmpty
        }
    }
    
    func setupControl() {
        appleLoginButton.rx.touchGesture()
            .subscribe(
                onNext: { [weak self] _ in
                    let appleIdProvider = ASAuthorizationAppleIDProvider()
                    let request = appleIdProvider.createRequest()
                    request.requestedScopes = [.fullName, .email]
                    
                    let controller = ASAuthorizationController(authorizationRequests: [request])
                    controller.delegate = self
                    controller.presentationContextProvider = self
                    controller.performRequests()
                }
            ).disposed(by: disposeBag)
    }
}

extension ViewController: ASAuthorizationControllerDelegate {
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        switch authorization.credential {
        case let appleIDCredential as ASAuthorizationAppleIDCredential:
            let userID = appleIDCredential.user
            let fullName = appleIDCredential.fullName
            let email = appleIDCredential.email
            
            UserDefaults.standard.set(userID, forKey: "userID")
            
            self.appleLoginButton.isHidden = true
        case let passwordCredential as ASPasswordCredential:
            let userName = passwordCredential.user
            let password = passwordCredential.password
            
            print("@@@@@@@ : ", userName, password)
        default:
            break
        }
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        
    }
}

extension ViewController: ASAuthorizationControllerPresentationContextProviding {
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return self.view.window!
    }
}
