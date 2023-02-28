//
//  Reactive+Extensions.swift
//  AppleLogin_Demo
//
//  Created by jbjeong on 2023/02/28.
//

import UIKit
import AuthenticationServices
import RxSwift
import RxCocoa

@available(iOS 13.0, *)
extension Reactive where Base: ASAuthorizationAppleIDButton {
    public func touchGesture() -> ControlEvent<()> {
        return controlEvent(.touchUpInside)
    }
}
