//
//  MyPageBlockUserViewModel.swift
//  WSSiOS
//
//  Created by 신지원 on 7/29/24.
//

import Foundation

import RxSwift
import RxCocoa

final class MyPageBlockUserViewModel: ViewModelType {
    
    //MARK: - Properties
    
    private let userRepository: UserRepository
    private var bindCellReleay = BehaviorRelay<[blockList]>(value: [])
    private let showEmptyView = PublishRelay<Bool>()
    private let popViewController = PublishRelay<Bool>()
    private let showToastMessage = PublishRelay<String>()
    
    init(userRepository: UserRepository) {
        self.userRepository = userRepository
    }
    
    //MARK: - Life Cycle
    
    struct Input {
        let backButtonDidTap: ControlEvent<Void>
        let unblockButtonDidTap: Observable<IndexPath>
    }
    
    struct Output {
        let showEmptyView: Driver<Bool>
        let popViewController: PublishRelay<Bool>
        let bindCell: BehaviorRelay<[blockList]>
        let showToastMessage: PublishRelay<String>
    }
    
    func transform(from input: Input, disposeBag: DisposeBag) -> Output {
        input.backButtonDidTap
            .subscribe(with: self, onNext: { owner, _ in
                owner.popViewController.accept(true)
            })
            .disposed(by: disposeBag)
        
        getBlockUserList()
            .subscribe(with: self, onNext: { owner, data in
                if data.blocks.isEmpty {
                    owner.showEmptyView.accept(true)
                }
                owner.bindCellReleay.accept(data.blocks)
            })
            .disposed(by: disposeBag)
        
        input.unblockButtonDidTap
            .subscribe(with: self, onNext: { owner, indexPath in
                let blocks = owner.bindCellReleay.value
                
                let blockID = blocks[indexPath.row].blockId
                var nickName = blocks[indexPath.row].nickname
                if nickName.count > 8 {
                    nickName = nickName.prefix(8) + "..."
                }
                
                owner.deleteBlockUser(blockID: blockID)
                    .subscribe(onNext: {
                        owner.showToastMessage.accept(nickName)
                    }, onError: { error in
                        print("Error: \(error)")
                    })
                    .disposed(by: disposeBag)
            })
            .disposed(by: disposeBag)
        
        return Output(showEmptyView: showEmptyView.asDriver(onErrorJustReturn: true),
                      popViewController: popViewController,
                      bindCell: bindCellReleay,
                      showToastMessage: showToastMessage)
    }
    
    //MARK: - API
    
    private func getBlockUserList() -> Observable<BlockUserResult> {
        return self.userRepository.getBlocksList()
    }
    
    private func deleteBlockUser(blockID: Int) -> Observable<Void> {
        return self.userRepository.deleteBlockUser(blockID: blockID)
    }
}
