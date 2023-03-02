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
import WebKit

enum LoginStatus: String {
    case signIn
    case signOut
}

class ViewController: UIViewController {
    let disposeBag = DisposeBag()
    
    var status: LoginStatus = .signOut {
        didSet {
            appleLoginButton.isHidden = status == .signIn
            signOutButton.isHidden = status == .signOut
        }
    }
    
    let SNSLoginStackView = UIStackView()
    let appleLoginButton = ASAuthorizationAppleIDButton()
    let signOutButton = UIButton()
    
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
        signOutButton.setTitle("로그아웃", for: .normal)
        SNSLoginStackView.addArrangedSubview(signOutButton)
        
        if let userID = UserDefaults.standard.string(forKey: "userID") {
            status = .signIn
        } else {
            status = .signOut
        }
    }
    
    func setupControl() {
        signIn()
        signOut()
    }
    
    func signIn() {
        appleLoginButton.rx.touchGesture()
            .subscribe { [weak self] _ in
                let request = ASAuthorizationAppleIDProvider().createRequest()
                request.requestedScopes = [.fullName, .email]
                
                let controller = ASAuthorizationController(authorizationRequests: [request])
                controller.delegate = self
                controller.presentationContextProvider = self
                controller.performRequests()
            }.disposed(by: disposeBag)
    }
    
    func signOut() {
        signOutButton.rx.tap.subscribe { [weak self] _ in
            UserDefaults.standard.removeObject(forKey: "userID")
            KeyChain.delete()
            
            self?.status = .signOut
        }.disposed(by: disposeBag)
    }
}

extension ViewController: ASAuthorizationControllerDelegate {
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        guard let credential = authorization.credential as? ASAuthorizationAppleIDCredential, let code = credential.authorizationCode else {
            return
        }
        
        self.didSuccessAppleLogin(code, credential.user)
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        
    }
    
    private func didSuccessAppleLogin(_ code: Data, _ user: String) {
        let authrizationCodeStr = String(data: code, encoding: .utf8)
        let parameter = ["accessToken": authrizationCodeStr]
        
        UserDefaults.standard.set(user, forKey: "userID")
        KeyChain.create(userID: user)
        
        status = .signIn
    }
}

extension ViewController: ASAuthorizationControllerPresentationContextProviding {
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return self.view.window!
    }
}


class KeyChain {
    class func create(userID: String) {
        let query: NSDictionary = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrAccount: "userID",
            kSecValueData: userID.data(using: .utf8, allowLossyConversion: false) as Any
        ]
        
        SecItemDelete(query)
        
        let status = SecItemAdd(query, nil)
        assert(status == noErr, "아이디 저장 실패")

    }
    
    class func read() -> String? {
        let query: NSDictionary = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrAccount: "userID",
            kSecReturnData: kCFBooleanTrue as Any,
            kSecMatchLimit: kSecMatchLimitOne
        ]
        
        var dataTypeRef: AnyObject?
        let status = SecItemCopyMatching(query, &dataTypeRef)
        
        if status == errSecSuccess {
            let retrievedData = dataTypeRef as! Data
            let value = String(data: retrievedData, encoding: .utf8)
            return value
        } else {
            return ""
        }
    }
    
    class func delete() {
        let query: NSDictionary = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrAccount: "userID"
        ]
        
        let status = SecItemDelete(query)
        assert(status == noErr, "아이디 삭제 실패")
    }
}
