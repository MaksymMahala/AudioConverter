//
//  GTMFetcherAuthorizationWrapper.swift
//  AudioConverter
//
//  Created by Max on 30.06.2025.
//

import Foundation
//import GTMSessionFetcher
//
//class GTMFetcherAuthorizationWrapper: NSObject, GTMFetcherAuthorizationProtocol {
//    var userEmail: String?
//
//    private let accessToken: String
//
//    init(accessToken: String) {
//        self.accessToken = accessToken
//    }
//
//    func authorizeRequest(_ request: NSMutableURLRequest?, delegate: Any?, didFinish selector: Selector?) {
//        request?.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
//
//        if let delegate = delegate as? NSObjectProtocol,
//           let selector = selector {
//            _ = delegate.perform(selector, with: request, with: nil)
//        }
//    }
//
//    func stopAuthorization() {}
//    func stopAuthorization(for request: URLRequest) {}
//    func isAuthorizingRequest(_ request: URLRequest) -> Bool { false }
//    func isAuthorizedRequest(_ request: URLRequest) -> Bool { true }
//}
