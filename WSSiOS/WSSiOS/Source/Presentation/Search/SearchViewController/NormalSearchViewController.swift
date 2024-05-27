//
//  NormalSearchViewController.swift
//  WSSiOS
//
//  Created by Seoyeon Choi on 5/27/24.
//

import UIKit

import RxSwift
import RxCocoa
import Then

final class NormalSearchViewController: UIViewController {
    
    //MARK: - Properties
    
    private let viewModel: NormalSearchViewModel
    private let disposeBag = DisposeBag()
    
    //MARK: - Components
    
    private let rootView = NormalSearchView()
    
    //MARK: - Life Cycle
    
    init(viewModel: NormalSearchViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        self.view = rootView
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUI()
        registerCell()
        
        bindViewModel()
    }
    
    //MARK: - UI
    
    private func setUI() {
        self.view.do {
            $0.backgroundColor = .White
        }
    }
    
    //MARK: - Bind
    
    private func registerCell() {
        
    }
    
    private func bindViewModel() {
        let input = NormalSearchViewModel.Input(
            backButtonDidTap: rootView.headerView.backButton.rx.tap
        )
        let output = viewModel.transform(from: input, disposeBag: disposeBag)
        
        output.backButtonEnabled
            .bind(with: self, onNext: { owner, _ in
                owner.popToLastViewController()
            })
            .disposed(by: disposeBag)
    }
}
