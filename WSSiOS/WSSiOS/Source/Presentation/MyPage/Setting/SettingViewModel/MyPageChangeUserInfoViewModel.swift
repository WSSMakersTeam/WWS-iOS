//
//  MyPageChangeUserInfoViewModel.swift
//  WSSiOS
//
//  Created by 신지원 on 9/20/24.
//

import Foundation
import UIKit

import RxSwift
import RxCocoa

final class MyPageChangeUserInfoViewModel: ViewModelType {
    
    //MARK: - Properties
    
    private let userRepository: UserRepository
    private let userInfo: ChangeUserInfo
    
    private var currentGender = ""
    private var currentBirth = 0
    
    //MARK: - Life Cycle
    
    init(userRepository: UserRepository, userInfo: ChangeUserInfo) {
        self.userRepository = userRepository
        self.userInfo = userInfo
        
        self.currentGender = self.userInfo.gender
        self.currentBirth = self.userInfo.birth
    }
    
    struct Input {
        let maleButtonTapped: ControlEvent<Void>
        let femaleButtonTapped: ControlEvent<Void>
        let birthViewTapped: ControlEvent<UITapGestureRecognizer>
        let backButtonTapped: ControlEvent<Void>
        let completeButtonTapped: ControlEvent<Void>
    }
    
    struct Output {
        let dataBind = BehaviorRelay<ChangeUserInfo>(value: ChangeUserInfo(gender: "", 
                                                                           birth: 0))
        let changeGender = BehaviorRelay<String>(value: "")
        let showBottomSheet = PublishRelay<Bool>()
        let changeCompleteButton = PublishRelay<Bool>()
        let popViewConroller = PublishRelay<Bool>()
    }
    
    func transform(from input: Input, disposeBag: DisposeBag) -> Output {
        let output = Output()
        
        output.dataBind.accept(self.userInfo)
        
        input.maleButtonTapped
            .subscribe(with: self, onNext: { owner, _ in
                owner.currentGender = "M"
                output.changeGender.accept("M")
                output.changeCompleteButton.accept(owner.checkIsEnabledCompleteButton())
            })
            .disposed(by: disposeBag)
        
        input.femaleButtonTapped
            .subscribe(with: self, onNext: { owner, _ in
                owner.currentGender = "F"
                output.changeGender.accept("F")
                output.changeCompleteButton.accept(owner.checkIsEnabledCompleteButton())
            })
            .disposed(by: disposeBag)
        
        input.birthViewTapped
            .subscribe(with: self, onNext: { owner, _ in
                output.showBottomSheet.accept(true)
            })
            .disposed(by: disposeBag)
        
        input.backButtonTapped
            .throttle(.seconds(3), scheduler: MainScheduler.instance)
            .subscribe(with: self, onNext: { owner, _ in
                output.popViewConroller.accept(true)
            })
            .disposed(by: disposeBag)
        
        input.completeButtonTapped
            .throttle(.seconds(3), scheduler: MainScheduler.instance)
            .subscribe(with: self, onNext: { owner, _ in
                owner.putUserInfo(gender: owner.currentGender, birth: owner.currentBirth)
                    .subscribe(with: self, onNext: { owner, _ in
                        
                        output.popViewConroller.accept(true)
                    }, onError: { owner, error in
                        print(error)
                    })
                    .disposed(by: disposeBag)
            })
            .disposed(by: disposeBag)
        
        return output
    }
    
    //MARK: - API
    
    private func putUserInfo(gender: String, birth: Int) -> Observable<Void> {
        return userRepository.putUserInfo(gender: gender, birth: birth) 
            .observe(on: MainScheduler.instance)
    }
    
    //MARK: - Custom Method
    
    private func checkIsEnabledCompleteButton() -> Bool {
        return userInfo.gender != currentGender || userInfo.birth != currentBirth
    }
}

