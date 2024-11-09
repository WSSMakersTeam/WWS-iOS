//
//  AuthResult.swift
//  WSSiOS
//
//  Created by Hyowon Jeon on 11/2/24.
//

import Foundation

struct AppleLoginBody: Codable {
    let userIdentifier: String
    let email: String?
}

struct LoginResult: Codable {
    let Authorization: String
    let refreshToken: String
    let isRegister: Bool
}
