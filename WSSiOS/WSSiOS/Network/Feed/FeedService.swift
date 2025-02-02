//
//  FeedService.swift
//  WSSiOS
//
//  Created by 신지원 on 6/3/24.
//

import Foundation

import RxSwift

protocol FeedService {
    func getFeedList(category: String,
                     lastFeedId: Int,
                     size: Int) -> Single<TotalFeed>
    func postFeed(relevantCategories: [String], feedContent: String, novelId: Int?, isSpoiler: Bool) -> Single<Void>
    func putFeed(feedId: Int, relevantCategories: [String], feedContent: String, novelId: Int?, isSpoiler: Bool) -> Single<Void>
}

final class DefaultFeedService: NSObject, Networking, FeedService {
    func makeFeedListQuery(category: String,
                           lastFeedId: Int,
                           size: Int) -> [URLQueryItem] {
        return [
            URLQueryItem(name: "category", value: category),
            URLQueryItem(name: "lastFeedId", value: String(describing: lastFeedId)),
            URLQueryItem(name: "size", value: String(describing: size)),
        ]
    }

    func getFeedList(category: String, lastFeedId: Int, size: Int) -> RxSwift.Single<TotalFeed> {
        do {
            let request = try makeHTTPRequest(method: .get,
                                              path: URLs.Feed.getFeeds,
                                              queryItems: makeFeedListQuery(category: category,
                                                                            lastFeedId: lastFeedId,
                                                                            size: size),
                                              headers: APIConstants.accessTokenHeader,
                                              body: nil)

            NetworkLogger.log(request: request)

            return tokenCheckURLSession.rx.data(request: request)
                .map { try self.decode(data: $0,
                                       to: TotalFeed.self) }
                .asSingle()

        } catch {
            return Single.error(error)
        }
    }
    
    func postFeed(relevantCategories: [String], feedContent: String, novelId: Int?, isSpoiler: Bool) -> Single<Void> {
        guard let feedContentData = try? JSONEncoder().encode(FeedContent(relevantCategories: relevantCategories, feedContent: feedContent, novelId: novelId, isSpoiler: isSpoiler)) else {
            return Single.error(NetworkServiceError.invalidRequestError)
        }
        
        do {
            let request = try makeHTTPRequest(method: .post,
                                              path: URLs.Feed.postFeed,
                                              headers: APIConstants.accessTokenHeader,
                                              body: feedContentData)
            
            NetworkLogger.log(request: request)
            
            return tokenCheckURLSession.rx.data(request: request)
                .map { _ in }
                .asSingle()
        } catch {
            return Single.error(error)
        }
    }
    
    func putFeed(feedId: Int, relevantCategories: [String], feedContent: String, novelId: Int?, isSpoiler: Bool) -> Single<Void> {
        guard let feedContentData = try? JSONEncoder().encode(FeedContent(relevantCategories: relevantCategories, feedContent: feedContent, novelId: novelId, isSpoiler: isSpoiler)) else {
            return Single.error(NetworkServiceError.invalidRequestError)
        }
        
        do {
            let request = try makeHTTPRequest(method: .put,
                                              path: URLs.Feed.putFeed(feedId: feedId),
                                              headers: APIConstants.accessTokenHeader,
                                              body: feedContentData)
            
            NetworkLogger.log(request: request)
            
            return tokenCheckURLSession.rx.data(request: request)
                .map { _ in }
                .asSingle()
        } catch {
            return Single.error(error)
        }
    }
}
