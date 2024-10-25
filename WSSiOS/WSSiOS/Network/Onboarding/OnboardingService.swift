//
//  OnboardingService.swift
//  WSSiOS
//
//  Created by YunhakLee on 10/6/24.
//

import Foundation

import RxSwift

protocol OnboardingService {
    func getNicknameisValid(_ nickname: String) -> Single<OnboardingResult>
    func postUserProfile(userInfoResult: UserInfoResult) -> Single<Void>
}

final class DefaultOnboardingService: NSObject, Networking {
    private var urlSession: URLSession = URLSession(configuration: URLSessionConfiguration.default,
                                                    delegate: nil,
                                                    delegateQueue: nil)
}

extension DefaultOnboardingService: OnboardingService {
    func getNicknameisValid(_ nickname: String) -> Single<OnboardingResult> {
        let nicknameisValidQueryItems: [URLQueryItem] = [
            URLQueryItem(name: "nickname", value: String(describing: nickname))
        ]
        
        return Single.create { single in
            do {
                let request = try self.makeHTTPRequest(
                    method: .get,
                    path: URLs.Onboarding.nicknameCheck,
                    queryItems: nicknameisValidQueryItems,
                    headers: APIConstants.testTokenHeader,
                    body: nil
                )
                
                NetworkLogger.log(request: request)
                
                let task = self.urlSession.dataTask(with: request) { data, response, error in
                    if let error = error {
                        single(.failure(error))
                        return
                    }
                    
                    guard let response = response as? HTTPURLResponse else {
                        single(.failure(ServiceError.unknownError))
                        return
                    }
                    
                    guard let data = data else {
                        single(.failure(ServiceError.emptyDataError))
                        return
                    }
                    
                    if (200...299).contains(response.statusCode) {
                        do {
                            let result = try self.decode(data: data, to: OnboardingResult.self)
                            single(.success(result))
                        } catch {
                            single(.failure(ServiceError.responseDecodingError))
                        }
                    } else {
                        let result = try? self.decode(data: data, to: ServerErrorResponse.self)
                        single(.failure(ServiceError(statusCode: response.statusCode, errorResponse: result)))
                    }
                }
                task.resume()
                return Disposables.create {
                    task.cancel()
                }
            } catch {
                single(.failure(error))
            }
            
            return Disposables.create()
        }
    }

    func postUserProfile(userInfoResult: UserInfoResult) -> Single<Void> {
        guard let userInfo = try? JSONEncoder().encode(userInfoResult) else {
            return Single.error(NetworkServiceError.invalidRequestError)
        }
        print(userInfo)
        
        return Single.create { single in
            do {
                let request = try self.makeHTTPRequest(
                    method: .post,
                    path: URLs.Onboarding.postProfile,
                    headers: APIConstants.testTokenHeader,
                    body: userInfo
                )
                
                NetworkLogger.log(request: request)
                
                let task = self.urlSession.dataTask(with: request) { data, response, error in
                    if let error = error {
                        single(.failure(error))
                        return
                    }
                    
                    guard let response = response as? HTTPURLResponse else {
                        single(.failure(ServiceError.unknownError))
                        return
                    }
                    
                    if (200...299).contains(response.statusCode) {
                        single(.success(()))
                    } else {
                        if let data,
                           let result = try? self.decode(data: data, to: ServerErrorResponse.self) {
                            single(.failure(ServiceError(statusCode: response.statusCode, errorResponse: result)))
                        }
                    }
                }
                task.resume()
                return Disposables.create {
                    task.cancel()
                }
            } catch {
                single(.failure(error))
            }
            
            return Disposables.create()
        }
    }
}
