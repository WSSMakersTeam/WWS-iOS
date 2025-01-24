//
//  MyPageFeedViewModel.swift
//  WSSiOS
//
//  Created by 신지원 on 1/22/25.
//

import Foundation

import RxSwift
import RxCocoa

final class MyPageFeedViewModel: ViewModelType {
    
    // MARK: - Properties
    
    private let userRepository: UserRepository
    private let disposeBag = DisposeBag()
    
    /// 초기값은 내 프로필로 설정
    private let isMyPage = BehaviorRelay<Bool>(value: true)
    private var profileId: Int
    private let profileDataRelay = BehaviorRelay<MyProfileResult>(value: MyProfileResult(nickname: "",
                                                                                         intro: "",
                                                                                         avatarImage: "",
                                                                                         genrePreferences: []))
    
    private let bindFeedDataRelay = BehaviorRelay<[FeedCellData]>(value: [])
    private let isEmptyFeedRelay = BehaviorRelay<Bool>(value: true)
    private let showFeedDetailButtonRelay = BehaviorRelay<Bool>(value: false)
    
    private let pushToMyPageFeedDetailViewControllerRelay = PublishSubject<(Int, MyProfileResult)>()
    private let pushToFeedDetailViewController = PublishSubject<Int>()
    private let pushToNovelDetailViewController = PublishSubject<Int>()
    
    private let updateFeedTableViewHeightRelay = PublishRelay<CGFloat>()
    
    // MARK: - Life Cycle
    
    init(userRepository: UserRepository, profileId: Int) {
        self.userRepository = userRepository
        self.profileId = profileId
    }
    
    struct Input {
        let viewWillAppearEvent: BehaviorRelay<Void>
        let profileData: BehaviorRelay<MyProfileResult>
        let feedDetailButtonDidTap: ControlEvent<Void>
        let feedTableViewItemSelected: Observable<IndexPath>
        let feedConnectedNovelViewDidTap: Observable<Int>
        let resizefeedTableViewHeight: Observable<CGSize?>
    }
    
    struct Output {
        let bindFeedData: BehaviorRelay<[FeedCellData]>
        let isEmptyFeed: BehaviorRelay<Bool>
        let showFeedDetailButton: BehaviorRelay<Bool>
        
        let pushToMyPageFeedDetailViewController: Observable<(Int, MyProfileResult)>
        let pushToFeedDetailViewController: Observable<Int>
        let pushToNovelDetailViewController: Observable<Int>
        
        let updateFeedTableViewHeight: PublishRelay<CGFloat>
    }
    
    func transform(from input: Input, disposeBag: DisposeBag) -> Output {
        input.viewWillAppearEvent
            .flatMapLatest { [weak self] _ -> Observable<Void> in
                guard let self = self else { return .empty() }
                
                if self.profileId == 0 {
                    let myUserId = UserDefaults.standard.integer(forKey: StringLiterals.UserDefault.userId)
                    if myUserId == 0 {
                        return self.getUserMeData()
                            .do(onNext: { userData in
                                self.profileId = userData.userId
                                UserDefaults.standard.setValue(userData.userId, forKey: StringLiterals.UserDefault.userId)
                            })
                            .map{ _ in }
                    } else {
                        self.profileId = myUserId
                    }
                }
                
                return self.updateMyPageFeedData()
                
                .flatMap { _ -> Observable<Void> in
                    self.handleFeedTableViewHeight(resizeFeedTableViewHeight: input.resizefeedTableViewHeight)
                        .map { _ in () }
                }
            }
            .subscribe()
            .disposed(by: disposeBag)
        
        input.profileData
            .bind(with: self, onNext: { owner, data in
                owner.profileDataRelay.accept(data)
            })
            .disposed(by: disposeBag)
        
        input.feedDetailButtonDidTap
            .bind(with: self, onNext: { owner, _ in
                self.pushToMyPageFeedDetailViewControllerRelay.onNext((owner.profileId, owner.profileDataRelay.value))
            })
            .disposed(by: disposeBag)
        
        input.feedTableViewItemSelected
            .bind(with: self, onNext: { owner, indexPath in
                let feedId = self.bindFeedDataRelay.value[indexPath.row].feed.feedId
                self.pushToFeedDetailViewController.onNext(feedId)
            })
            .disposed(by: disposeBag)
        
        input.feedConnectedNovelViewDidTap
            .bind(with: self, onNext: { owner, novelId in
                self.pushToNovelDetailViewController.onNext(novelId)
            })
            .disposed(by: disposeBag)
        
        return Output(bindFeedData: bindFeedDataRelay,
                      isEmptyFeed: isEmptyFeedRelay,
                      showFeedDetailButton: showFeedDetailButtonRelay,
                      pushToMyPageFeedDetailViewController: pushToMyPageFeedDetailViewControllerRelay,
                      pushToFeedDetailViewController: pushToFeedDetailViewController,
                      pushToNovelDetailViewController: pushToNovelDetailViewController,
                      updateFeedTableViewHeight: updateFeedTableViewHeightRelay
        )
    }
    
    // MARK: - Custom Method

    private func updateMyPageFeedData() -> Observable<Void> {
        return getUserFeed(userId: self.profileId, lastFeedId: 0, size: 6)
            .map { feedResult -> [FeedCellData] in
                feedResult.feeds.map { feed in
                    FeedCellData(
                        feed: feed,
                        avatarImage: self.profileDataRelay.value.avatarImage,
                        nickname: self.profileDataRelay.value.nickname
                    )
                }
            }
            .do(onNext: { [weak self] feedCellData in
                guard let self else { return }
                if feedCellData.isEmpty {
                    self.isEmptyFeedRelay.accept(feedCellData.isEmpty)
                    self.showFeedDetailButtonRelay.accept(!feedCellData.isEmpty)
                } else {
                    self.isEmptyFeedRelay.accept(false)
                    self.bindFeedDataRelay.accept(Array(feedCellData.prefix(5)))
                    
                    /// 5개까지만 활동뷰에 바인딩
                    /// 5개를 초과할 경우 더보기 버튼 뜨게 함
                    let hasMoreThanFive = feedCellData.count > 5
                    self.showFeedDetailButtonRelay.accept(hasMoreThanFive)
                }
            })
            .catch { [weak self] error in
                self?.isEmptyFeedRelay.accept(false)
                return .just([])
            }
            .map { _ in Void() }
    }
    
    private func handleFeedTableViewHeight(resizeFeedTableViewHeight: Observable<CGSize?>) -> Observable<CGFloat> {
        return resizeFeedTableViewHeight
            .map { $0?.height ?? 0 }
            .do(onNext: { [weak self] height in
                self?.updateFeedTableViewHeightRelay.accept(height)
            })
    }
    
    // MARK: - API
    
    func getUserMeData() -> Observable<UserMeResult> {
        return userRepository.getUserMeData()
    }
    
    private func getUserFeed(userId: Int, lastFeedId: Int, size: Int) -> Observable<MyFeedResult> {
        return userRepository.getUserFeed(userId: userId, lastFeedId: lastFeedId, size: size)
    }
}
