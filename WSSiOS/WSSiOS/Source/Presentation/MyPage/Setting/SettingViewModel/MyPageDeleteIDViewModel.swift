//
//  MyPageDeleteIDViewModel.swift
//  WSSiOS
//
//  Created by 신지원 on 7/24/24.
//

import UIKit

import RxSwift
import RxCocoa

final class MyPageDeleteIDViewModel: ViewModelType {
    
    //MARK: - Properties
    
    private let authRepository: AuthRepository
    static let textViewMaxLimit = 80
    static let exceptionIndexPath: IndexPath = [ 0 , 4 ]
    
    private let reasonCellTitle = BehaviorRelay<[String]>(value: StringLiterals.MyPage.DeleteIDReason.allCases.map { $0.rawValue })
    private let checkCellTitle = BehaviorRelay<[(String, String)]>(value: zip(StringLiterals.MyPage.DeleteIDCheckTitle.allCases, StringLiterals.MyPage.DeleteIDCheckContent.allCases).map { ($0.rawValue, $1.rawValue) })
    
    private let reasonCellTap = BehaviorRelay<Bool>(value: false)
    private let isEmptyTextField = BehaviorRelay<Bool>(value: true)
    private let reasonStringRelay = BehaviorRelay<String>(value: "")
    
    //MARK: - Life Cycle
    
    init(authRepository: AuthRepository) {
        self.authRepository = authRepository
    }
    
    struct Input {
        let backButtonDidTap: ControlEvent<Void>
        let agreeAllButtonDidTap: ControlEvent<Void>
        let reasonCellDidTap: ControlEvent<IndexPath>
        let completeButtonDidTap: ControlEvent<Void>
        let viewDidTap: ControlEvent<UITapGestureRecognizer>
        let textUpdated: Observable<String>
        let didBeginEditing: ControlEvent<Void>
        let didEndEditing: ControlEvent<Void>
    }
    
    struct Output {
        let bindReasonCell: Observable<[String]>
        let bindCheckCell: Observable<[(String, String)]>
        let tapReasonCell = PublishRelay<IndexPath>()
        let popViewController = PublishRelay<Bool>()
        let changeAgreeButtonColor = BehaviorRelay<Bool>(value: false)
        let completeButtonIsAble = BehaviorRelay<Bool>(value: false)
        let textCountLimit = PublishRelay<Int>()
        let beginEditing = PublishRelay<Bool>()
        let endEditing = PublishRelay<Bool>()
        let containText = BehaviorRelay<String>(value: "")
        let pushToLoginViewController = PublishRelay<Bool>()
    }
    
    func transform(from input: Input, disposeBag: DisposeBag) -> Output {
        let output = Output(bindReasonCell: reasonCellTitle.asObservable(),
                            bindCheckCell: checkCellTitle.asObservable())
        
        input.backButtonDidTap
            .throttle(.seconds(3), latest: false, scheduler: MainScheduler.instance)
            .subscribe(with: self, onNext: { owner, _ in
                output.popViewController.accept(true)
            })
            .disposed(by: disposeBag)
        
        input.agreeAllButtonDidTap
            .subscribe(with: self, onNext: { owner, _ in
                let currentValue = output.changeAgreeButtonColor.value
                output.changeAgreeButtonColor.accept(!currentValue)
            })
            .disposed(by: disposeBag)
        
        input.reasonCellDidTap
            .subscribe(with: self, onNext: { owner, indexPath in
                output.tapReasonCell.accept(indexPath)
                owner.reasonCellTap.accept(true)
                if indexPath != MyPageDeleteIDViewModel.exceptionIndexPath {
                    output.containText.accept("")
                    output.endEditing.accept(true)
                    owner.reasonStringRelay.accept(StringLiterals.MyPage.DeleteIDReason.reasonForIndex(indexPath.row))
                } else {
                    owner.reasonStringRelay.accept(output.containText.value)
                }
            })
            .disposed(by: disposeBag)
        
        input.viewDidTap
            .subscribe(onNext: { _ in
                output.endEditing.accept(true)
            })
            .disposed(by: disposeBag)
        
        input.textUpdated
            .observe(on: MainScheduler.asyncInstance)
            .subscribe(with: self, onNext: { owner, text in
                output.containText.accept(String(text.prefix(MyPageDeleteIDViewModel.textViewMaxLimit)))
                output.textCountLimit.accept(output.containText.value.count)
                owner.isEmptyTextField.accept(output.containText.value.isEmpty || output.containText.value.range(of: "^[\\s]*$", options: .regularExpression) != nil)
            })
            .disposed(by: disposeBag)
        
        input.didBeginEditing
            .subscribe(with: self, onNext: { owner, text in
                output.tapReasonCell.accept(MyPageDeleteIDViewModel.exceptionIndexPath)
                output.beginEditing.accept(true)
            })
            .disposed(by: disposeBag)
        
        input.didEndEditing
            .observe(on:MainScheduler.asyncInstance)
            .subscribe(onNext: { _ in
                output.endEditing.accept(true)
            })
            .disposed(by: disposeBag)
        
        input.completeButtonDidTap
            .throttle(.seconds(3), latest: false, scheduler: MainScheduler.instance)
            .flatMapLatest{ _ -> Observable<Void> in
                let reasonString = self.reasonStringRelay.value
                guard let refreshTokenString = UserDefaults.standard.string(forKey: StringLiterals.UserDefault.refreshToken) else { return Observable.empty() }
                return self.postDeleteID(reason: reasonString, refreshToken: refreshTokenString)
            }
            .subscribe(
                onNext: {
                    output.pushToLoginViewController.accept(true)
                },
                onError: { error in
                    print(error.localizedDescription)
                }
            )
            .disposed(by: disposeBag)
        
        Observable
            .combineLatest(reasonCellTap,
                           output.tapReasonCell,
                           isEmptyTextField,
                           output.changeAgreeButtonColor)
            .map { tappedCell, cellIndexPath, textEmpty, tappedAgreeButton in
                guard tappedCell, tappedAgreeButton else { return false }
                return cellIndexPath != MyPageDeleteIDViewModel.exceptionIndexPath || !textEmpty
            }
            .bind(to: output.completeButtonIsAble)
            .disposed(by: disposeBag)
        
        return output
    }
    
    //MARK: - API
    
    private func postDeleteID(reason: String, refreshToken: String) -> Observable<Void> {
        return self.authRepository.postWithdrawId(reason: reason, refreshToken: refreshToken)
            .asObservable()
    }
}
