//
//  MyPageViewModel.swift
//  WSSiOS
//
//  Created by 신지원 on 7/9/24.
//

import UIKit

import RxSwift
import RxCocoa

final class MyPageViewModel: ViewModelType {
    
    // MARK: - Properties
    
    private var profileId: Int
    private let userRepository: UserRepository
    private let disposeBag = DisposeBag()
    
    private let isMyPageRelay = BehaviorRelay<Bool>(value: true)
    private let isProfilePrivateRelay = BehaviorRelay<(Bool, String)>(value: (false, ""))
    private let isExistPrefernecesRelay = PublishRelay<Bool>()
    private let profileDataRelay = BehaviorRelay<MyProfileResult>(value: MyProfileResult(nickname: "",
                                                                                         intro: "",
                                                                                         avatarImage: "",
                                                                                         genrePreferences: []))
    private let updateNavigationRelay = BehaviorRelay<(Bool, String)>(value: (false, ""))
    private let updateStickyHeaderRelay = BehaviorRelay<(Bool)>(value: (false))
    private let stickyHeaderAction = BehaviorRelay<Bool>(value: true)
    private var stickyHeaderHeight: CGFloat = 0
    
    private let pushToEditViewControllerRelay = PublishRelay<MyProfileResult>()
    private let popViewControllerRelay = PublishRelay<Void>()
    
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
        let viewWillAppearEvent: BehaviorRelay<Void>
        
        let headerViewHeight: Driver<Double>
        let scrollOffset: Driver<CGPoint>
        let dropdownButtonDidTap: Observable<String>
        let editButtonDidTap: ControlEvent<Void>
        let libraryButtonDidTap: Observable<Bool>
        let feedButtonDidTap: Observable<Bool>
    }
    
    struct Output {
        let isMyPage: BehaviorRelay<Bool>
        let isProfilePrivate: BehaviorRelay<(Bool, String)>
        let profileData: BehaviorRelay<MyProfileResult>
        let updateNavigationBar: BehaviorRelay<(Bool, String)>
        let updateStickyHeader: BehaviorRelay<(Bool)>
        let stickyHeaderAction: BehaviorRelay<Bool>
        
        let pushToEditViewController: PublishRelay<MyProfileResult>
        let popViewController: PublishRelay<Void>
    }
    
    func transform(from input: Input, disposeBag: DisposeBag) -> Output {
        
        /// 진입 경로 분기처리
        /// 현재는 탭바로 진입할 때만 마이페이지!
        input.isEntryTabbar
            .subscribe(with: self, onNext: { owner, isMyPage in
                owner.isMyPageRelay.accept(isMyPage)
            })
            .disposed(by: disposeBag)
        
        input.viewWillAppearEvent
            .flatMap { [weak self] _ -> Observable<Void> in
                guard let self = self else { return .empty() }
                return self.updateHeaderView(isMyPage: self.isMyPageRelay.value)
            }
            .subscribe()
            .disposed(by: disposeBag)
        
        /// 스티키 헤더 처리
        input.headerViewHeight
            .asObservable()
            .bind(with: self, onNext: { owner, height in
                owner.stickyHeaderHeight = height
            })
            .disposed(by: disposeBag)
        
        input.scrollOffset
            .asObservable()
            .map{ $0.y }
            .subscribe(with: self, onNext: { owner, scrollHeight in
                let navigationText = owner.isMyPageRelay.value ? StringLiterals.Navigation.Title.myPage : owner.profileDataRelay.value.nickname
                
                owner.updateNavigationRelay.accept((scrollHeight > 0, navigationText))
                owner.updateStickyHeaderRelay.accept(scrollHeight > owner.stickyHeaderHeight)
            })
            .disposed(by: disposeBag)
        
        input.editButtonDidTap
            .map { self.profileDataRelay.value }
            .bind(to: pushToEditViewControllerRelay)
            .disposed(by: disposeBag)
        
        Observable.merge(
            input.libraryButtonDidTap.map { _ in true },
            input.feedButtonDidTap.map { _ in false }
        )
        .flatMapLatest { isLibraryTap -> Observable<Void> in
            self.stickyHeaderAction.accept(isLibraryTap)
            return .just(())
        }
        .subscribe()
        .disposed(by: disposeBag)
        
        input.dropdownButtonDidTap
            .filter { $0 == StringLiterals.MyPage.BlockUser.toastText }
            .flatMapLatest { [weak self] _ -> Observable<Void> in
                guard let self else { return .empty() }
                return self.postBlockUser(userId: self.profileId)
            }
            .subscribe(with: self, onNext: { owner, _ in
                AmplitudeManager.shared.track(AmplitudeEvent.MyPage.otherBlock)
                let nickname = owner.profileDataRelay.value.nickname
                NotificationCenter.default.post(name: NSNotification.Name("BlockUser"), object: nickname)
                owner.popViewControllerRelay.accept(())
            })
            .disposed(by: disposeBag)
        
        return Output(
            isMyPage: self.isMyPageRelay,
            isProfilePrivate: self.isProfilePrivateRelay,
            profileData: self.profileDataRelay,
            updateNavigationBar: self.updateNavigationRelay,
            updateStickyHeader: self.updateStickyHeaderRelay,
            stickyHeaderAction: self.stickyHeaderAction,
            
            pushToEditViewController: self.pushToEditViewControllerRelay,
            popViewController: self.popViewControllerRelay
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
    
    /// 본인프로필과 타인프로필 분기처리
    /// 본인프로필일 때는 private 상태 false
    /// 타인프로필일 때 private 상태 분기처리
    /// 에러일 때 알 수 없음 프로필로 처리
    private func updateHeaderView(isMyPage: Bool) -> Observable<Void> {
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
                .catch { [weak self] error in
                    guard let self else { return .empty() }
                    
                    /// 현재 로직상 알 수 없는 유저 프로필을 확인하는 것은 불가능하지만
                    /// 서버에러에 대응하여 아래처럼 처리
                    if self.isUnknownUserError(error) {
                        let data = MyProfileResult(
                            nickname: "",
                            intro: "",
                            avatarImage: "",
                            genrePreferences: []
                        )
                        self.profileDataRelay.accept(data)
                        self.isProfilePrivateRelay.accept((false, ""))
                    }
                    return .empty()
                }
        }
    }
    
    // MARK: - API
    
    private func getProfileData() -> Observable<MyProfileResult> {
        return userRepository.getMyProfileData()
            .observe(on: MainScheduler.instance)
    }
    
    private func getOtherProfileData(userId: Int) -> Observable<OtherProfileResult> {
        return userRepository.getOtherProfile(userId: userId)
    }
    
    private func postBlockUser(userId: Int) -> Observable<Void> {
        return userRepository.postBlockUser(userId: userId)
    }
}
