//
//  NovelDateSelectModalViewController.swift
//  WSSiOS
//
//  Created by Hyowon Jeon on 9/21/24.
//

import UIKit

import RxSwift
import RxCocoa

final class NovelDateSelectModalViewController: UIViewController {
    
    //MARK: - Properties
    
    private let novelDateSelectModalViewModel: NovelDateSelectModalViewModel
    private let disposeBag = DisposeBag()
    
    //MARK: - Components
    
    private let rootView = NovelDateSelectModalView()
    
    //MARK: - Life Cycle
    
    init(viewModel: NovelDateSelectModalViewModel) {
        self.novelDateSelectModalViewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        self.view = rootView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        bindViewModel()
    }
    
    //MARK: - UI
    
    //MARK: - Bind
    
    private func bindViewModel() {
        let input = NovelDateSelectModalViewModel.Input(
            closeButtonDidTap: rootView.closeButton.rx.tap
        )
        
        let output = self.novelDateSelectModalViewModel.transform(from: input, disposeBag: self.disposeBag)
        
        output.dismissModalViewController
            .subscribe(with: self, onNext: { owner, _ in
                owner.dismissModalViewController()
            })
            .disposed(by: disposeBag)
    }
}
