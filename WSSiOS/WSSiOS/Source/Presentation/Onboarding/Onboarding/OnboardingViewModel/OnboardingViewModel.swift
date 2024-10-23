//
//  OnboardingViewModel.swift
//  WSSiOS
//
//  Created by YunhakLee on 9/27/24.
//

import UIKit

import RxCocoa
import RxGesture
import RxSwift


final class OnboardingViewModel: ViewModelType {
    
    //MARK: - Properties
    
    private let onboardingRepository: OnboardingRepository
    
    // Nickname
    private let nicknameText = BehaviorRelay<String>(value: "")
    private let isNicknameFieldEditing = BehaviorRelay<Bool>(value: false)
    private let nicknameTextFieldClear = PublishRelay<Void>()
    private let isDuplicateCheckButtonEnabled = BehaviorRelay<Bool>(value: false)
    private let isNicknameAvailable = BehaviorRelay<NicknameAvailablity>(value: .notStarted)
    private let nicknameNotAvailableReason = BehaviorRelay<NicknameNotAvailableReason?>(value: nil)
    private let isNicknameNextButtonAvailable = BehaviorRelay<Bool>(value: false)
    
    // BirthGender
    private let selectedGender = BehaviorRelay<OnboardingGender?>(value: nil)
    private let selectedBirth = BehaviorRelay<Int?>(value: nil)
    private let isBirthGenderNextButtonAvailable = BehaviorRelay<Bool>(value: false)
    
    // GenrePreference
    private let selectedGenres = BehaviorRelay<[NewNovelGenre]>(value: [])
    private let isGenrePreferenceNextButtonAvailable = BehaviorRelay<Bool>(value: false)
    
    // Total
    private let moveToLastStage = PublishRelay<Void>()
    private let moveToNextStage = PublishRelay<Void>()
    private let moveToOnboardingSuccessViewController = PublishRelay<String>()
    private let stageIndex = BehaviorRelay<Int>(value: 0)
    private let progressOffset = BehaviorRelay<CGFloat>(value: 0)
    
    //MARK: - Life Cycle
    
    init(onboardingRepository: OnboardingRepository) {
        self.onboardingRepository = onboardingRepository
    }
    
    //MARK: - Transform
    
    struct Input {
        // Nickname
        let nicknameTextFieldEditingDidBegin: ControlEvent<Void>
        let nicknameTextFieldEditingDidEnd: ControlEvent<Void>
        let nicknameTextFieldText: Observable<String>
        let textFieldInnerButtonDidTap: ControlEvent<Void>
        let duplicateCheckButtonDidTap: ControlEvent<Void>
        
        // BirthGender
        let genderButtonDidTap: Observable<OnboardingGender>
        let selectBirthButtonDidTap: ControlEvent<Void>
        
        // GenrePreference
        let genreButtonDidTap: Observable<NewNovelGenre>
        
        // Total
        let nextButtonDidTap: Observable<Void>
        let backButtonDidTap: ControlEvent<Void>
        let scrollViewContentOffset: ControlProperty<CGPoint>
        let skipButtonDidTap: ControlEvent<Void>
    }
    
    struct Output {
        // Nickname
        let isNicknameTextFieldEditing: Driver<Bool>
        let nicknameTextFieldClear: Driver<Void>
        let isDuplicateCheckButtonEnabled: Driver<Bool>
        let nicknameAvailablity: Driver<NicknameAvailablity>
        let nicknameNotAvailableReason: Driver<NicknameNotAvailableReason?>
        let isNicknameNextButtonEnabled: Driver<Bool>
        
        // BirthGender
        let selectedGender: Driver<OnboardingGender?>
        let showDatePickerModal: Driver<Void>
        let isBirthGenderNextButtonEnabled: Driver<Bool>
        
        // GenrePrefernece
        let selectedGenres: Driver<[NewNovelGenre]>
        let isGenrePreferenceNextButtonEnabled: Driver<Bool>
        
        // Total
        let stageIndex: Driver<Int>
        let moveToLastStage: Driver<Void>
        let moveToNextStage: Driver<Void>
        let moveToOnboardingSuccessViewController: Driver<String>
        let progressOffset: Driver<CGFloat>
    }
    
    func transform(from input: Input, disposeBag: DisposeBag) -> Output {
        // Nickname
        input.nicknameTextFieldEditingDidBegin
            .bind(with: self, onNext: { owner, _ in
                owner.isNicknameFieldEditing.accept(true)
            })
            .disposed(by: disposeBag)
        
        input.nicknameTextFieldEditingDidEnd
            .withLatestFrom(input.nicknameTextFieldText)
            .bind(with: self, onNext: { owner, text in
                owner.isNicknameFieldEditing.accept(!text.isEmpty)
            })
            .disposed(by: disposeBag)
        
        input.nicknameTextFieldText
            .bind(with: self, onNext: { owner, text in
                owner.checkNicknameAvailability(text)
            })
            .disposed(by: disposeBag)
        
        self.isNicknameAvailable
            .bind(with: self, onNext: { owner, availablity in
                owner.isDuplicateCheckButtonEnabled.accept(availablity == .unknown)
                owner.isNicknameNextButtonAvailable.accept(availablity == .available)
            })
            .disposed(by: disposeBag)
        
        self.isNicknameAvailable
            .filter { $0 == .available }
            .withLatestFrom(input.nicknameTextFieldText)
            .bind(with: self, onNext: { owner, nickname in
                owner.nicknameText.accept(nickname)
            })
            .disposed(by: disposeBag)
        
        input.textFieldInnerButtonDidTap
            .bind(with: self, onNext: { owner, availablity in
                owner.nicknameTextFieldClear.accept(())
                owner.isNicknameAvailable.accept(.notStarted)
            })
            .disposed(by: disposeBag)
        
        input.duplicateCheckButtonDidTap
            .withLatestFrom(input.nicknameTextFieldText)
            .bind(with: self, onNext: { owner, nickname in
                owner.checkNicknameisValid(nickname, disposeBag: disposeBag)
            })
            .disposed(by: disposeBag)
        
        // BirthGender
        input.genderButtonDidTap
            .bind(with: self, onNext: { owner, selectedGender in
                owner.selectedGender.accept(selectedGender)
            })
            .disposed(by: disposeBag)
        
        let showDatePickerModal = input.selectBirthButtonDidTap.asDriver()
        
        self.selectedGender
            .bind(with: self, onNext: { owner, selectedGender in
                // DatePicker 관련된 것은 나중에 적용 예정, 지금은 성별만 선택하면 넘어갈 수 있음
                if selectedGender != nil {
                    owner.isBirthGenderNextButtonAvailable.accept(true)
                }
            })
            .disposed(by: disposeBag)
        
        // GenrePreference
        input.genreButtonDidTap
            .bind(with: self, onNext: { owner, genre in
                var selectedGenres = owner.selectedGenres.value
                if selectedGenres.contains(genre) {
                    selectedGenres.removeAll(where: { $0 == genre })
                } else {
                    selectedGenres.append(genre)
                }
                owner.selectedGenres.accept(selectedGenres)
                owner.isGenrePreferenceNextButtonAvailable.accept(!selectedGenres.isEmpty)
            })
            .disposed(by: disposeBag)
        
        input.skipButtonDidTap
            .throttle(.seconds(1), scheduler: MainScheduler.instance)
            .withLatestFrom(nicknameText)
            .bind(with: self, onNext: { owner, nickname in
                owner.moveToOnboardingSuccessViewController.accept(nickname)
            })
            .disposed(by: disposeBag)
        
        // Total
        input.backButtonDidTap
            .throttle(.seconds(1), scheduler: MainScheduler.instance)
            .withLatestFrom(stageIndex)
            .bind(with: self, onNext: { owner, stage in
                if stage > 0 {
                    owner.stageIndex.accept(stage - 1)
                    owner.moveToLastStage.accept(())
                }
            })
            .disposed(by: disposeBag)
        
        input.nextButtonDidTap
            .throttle(.seconds(1), scheduler: MainScheduler.instance)
            .withLatestFrom(stageIndex)
            .bind(with: self, onNext: { owner, stage in
                // 만든 부분까지만 보여주고, 바로 홈으로 이동. 지금은 1번까지 만들어져 있음.
                if stage >= 2 {
                    owner.moveToOnboardingSuccessViewController.accept(owner.nicknameText.value)
                } else if stage >= 0 {
                    owner.stageIndex.accept(stage + 1)
                    owner.moveToNextStage.accept(())
                }
            })
            .disposed(by: disposeBag)
        
        input.scrollViewContentOffset
            .bind(with: self, onNext: { owner, offset in
                let screenWidth = UIScreen.main.bounds.width
                let offset = screenWidth - (offset.x + screenWidth)/3
                owner.progressOffset.accept(offset)
            })
            .disposed(by: disposeBag)
        
        return Output(
            isNicknameTextFieldEditing: isNicknameFieldEditing.asDriver(),
            nicknameTextFieldClear: nicknameTextFieldClear.asDriver(onErrorJustReturn: ()),
            isDuplicateCheckButtonEnabled: isDuplicateCheckButtonEnabled.asDriver(),
            nicknameAvailablity: isNicknameAvailable.asDriver(),
            nicknameNotAvailableReason: nicknameNotAvailableReason.asDriver(),
            isNicknameNextButtonEnabled: isNicknameNextButtonAvailable.asDriver(),
            selectedGender: selectedGender.asDriver(),
            showDatePickerModal: showDatePickerModal,
            isBirthGenderNextButtonEnabled: isBirthGenderNextButtonAvailable.asDriver(),
            selectedGenres: selectedGenres.asDriver(),
            isGenrePreferenceNextButtonEnabled: isGenrePreferenceNextButtonAvailable.asDriver(),
            stageIndex: stageIndex.asDriver(),
            moveToLastStage: moveToLastStage.asDriver(onErrorJustReturn: ()),
            moveToNextStage: moveToNextStage.asDriver(onErrorJustReturn: ()),
            moveToOnboardingSuccessViewController: moveToOnboardingSuccessViewController.asDriver(onErrorJustReturn: "Error"),
            progressOffset: progressOffset.asDriver()
        )
    }
    
    //MARK: - Custom Method
    
    private func checkNicknameAvailability(_ nickname: String) {
        if nickname.isEmpty {
            self.isNicknameAvailable.accept(.notStarted)
        } else if !self.isValidNicknameCharacters(nickname) {
            if nickname.contains(where: { $0 == " " }) {
                self.isNicknameAvailable.accept(
                    .notAvailable(reason: .whiteSpaceIncluded)
                )
            } else {
                self.isNicknameAvailable.accept(
                    .notAvailable(reason: .invalidChacterOrLimitExceeded)
                )
            }
        } else {
            self.isNicknameAvailable.accept(.unknown)
        }
    }
    
    private func isValidNicknameCharacters(_ text: String) -> Bool {
        let pattern = "^[a-zA-Z0-9가-힣ㄱ-ㅎㅏ-ㅣ]{2,10}$"
        return text.range(of: pattern, options: .regularExpression) != nil
    }
    
    private func checkNicknameisValid(_ nickname: String, disposeBag: DisposeBag) {
        self.onboardingRepository.getNicknameisValid(nickname)
            .map { $0.isValid }
            .subscribe(with: self, onNext: { owner, isValid in
                if isValid {
                    owner.isNicknameAvailable.accept(.available)
                } else {
                    owner.isNicknameAvailable.accept(.notAvailable(reason: .duplicated))
                }
            }, onError: { owner, error in
                owner.isNicknameAvailable.accept(.notAvailable(reason: .invalidChacterOrLimitExceeded))
                print(error)
            })
            .disposed(by: disposeBag)
    }
}
