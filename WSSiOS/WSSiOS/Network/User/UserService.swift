//
//  UserService.swift
//  WSSiOS
//
//  Created by 최서연 on 1/14/24.
//

import Foundation

import RxSwift

protocol UserService {
    func getUserData() -> Single<UserResult>
    func patchUserName(userNickName: String) -> Single<Void>
    func getUserCharacterData() -> Single<UserCharacter>
}

final class DefaultUserService: NSObject, Networking {
    private let userNickNameQueryItems: [URLQueryItem] = [URLQueryItem(name: "userNickname",
                                                                       value: String(describing: 10))]
    private var urlSession: URLSession = URLSession(configuration: URLSessionConfiguration.default,
                                                    delegate: nil,
                                                    delegateQueue: nil)
}

extension DefaultUserService: UserService {
    func getUserData() -> RxSwift.Single<UserResult> {
        guard let request = try? makeHTTPRequest(method: .get,
                                                 path: URLs.User.getUserInfo,
                                                 headers: APIConstants.testTokenHeader,
                                                 body: nil)
                
        else {
            return .error(NetworkServiceError.invalidRequestError) 
        }
        
        NetworkLogger.log(request: request)
        
        return urlSession.rx.data(request: request)
            .map { try self.decode(data: $0,
                                   to: UserResult.self) }
            .asSingle()
    }
    
    func patchUserName(userNickName: String) -> RxSwift.Single<Void> {
        guard let userNickNameData = try? JSONEncoder().encode(UserNickNameResult(userNickname: userNickName)) 
                
        else {
            return .error(NetworkServiceError.invalidRequestError)
        }
        
        guard let request = try? makeHTTPRequest(method: .patch,
                                                 path: URLs.User.patchUserNickname,
                                                 queryItems: userNickNameQueryItems,
                                                 headers: APIConstants.testTokenHeader,
                                                 body: userNickNameData)
        else {
            return .error(NetworkServiceError.invalidRequestError)
        }
        
        NetworkLogger.log(request: request)
        
        return urlSession.rx.data(request: request)
            .map { _ in }
            .asSingle()
    }
    
    func getUserCharacterData() -> Single<UserCharacter> {
        guard let request = try? makeHTTPRequest(method: .get,
                                                 path: URLs.Avatar.getRepAvatar,
                                                 headers: APIConstants.testTokenHeader,
                                                 body: nil)
                
        else {
            return .error(NetworkServiceError.invalidRequestError)
        }
        
        NetworkLogger.log(request: request)
        
        return urlSession.rx.data(request: request)
            .map { try self.decode(data: $0,
                                   to: UserCharacter.self) }
            .asSingle()
    }
}


