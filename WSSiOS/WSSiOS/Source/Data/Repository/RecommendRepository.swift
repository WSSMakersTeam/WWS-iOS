//
//  RecommendRepository.swift
//  WSSiOS
//
//  Created by 최서연 on 1/14/24.
//

import Foundation

import RxSwift

protocol RecommendRepository {
    func getTestTodayPopularNovels() -> Observable<[TodayPopularEntity]>
    func getTestInterestNovels() -> Observable<[InterestEntity]>
    func getTestTasteRecommendNovels() -> Observable<[TasteRecommendEntity]>
}

struct DefaultRecommendRepository: RecommendRepository {
    
    private let recommendService: RecommendService
    
    init(recommendService: RecommendService) {
        self.recommendService = recommendService
    }
    
    func getTestTodayPopularNovels() -> Observable<[TodayPopularEntity]> {
        return Observable.just([TodayPopularEntity(novelId: 1,
                                                   title: "1번작품입니다다라마바사아자차카타파하",
                                                   novelImage: "imgTest2",
                                                   avatarImage: "imgTest2",
                                                   nickname: "구리스",
                                                   feedContent: "상수리 나무 아래는 ㄹㅇ 아마 제 인생작이 될꺼 같네요. 소장본도 사려고요 근데 약간 여주가 답답한 스타일인데 그거를 살려버린다 우왕"),
                                TodayPopularEntity(novelId: 1,
                                                   title: "2번작품입니다다라마바사아자차카타파하",
                                                   novelImage: "imgTest2",
                                                   avatarImage: "imgTest2",
                                                   nickname: "구리스",
                                                   feedContent: "상수리 나무 아래는 ㄹㅇ 아마 제 인생작이 될꺼 같네요. 소장본도 사려고요 근데 약간 여주가 답답한 스타일인데 그거를 살려버린다 우왕"),
                                TodayPopularEntity(novelId: 1,
                                                   title: "상수리 나무 아래라구요오오오오오오오오오오오오오옷",
                                                   novelImage: "imgTest2",
                                                   avatarImage: "imgTest2",
                                                   nickname: "구리스",
                                                   feedContent: "상수리 나무 아래는 ㄹㅇ 아마 제 인생작이 될꺼 같네요. 소장본도 사려고요 근데 약간 여주가 답답한 스타일인데 그거를 살려버린다 우왕"),
                                TodayPopularEntity(novelId: 1,
                                                   title: "상수리 나무 아래라구요오오오오오오오오오오오오오옷",
                                                   novelImage: "imgTest2",
                                                   avatarImage: "imgTest2",
                                                   nickname: "구리스",
                                                   feedContent: "상수리 나무 아래는 ㄹㅇ 아마 제 인생작이 될꺼 같네요. 소장본도 사려고요 근데 약간 여주가 답답한 스타일인데 그거를 살려버린다 우왕"),
                                TodayPopularEntity(novelId: 1,
                                                   title: "상수리 나무 아래라구요오오오오오오오오오오오오오옷",
                                                   novelImage: "imgTest2",
                                                   avatarImage: "imgTest2",
                                                   nickname: "구리스",
                                                   feedContent: "상수리 나무 아래는 ㄹㅇ 아마 제 인생작이 될꺼 같네요. 소장본도 사려고요 근데 약간 여주가 답답한 스타일인데 그거를 살려버린다 우왕"),
                                TodayPopularEntity(novelId: 1,
                                                   title: "상수리 나무 아래라구요오오오오오오오오오오오오오옷",
                                                   novelImage: "imgTest2",
                                                   avatarImage: "imgTest2",
                                                   nickname: "구리스",
                                                   feedContent: "상수리 나무 아래는 ㄹㅇ 아마 제 인생작이 될꺼 같네요. 소장본도 사려고요 근데 약간 여주가 답답한 스타일인데 그거를 살려버린다 우왕")])
    }
    
    func getTestInterestNovels() -> Observable<[InterestEntity]> {
        return Observable.just([InterestEntity(novelId: 1, novelTitle: "신데렐라는 이 멧밭쥐가 데려갑니다", novelImage: "imgTest2", novelRating: 4.21, novelRatingCount: 1003, userNickname: "구리스", userAvatarImage: "imgTest2", userFeedContent: "주인공이 당연히 엘로디인 줄 알았는데.... 표지에 두명이 나온 이유가 있구나..... 당연히 주인공이 하나일거라고 생각하면 안 되는 거구나..ㅠㅠㅠ 신데렐라와 멧밭쥐 두 주인공의 넘 아름다운 이야기야 따흑 근데 세라 친어머니 죽고 재혼한 건데 계보에도 안 올릴 수가 있나... 외가가 망해 없어지기라도 했나?"),
                                InterestEntity(novelId: 1, novelTitle: "신데렐라는 이 멧밭쥐가 데려갑니다", novelImage: "imgTest2", novelRating: 4.21, novelRatingCount: 1003, userNickname: "구리스", userAvatarImage: "imgTest2", userFeedContent: "주인공이 당연히 엘로디인 줄 알았는데.... 표지에 두명이 나온 이유가 있구나..... 당연히 주인공이 하나일거라고 생각하면 안 되는 거구나..ㅠㅠㅠ 신데렐라와 멧밭쥐 두 주인공의 넘 아름다운 이야기야 따흑 근데 세라 친어머니 죽고 재혼한 건데 계보에도 안 올릴 수가 있나... 외가가 망해 없어지기라도 했나?"),
                                InterestEntity(novelId: 1, novelTitle: "신데렐라는 이 멧밭쥐가 데려갑니다", novelImage: "imgTest2", novelRating: 4.21, novelRatingCount: 1003, userNickname: "구리스", userAvatarImage: "imgTest2", userFeedContent: "주인공이 당연히 엘로디인 줄 알았는데.... 표지에 두명이 나온 이유가 있구나..... 당연히 주인공이 하나일거라고 생각하면 안 되는 거구나..ㅠㅠㅠ 신데렐라와 멧밭쥐 두 주인공의 넘 아름다운 이야기야 따흑 근데 세라 친어머니 죽고 재혼한 건데 계보에도 안 올릴 수가 있나... 외가가 망해 없어지기라도 했나?"),
                                InterestEntity(novelId: 1, novelTitle: "신데렐라는 이 멧밭쥐가 데려갑니다", novelImage: "imgTest2", novelRating: 4.21, novelRatingCount: 1003, userNickname: "구리스", userAvatarImage: "imgTest2", userFeedContent: "주인공이 당연히 엘로디인 줄 알았는데.... 표지에 두명이 나온 이유가 있구나..... 당연히 주인공이 하나일거라고 생각하면 안 되는 거구나..ㅠㅠㅠ 신데렐라와 멧밭쥐 두 주인공의 넘 아름다운 이야기야 따흑 근데 세라 친어머니 죽고 재혼한 건데 계보에도 안 올릴 수가 있나... 외가가 망해 없어지기라도 했나?"),
                                InterestEntity(novelId: 1, novelTitle: "신데렐라는 이 멧밭쥐가 데려갑니다", novelImage: "imgTest2", novelRating: 4.21, novelRatingCount: 1003, userNickname: "구리스", userAvatarImage: "imgTest2", userFeedContent: "주인공이 당연히 엘로디인 줄 알았는데.... 표지에 두명이 나온 이유가 있구나..... 당연히 주인공이 하나일거라고 생각하면 안 되는 거구나..ㅠㅠㅠ 신데렐라와 멧밭쥐 두 주인공의 넘 아름다운 이야기야 따흑 근데 세라 친어머니 죽고 재혼한 건데 계보에도 안 올릴 수가 있나... 외가가 망해 없어지기라도 했나?"),
                                InterestEntity(novelId: 1, novelTitle: "신데렐라는 이 멧밭쥐가 데려갑니다", novelImage: "imgTest2", novelRating: 4.21, novelRatingCount: 1003, userNickname: "구리스", userAvatarImage: "imgTest2", userFeedContent: "주인공이 당연히 엘로디인 줄 알았는데.... 표지에 두명이 나온 이유가 있구나..... 당연히 주인공이 하나일거라고 생각하면 안 되는 거구나..ㅠㅠㅠ 신데렐라와 멧밭쥐 두 주인공의 넘 아름다운 이야기야 따흑 근데 세라 친어머니 죽고 재혼한 건데 계보에도 안 올릴 수가 있나... 외가가 망해 없어지기라도 했나?")])
    }
    
    func getTestTasteRecommendNovels() -> Observable<[TasteRecommendEntity]> {
        return Observable.just([TasteRecommendEntity(novelId: 1, novelTitle: "여주인공의 오빠를 지키는 방법이라능", novelAuthor: "최서연, 구리스", novelImage: "imgTest2", novelLikeCount: 123, novelRating: 4.21, novelRatingCount: 456),
                                TasteRecommendEntity(novelId: 1, novelTitle: "여주인공의 오빠를 지키는 방법이라능", novelAuthor: "최서연, 구리스", novelImage: "imgTest2", novelLikeCount: 123, novelRating: 4.21, novelRatingCount: 456),
                                TasteRecommendEntity(novelId: 1, novelTitle: "여주인공의 오빠를 지키는 방법이라능", novelAuthor: "최서연, 구리스", novelImage: "imgTest2", novelLikeCount: 123, novelRating: 4.21, novelRatingCount: 456),
                                TasteRecommendEntity(novelId: 1, novelTitle: "여주인공의 오빠를 지키는 방법이라능", novelAuthor: "최서연, 구리스", novelImage: "imgTest2", novelLikeCount: 123, novelRating: 4.21, novelRatingCount: 456),
                                TasteRecommendEntity(novelId: 1, novelTitle: "여주인공의 오빠를 지키는 방법이라능", novelAuthor: "최서연, 구리스", novelImage: "imgTest2", novelLikeCount: 123, novelRating: 4.21, novelRatingCount: 456),
                                TasteRecommendEntity(novelId: 1, novelTitle: "여주인공의 오빠를 지키는 방법이라능", novelAuthor: "최서연, 구리스", novelImage: "imgTest2", novelLikeCount: 123, novelRating: 4.21, novelRatingCount: 456),
                                TasteRecommendEntity(novelId: 1, novelTitle: "여주인공의 오빠를 지키는 방법이라능", novelAuthor: "최서연, 구리스", novelImage: "imgTest2", novelLikeCount: 123, novelRating: 4.21, novelRatingCount: 456),
                                TasteRecommendEntity(novelId: 1, novelTitle: "여주인공의 오빠를 지키는 방법이라능", novelAuthor: "최서연, 구리스", novelImage: "imgTest2", novelLikeCount: 123, novelRating: 4.21, novelRatingCount: 456),
                                TasteRecommendEntity(novelId: 1, novelTitle: "여주인공의 오빠를 지키는 방법이라능", novelAuthor: "최서연, 구리스", novelImage: "imgTest2", novelLikeCount: 123, novelRating: 4.21, novelRatingCount: 456),
                                TasteRecommendEntity(novelId: 1, novelTitle: "여주인공의 오빠를 지키는 방법이라능", novelAuthor: "최서연, 구리스", novelImage: "imgTest2", novelLikeCount: 123, novelRating: 4.21, novelRatingCount: 456)])
    }
}
