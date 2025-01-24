//
//  MyPageLibraryViewModel.swift
//  WSSiOS
//
//  Created by 신지원 on 1/22/25.
//

import UIKit

import RxSwift
import RxCocoa

final class MyPageLibraryViewModel: ViewModelType {
    
    // MARK: - Properties
    
    private let userRepository: UserRepository
    private let disposeBag = DisposeBag()
    
    /// 초기값은 내 프로필로 설정
    private let isMyPage = BehaviorRelay<Bool>(value: true)
    private var profileId: Int
    
    private let isExistPrefernecesRelay = BehaviorRelay<Bool>(value: false)
    private let isProfilePrivate = PublishRelay<Bool>()
    
    private let bindInventoryDataRelay = BehaviorRelay<UserNovelStatus>(value: UserNovelStatus(interestNovelCount: 0,
                                                                                               watchingNovelCount: 0,
                                                                                               watchedNovelCount: 0,
                                                                                               quitNovelCount: 0))
    private let pushToLibraryViewControllerRelay = PublishRelay<Int>()
    private let bindGenreDataRelay = BehaviorRelay<UserGenrePreferences>(value: UserGenrePreferences(genrePreferences: []))
    private let showGenreOtherViewRelay = BehaviorRelay<Bool>(value: false)
    
    private let bindAttractivePointsDataRelay = BehaviorRelay<[String]>(value: [])
    let bindKeywordRelay = BehaviorRelay<[Keyword]>(value: [])
    private let updateButtonWithLibraryViewRelay = BehaviorRelay<Bool>(value: true)
    private let updateKeywordCollectionViewHeightRelay = PublishRelay<CGFloat>()
    
    // MARK: - Life Cycle
    
    init(userRepository: UserRepository, profileId: Int) {
        self.userRepository = userRepository
        self.profileId = profileId
    }
    
    struct Input {
        let viewWillAppearEvent: BehaviorRelay<Void>
        let genrePreferenceButtonDidTap: Observable<Bool>
        let inventoryViewDidTap: Observable<UITapGestureRecognizer>
        let resizeKeywordCollectionViewHeight: Observable<CGSize?>
    }
    
    struct Output {
        let isExistPreferneces: BehaviorRelay<Bool>
        let isProfilePrivate: PublishRelay<Bool>
        
        let bindInventoryData: BehaviorRelay<UserNovelStatus>
        let pushToLibraryViewController: PublishRelay<Int>
        let bindGenreData: BehaviorRelay<UserGenrePreferences>
        let showGenreOtherView: BehaviorRelay<Bool>
        let bindAttractivePointsData: BehaviorRelay<[String]>
        let bindKeywordCell: BehaviorRelay<[Keyword]>
        let updateKeywordCollectionViewHeight: PublishRelay<CGFloat>
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
                
                return Observable.merge(
                    self.updateMyPageLibraryInventoryData(),
                    self.updateMyPageLibraryPreferenceData()
                )
                /// flatMap 체인에서 반환 타입을 일관되게 만들어야 하기 때문에 함수의 리턴값인 <CGFloat> 을 <Void> 로 조정
                .flatMap { _ -> Observable<Void> in
                    self.handleKeywordCollectionViewHeight(resizeKeywordCollectionViewHeight: input.resizeKeywordCollectionViewHeight)
                        .map { _ in () }
                }
            }
            .subscribe()
            .disposed(by: disposeBag)
        
        input.genrePreferenceButtonDidTap
            .subscribe(with: self, onNext: { owner, _ in
                let currentState = owner.showGenreOtherViewRelay.value
                owner.showGenreOtherViewRelay.accept(!currentState)
            })
            .disposed(by: disposeBag)
        
        input.inventoryViewDidTap
            .bind(with: self, onNext: { owner, _ in
                self.pushToLibraryViewControllerRelay.accept(owner.profileId)
            })
            .disposed(by: disposeBag)
        
        Observable.combineLatest(
            bindAttractivePointsDataRelay.asObservable(),
            bindKeywordRelay.asObservable()
        )
        .map { attractivePoints, keywords in
            !(attractivePoints.isEmpty && keywords.isEmpty)
        }
        .bind(to: isExistPrefernecesRelay)
        .disposed(by: disposeBag)
        
        return Output(isExistPreferneces: isExistPrefernecesRelay,
                      isProfilePrivate: isProfilePrivate,
                      bindInventoryData: bindInventoryDataRelay,
                      pushToLibraryViewController: pushToLibraryViewControllerRelay,
                      bindGenreData: bindGenreDataRelay,
                      showGenreOtherView: showGenreOtherViewRelay,
                      bindAttractivePointsData: bindAttractivePointsDataRelay,
                      bindKeywordCell: bindKeywordRelay,
                      updateKeywordCollectionViewHeight: updateKeywordCollectionViewHeightRelay)
    }
    
    // MARK: - Custom Method
    
    /// 비공개처리된 유저
    private func isPrivateUserError(_ error: Error) -> Bool {
        if let networkError = error as? RxCocoaURLError {
            switch networkError {
            case .httpRequestFailed(_, let data):
                if let data = data {
                    do {
                        let errorInfo = try JSONDecoder().decode(ServerErrorResponse.self, from: data)
                        return errorInfo.code == "USER-015"
                    } catch {}
                }
                
            default:
                return false
            }
        }
        return false
    }
    
    /// 서재 데이터 바인딩
    /// 보관함-장르취향-작품취향 서버연결
    private func updateMyPageLibraryInventoryData() -> Observable<Void> {
        return getInventoryData(userId: self.profileId)
            .flatMap { [weak self] inventory -> Observable<Void> in
                guard let self else { return .just(()) }
                self.bindInventoryDataRelay.accept(inventory)
                return .just(())
            }
        /// private 유저일 경우 에러를 배출함
            .catch { [weak self] error in
                guard let self else { return .empty() }
                
                if self.isPrivateUserError(error) {
                    self.isProfilePrivate.accept(true)
                }
                return .empty()
            }
    }
    
    //취향분석 데이터 바인딩
    private func updateMyPageLibraryPreferenceData() -> Observable<Void> {
        return getNovelPreferenceData(userId: self.profileId)
            .flatMap { [weak self] preference -> Observable<Bool> in
                guard let self else { return .just(false) }
                
                //작품취향 분기처리
                //1. 매력포인트, 키워드 둘 다 있을 때
                //2. 매력포인트만 있을 때
                //3. 키워드만 있을 때
                // => 각각의 뷰만 뜨게 함
                
                //4. 둘 다 없을 때
                //=> emptyView 처리
                //=> 이 경우 장르 취향도 데이터가 없기 때문에 false 반환
                let keywords = preference.keywords ?? []
                self.bindAttractivePointsDataRelay.accept(preference.attractivePoints ?? [])
                self.bindKeywordRelay.accept(keywords)
                return .just(true)
            }
            .catch { [weak self] error in
                guard let self else { return .empty() }
                
                if self.isPrivateUserError(error) {
                    self.isProfilePrivate.accept(true)
                }
                return .just(false)
            }
        
        /// 장르 취향
            .flatMap { [weak self] isExist -> Observable<Void> in
                guard let self else { return .empty() }
                if isExist {
                    return self.getGenrePreferenceData(userId: self.profileId)
                        .do(onNext: { data in
                            if !data.genrePreferences.isEmpty {
                                self.bindGenreDataRelay.accept(data)
                            }
                        })
                        .map { _ in Void() }
                } else {
                    return .just(Void())
                }
            }
    }
    
    private func handleKeywordCollectionViewHeight(resizeKeywordCollectionViewHeight: Observable<CGSize?>) -> Observable<CGFloat> {
        return resizeKeywordCollectionViewHeight
            .map { $0?.height ?? 0 }
            .do(onNext: { [weak self] height in
                self?.updateKeywordCollectionViewHeightRelay.accept(height)
            })
    }
    
    // MARK: - API
    
    func getUserMeData() -> Observable<UserMeResult> {
        return userRepository.getUserMeData()
    }
    
    private func getNovelPreferenceData(userId: Int) -> Observable<UserNovelPreferences> {
        return userRepository.getUserNovelPreferences(userId: userId)
    }
    
    private func getGenrePreferenceData(userId: Int) -> Observable<UserGenrePreferences> {
        return userRepository.getUserGenrePreferences(userId: userId)
    }
    
    private func getInventoryData(userId: Int) -> Observable<UserNovelStatus> {
        return userRepository.getUserNovelStatus(userId: userId)
    }
}
