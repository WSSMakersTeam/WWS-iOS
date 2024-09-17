//
//  NovelKeywordSelectModalViewModel.swift
//  WSSiOS
//
//  Created by Hyowon Jeon on 9/17/24.
//

import UIKit

import RxSwift
import RxCocoa

final class NovelKeywordSelectModalViewModel: ViewModelType {
    
    //MARK: - Properties
    
    var keywordSearchResultList: [String] = ["환생생", "환생남주", "환생이", "환생물", "환생", "환환생", "환생여주", "환환환생"]
    
    //MARK: - Life Cycle
    
    struct Input {
        let closeButtonDidTap: ControlEvent<Void>
        let searchButtonDidTap: ControlEvent<Void>
        let searchResultCollectionViewContentSize: Observable<CGSize?>
    }
    
    struct Output {
        let dismissModalViewController = PublishRelay<Void>()
        let keywordSearchResultListData = BehaviorRelay<[String]>(value: [])
        let searchResultCollectionViewHeight = BehaviorRelay<CGFloat>(value: 0)
    }
    
    func transform(from input: Input, disposeBag: DisposeBag) -> Output {
        let output = Output()
        
        input.closeButtonDidTap
            .subscribe(onNext: { _ in
                output.dismissModalViewController.accept(())
            })
            .disposed(by: disposeBag)
        
        input.searchButtonDidTap
            .subscribe(with: self, onNext: { owner, _ in
                output.keywordSearchResultListData.accept(owner.keywordSearchResultList)
            })
            .disposed(by: disposeBag)
        
        input.searchResultCollectionViewContentSize
            .map { $0?.height ?? 0 }
            .bind(to: output.searchResultCollectionViewHeight)
            .disposed(by: disposeBag)
        
        return output
    }
}
