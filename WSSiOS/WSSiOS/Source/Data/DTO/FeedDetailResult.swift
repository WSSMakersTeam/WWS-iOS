//
//  FeedDetailResult.swift
//  WSSiOS
//
//  Created by Seoyeon Choi on 6/24/24.
//

import Foundation

/// 소소피드 전체 및 단건 조회
struct Feed: Decodable {
    var userId: Int
    var userNickname: String
    var userProfileImage: String
    
    var feedId: Int
    
    var createdDate: String
    var feedContent: String
    var likeCount: Int
    var isLiked: Bool
    
    var commentCount: Int
    
    var novelId: Int?
    var novelTitle: String?
    var novelRatingCount: Int?
    var novelRating: Float?
    var genres: [String]
    
    var isSpoiler: Bool
    var isModified: Bool
    var isMyFeed: Bool
    
    enum CodingKeys: String, CodingKey {
        case userId, feedId, createdDate, feedContent, likeCount, isLiked, commentCount
        case novelId, novelRatingCount, novelRating, isSpoiler, isModified, isMyFeed
        case userNickname = "nickname"
        case userProfileImage = "avatarImage"
        case novelTitle = "title"
        case genres = "relevantCategories"
    }
}

/// 소소피드 댓글 전체 조회
struct FeedComments: Decodable {
    var commentsCount: Int
    var comments: [FeedComment]
}

struct FeedComment: Decodable {
    var userId: Int
    var userNickname: String
    var userProfileImage: String
    var commentId: Int
    var createdDate: String
    var commentContent: String
    var isModified: Bool
    var isMyComment: Bool
    var isSpoiler: Bool
    var isBlocked: Bool
    var isHidden: Bool
    
    enum CodingKeys: String, CodingKey {
        case userId, commentId, createdDate, commentContent, isModified, isMyComment, isSpoiler, isBlocked, isHidden
        case userNickname = "nickname"
        case userProfileImage = "avatarImage"
    }
}

struct FeedCommentContent: Codable {
    var commentContent: String
}
