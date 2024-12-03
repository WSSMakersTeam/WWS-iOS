//
//  MyPageViewModel.swift
//  WSSiOS
//
//  Created by 신지원 on 7/9/24.
//

import Foundation

import RxSwift
import RxCocoa

final class MyPageViewModel: ViewModelType {
    
    // MARK: - Properties
    
    let profileId: Int
    
    private let userRepository: UserRepository
    
    private let disposeBag = DisposeBag()
    var height: Double = 0.0
    let bindKeywordRelay = BehaviorRelay<[Keyword]>(value: [])
    
    let isMyPageRelay = BehaviorRelay<Bool>(value: true)
    let isProfilePrivateRelay = BehaviorRelay<(Bool, String)>(value: (true, ""))
    
    let profileDataRelay = BehaviorRelay<MyProfileResult>(value: MyProfileResult(nickname: "", intro: "", avatarImage: "", genrePreferences: []))
    let updateNavigationEnabledRelay = BehaviorRelay<(Bool, String)>(value: (false, ""))
    
    let pushToEditViewControllerRelay = PublishRelay<MyProfileResult>()
    let pushToSettingViewControllerRelay = PublishRelay<Void>()
    let popViewControllerRelay = PublishRelay<Void>()
    let pushToLibraryViewControllerRelay = PublishRelay<Int>()
    let pushToFeedDetailViewControllerRelay = PublishRelay<(Int, MyProfileResult)>()
    
    let bindAttractivePointsDataRelay = BehaviorRelay<[String]>(value: [])
    let bindKeywordCellRelay = BehaviorRelay<[Keyword]>(value: [])
    let bindGenreDataRelay = BehaviorRelay<UserGenrePreferences>(value: UserGenrePreferences(genrePreferences: []))
    let bindInventoryDataRelay = BehaviorRelay<UserNovelStatus>(value: UserNovelStatus(interestNovelCount: 0, watchingNovelCount: 0, watchedNovelCount: 0, quitNovelCount: 0))
    let isExistPrefernecesRelay = PublishRelay<Bool>()
    
    let bindFeedDataRelay = BehaviorRelay<[FeedCellData]>(value: [])
    let isEmptyFeedRelay = PublishRelay<Void>()
    let showFeedDetailButtonRelay = PublishRelay<Bool>()
    
    let showGenreOtherViewRelay = BehaviorRelay<Bool>(value: false)
    let showToastViewRelay = PublishRelay<Void>()
    let stickyHeaderActionRelay = BehaviorRelay<Bool>(value: true)
    let showUnknownUserAlertRelay = PublishRelay<Void>()
    
    let updateButtonWithLibraryViewRelay = BehaviorRelay<Bool>(value: true)
    let updateFeedTableViewHeightRelay = PublishRelay<CGFloat>()
    let updateKeywordCollectionViewHeightRelay = PublishRelay<CGFloat>()
    
    // MARK: - Life Cycle
    
    init(userRepository: UserRepository, profileId: Int) {
        self.userRepository = userRepository
        if profileId == 0 {
            let userId = UserDefaults.standard.integer(forKey: StringLiterals.UserDefault.userId)
            self.profileId = userId
        } else {
            self.profileId = profileId
        }
    }
    
    struct Input {
        let isEntryTabbar: Observable<Bool>
        let viewWillAppearEvent: PublishRelay<Bool>
        
        let headerViewHeight: Driver<Double>
        let resizefeedTableViewHeight: Observable<CGSize?>
        let resizeKeywordCollectionViewHeight: Observable<CGSize?>
        let scrollOffset: Driver<CGPoint>
        
        let settingButtonDidTap: ControlEvent<Void>
        let dropdownButtonDidTap: Observable<String>
        let editButtonDidTap: ControlEvent<Void>
        let backButtonDidTap: ControlEvent<Void>
        
        let genrePreferenceButtonDidTap: Observable<Bool>
        let libraryButtonDidTap: Observable<Bool>
        let feedButtonDidTap: Observable<Bool>
        let inventoryButtonDidTap: ControlEvent<Void>
        let feedDetailButtonDidTap: ControlEvent<Void>
        
        let editProfileNotification: Observable<Notification>
    }
    
    struct Output {
        let isMyPage: BehaviorRelay<Bool>
        let isProfilePrivate: BehaviorRelay<(Bool, String)>
        let profileData: BehaviorRelay<MyProfileResult>
        let updateNavigationEnabled: BehaviorRelay<(Bool, String)>
        
        let pushToEditViewController: PublishRelay<MyProfileResult>
        let pushToSettingViewController: PublishRelay<Void>
        let popViewController: PublishRelay<Void>
        let pushToLibraryViewController: PublishRelay<Int>
        let pushToFeedDetailViewController: PublishRelay<(Int, MyProfileResult)>
        
        let bindAttractivePointsData: BehaviorRelay<[String]>
        let bindKeywordCell: BehaviorRelay<[Keyword]>
        let updateKeywordCollectionViewHeight: PublishRelay<CGFloat>
        let bindGenreData: BehaviorRelay<UserGenrePreferences>
        let bindInventoryData: BehaviorRelay<UserNovelStatus>

        let showGenreOtherView: BehaviorRelay<Bool>
        let isExistPreferneces: PublishRelay<Bool>
        
        let bindFeedData: BehaviorRelay<[FeedCellData]>
        let updateFeedTableViewHeight: PublishRelay<CGFloat>
        let isEmptyFeed: PublishRelay<Void>
        let showFeedDetailButton: PublishRelay<Bool>
        
        let showToastView: PublishRelay<Void>
        let stickyHeaderAction: BehaviorRelay<Bool>
        let updateButtonWithLibraryView: BehaviorRelay<Bool>
    }
    
    func transform(from input: Input, disposeBag: DisposeBag) -> Output {
        
        // 진입 경로 분기처리
        // 현재는 탭바로 진입할 때만 마이페이지!
        input.isEntryTabbar
            .subscribe(with: self, onNext: { owner, isMyPage in
                owner.isMyPageRelay.accept(isMyPage)
            })
            .disposed(by: disposeBag)
        
        // viewWillAppear 이벤트 처리
        input.viewWillAppearEvent
            .flatMapLatest { [unowned self] _ in
                Observable.zip(
                    self.updateHeaderView(isMyPage: self.isMyPageRelay.value),
                    self.updateMyPageData(),
                    self.handleKeywordCollectionViewHeight(resizeKeywordCollectionViewHeight: input.resizeKeywordCollectionViewHeight),
                    self.handleFeedTableViewHeight(resizeFeedTableViewHeight: input.resizefeedTableViewHeight)
                )
            }
            .subscribe()
            .disposed(by: disposeBag)
        
        input.viewWillAppearEvent
            .flatMapLatest { [unowned self] _ in
                self.updateHeaderView(isMyPage: self.isMyPageRelay.value)
                    .flatMapLatest { [unowned self] _ in
                        let isPrivate = self.isProfilePrivateRelay.value.0
                        if isPrivate {
                            return Observable<Void>.empty()
                        } else {
                            return self.updateMyPageData()
                        }
                    }
            }
            .subscribe()
            .disposed(by: disposeBag)
        
        // 스티키 헤더 처리
        input.headerViewHeight
            .asObservable()
            .bind(with: self, onNext: { owner, height in
                owner.height = height
            })
            .disposed(by: disposeBag)
        
        input.scrollOffset
            .asObservable()
            .map{ $0.y }
            .subscribe(with: self, onNext: { owner, scrollHeight in
                let navigationText = owner.isMyPageRelay.value ? StringLiterals.Navigation.Title.myPage : owner.profileDataRelay.value.nickname
                if (scrollHeight > owner.height) {
                    self.updateNavigationEnabledRelay.accept((true, navigationText))
                } else {
                    self.updateNavigationEnabledRelay.accept((false, navigationText))
                }
            })
            .disposed(by: disposeBag)
        
        // 버튼 클릭 이벤트 처리
        input.genrePreferenceButtonDidTap
            .subscribe(with: self, onNext: { owner, _ in
                let currentState = owner.showGenreOtherViewRelay.value
                owner.showGenreOtherViewRelay.accept(!currentState)
            })
            .disposed(by: disposeBag)
        
        input.settingButtonDidTap
            .bind(to: pushToSettingViewControllerRelay)
            .disposed(by: disposeBag)
        
        input.editButtonDidTap
            .map { self.profileDataRelay.value }
            .bind(to: pushToEditViewControllerRelay)
            .disposed(by: disposeBag)
        
        input.backButtonDidTap
            .bind(to: popViewControllerRelay)
            .disposed(by: disposeBag)
        
        input.libraryButtonDidTap
            .subscribe(with: self, onNext: { owner, _ in
                owner.stickyHeaderActionRelay.accept(true)
                owner.updateButtonWithLibraryViewRelay.accept(true)
            })
            .disposed(by: disposeBag)
        
        input.feedButtonDidTap
            .subscribe(with: self, onNext: { owner, _ in
                owner.stickyHeaderActionRelay.accept(false)
                owner.updateButtonWithLibraryViewRelay.accept(false)
            })
            .disposed(by: disposeBag)
        
        input.dropdownButtonDidTap
            .filter { $0 == StringLiterals.MyPage.BlockUser.toastText }
            .flatMapLatest { [unowned self] _ in
                self.postBlockUser(userId: self.profileId)
            }
            .subscribe(with: self, onNext: { owner, _ in
                let nickname = owner.profileDataRelay.value.nickname
                NotificationCenter.default.post(name: NSNotification.Name("BlockUser"), object: nickname)
                owner.popViewControllerRelay.accept(())
            })
            .disposed(by: disposeBag)
        
        self.showUnknownUserAlertRelay
            .subscribe(with: self, onNext: { owner, _ in
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    NotificationCenter.default.post(name: NSNotification.Name("UnknownUser"), object: nil)
                }
                self.popViewControllerRelay.accept(())
            })
            .disposed(by: disposeBag)
        
        input.inventoryButtonDidTap
            .bind(with: self, onNext: { owner, _ in
                self.pushToLibraryViewControllerRelay.accept(owner.profileId)
            })
            .disposed(by: disposeBag)
        
        input.feedDetailButtonDidTap
            .bind(with: self, onNext: { owner, _ in
                self.pushToFeedDetailViewControllerRelay.accept((owner.profileId, owner.profileDataRelay.value))
            })
            .disposed(by: disposeBag)
        
        input.editProfileNotification
            .bind(with: self, onNext: { owner, _ in
                self.showToastViewRelay.accept(())
            })
            .disposed(by: disposeBag)
        
        return Output(
            isMyPage: self.isMyPageRelay,
            isProfilePrivate: self.isProfilePrivateRelay,
            profileData: self.profileDataRelay,
            updateNavigationEnabled: self.updateNavigationEnabledRelay,
            
            pushToEditViewController: self.pushToEditViewControllerRelay,
            pushToSettingViewController: self.pushToSettingViewControllerRelay,
            popViewController: self.popViewControllerRelay,
            pushToLibraryViewController: self.pushToLibraryViewControllerRelay,
            pushToFeedDetailViewController: self.pushToFeedDetailViewControllerRelay,
            
            bindAttractivePointsData: self.bindAttractivePointsDataRelay,
            bindKeywordCell: self.bindKeywordRelay,
            updateKeywordCollectionViewHeight: self.updateKeywordCollectionViewHeightRelay,
            bindGenreData: self.bindGenreDataRelay,
            bindInventoryData: self.bindInventoryDataRelay,
            showGenreOtherView: self.showGenreOtherViewRelay,
            isExistPreferneces: self.isExistPrefernecesRelay,
            
            bindFeedData: self.bindFeedDataRelay,
            updateFeedTableViewHeight: self.updateFeedTableViewHeightRelay,
            isEmptyFeed: self.isEmptyFeedRelay,
            showFeedDetailButton: self.showFeedDetailButtonRelay,
            
            showToastView: self.showToastViewRelay,
            stickyHeaderAction: self.stickyHeaderActionRelay,
            updateButtonWithLibraryView: self.updateButtonWithLibraryViewRelay
        )
    }
    
    // MARK: - Custom Method
    
    private func isUnknownUserError(_ error: Error) -> Bool {
        if let networkError = error as? RxCocoaURLError {
            switch networkError {
            case .httpRequestFailed(_, let data):
                if let data = data {
                    do {
                        let errorInfo = try JSONDecoder().decode(ServerErrorResponse.self, from: data)
                        return errorInfo.code == "USER-018"
                    } catch {}
                }
                
            default:
                return false
            }
        }
        return false
    }
    
    private func updateHeaderView(isMyPage: Bool) -> Observable<Void> {
        let profileDataObservable: Observable<MyProfileResult>
        
        if isMyPage {
            return self.getProfileData()
                .do(onNext: { profileData in
                    self.profileDataRelay.accept(profileData)
                    self.isProfilePrivateRelay.accept((false, profileData.nickname))
                })
                .map { _ in }
        } else {
            return self.getOtherProfileData(userId: self.profileId)
                .do(onNext: { profileData in
                    let data = MyProfileResult(
                        nickname: profileData.nickname,
                        intro: profileData.intro,
                        avatarImage: profileData.avatarImage,
                        genrePreferences: profileData.genrePreferences
                    )
                    self.profileDataRelay.accept(data)
                    self.isProfilePrivateRelay.accept((!profileData.isProfilePublic, profileData.nickname))
                })
                .map { _ in }
                .catch { [unowned self] error in
                    if self.isUnknownUserError(error) {
                        self.showUnknownUserAlertRelay.accept(())
                    }
                    return .empty()
                }
        }
    }
    
    private func updateMyPageData() -> Observable<Void> {
        return Observable.zip(
            self.getNovelPreferenceData(userId: self.profileId)
                .do(onNext: { data in
                    let keywords = data.keywords ?? []
                    if data.attractivePoints == [] && keywords.isEmpty {
                        self.isExistPrefernecesRelay.accept(false)
                    } else {
                        self.bindAttractivePointsDataRelay.accept(data.attractivePoints ?? [])
                        self.bindKeywordRelay.accept(keywords)
                    }
                }),
            
            self.getGenrePreferenceData(userId: self.profileId)
                .do(onNext: { data in
                    if !data.genrePreferences.isEmpty {
                        self.bindGenreDataRelay.accept(data)
                    }
                }),
            
            self.getInventoryData(userId: self.profileId)
                .do(onNext: { data in
                    self.bindInventoryDataRelay.accept(data)
                }),
            
            self.getUserFeed(userId: self.profileId, lastFeedId: 0, size: 6)
                .map { feedResult -> [FeedCellData] in
                    feedResult.feeds.map { feed in
                        FeedCellData(
                            feed: feed,
                            avatarImage: self.profileDataRelay.value.avatarImage,
                            nickname: self.profileDataRelay.value.nickname
                        )
                    }
                }
                .do(onNext: { feedCellData in
                    let hasMoreThanFive = feedCellData.count > 5
                    self.showFeedDetailButtonRelay.accept(hasMoreThanFive)
                })
                .map { feedCellData in
                    Array(feedCellData.suffix(5))
                }
                .do(onNext: { feedData in
                    if feedData.isEmpty {
                        self.isEmptyFeedRelay.accept(())
                    } else {
                        self.bindFeedDataRelay.accept(feedData)
                    }
                })
        )
        .map { _ in }
    }
    
    private func handleFeedTableViewHeight(resizeFeedTableViewHeight: Observable<CGSize?>) -> Observable<CGFloat> {
        return resizeFeedTableViewHeight
            .map { $0?.height ?? 0 }
            .do(onNext: { [weak self] height in
                self?.updateFeedTableViewHeightRelay.accept(height)
            })
    }
    
    private func handleKeywordCollectionViewHeight(resizeKeywordCollectionViewHeight: Observable<CGSize?>) -> Observable<CGFloat> {
        return resizeKeywordCollectionViewHeight
            .map { $0?.height ?? 0 }
            .do(onNext: { [weak self] height in
                self?.updateKeywordCollectionViewHeightRelay.accept(height)
            })
    }
    
    // MARK: - API
    
    private func getProfileData() -> Observable<MyProfileResult> {
        return userRepository.getMyProfileData()
            .observe(on: MainScheduler.instance)
    }
    
    private func getOtherProfileData(userId: Int) -> Observable<OtherProfileResult> {
        return userRepository.getOtherProfile(userId: userId)
            .asObservable()
    }
    
    private func getNovelPreferenceData(userId: Int) -> Observable<UserNovelPreferences> {
        return userRepository.getUserNovelPreferences(userId: userId)
            .asObservable()
    }
    
    private func getGenrePreferenceData(userId: Int) -> Observable<UserGenrePreferences> {
        return userRepository.getUserGenrePreferences(userId: userId)
            .asObservable()
    }
    
    private func getInventoryData(userId: Int) -> Observable<UserNovelStatus> {
        return userRepository.getUserNovelStatus(userId: userId)
            .asObservable()
    }
    
    private func postBlockUser(userId: Int) -> Observable<Void> {
        return userRepository.postBlockUser(userId: userId)
            .asObservable()
    }
    
    private func getUserFeed(userId: Int, lastFeedId: Int, size: Int) -> Observable<MyFeedResult> {
        return userRepository.getUserFeed(userId: userId, lastFeedId: lastFeedId, size: size)
            .asObservable()
    }
}
