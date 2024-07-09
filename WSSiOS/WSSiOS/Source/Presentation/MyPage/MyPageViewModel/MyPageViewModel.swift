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
    
    private let userRepository: UserRepository
    private let disposeBag = DisposeBag()
    
    // MARK: - Life Cycle
    
    init(userRepository: UserRepository) {
        self.userRepository = userRepository
    }
    
    struct Input {
        let isMyPage: Driver<Bool>
    }
    
    struct Output {
        let isMyPage: Driver<Bool>
    }
    
    func transform(from input: Input, disposeBag: DisposeBag) -> Output {
        
        return Output(isMyPage: input.isMyPage)
    }
    
    // MARK: - Custom Method
    
    
    // MARK: - API
    
}
