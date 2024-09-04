//
//  HomeNoticeDetailViewController.swift
//  WSSiOS
//
//  Created by Seoyeon Choi on 7/6/24.
//

import UIKit

import RxSwift
import RxRelay

final class HomeNoticeDetailViewController: UIViewController {
    
    //MARK: - Properties
    
    private let viewModel: HomeNoticeDetailViewModel
    private let disposeBag = DisposeBag()
    
    private let notice: Notice
    private let viewWillAppearEvent = BehaviorRelay(value: Notice(noticeTitle: "", noticeContent: "", createdDate: ""))
    
    //MARK: - UI Components
    
    private let rootView = HomeNoticeDetailView()
    private var backButton = UIButton()
    
    //MARK: - Life Cycle
    
    init(viewModel: HomeNoticeDetailViewModel, notice: Notice) {
        self.viewModel = viewModel
        self.notice = notice
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
        
        preparationSetNavigationBar(title: StringLiterals.Navigation.Title.notice,
                                    left: self.backButton,
                                    right: nil)
        viewWillAppearEvent.accept(self.notice)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUI()
        bindViewModel()
    }
    
    //MARK: - UI
    
    private func setUI() {
        self.view.backgroundColor = .wssWhite
        
        backButton.do {
            $0.setImage(.icNavigateLeft, for: .normal)
        }
    }
    
    //MARK: - Bind
    
    private func bindViewModel() {
        let input = HomeNoticeDetailViewModel.Input(viewWillAppearEvent: self.viewWillAppearEvent.asObservable())
        let output = viewModel.transform(from: input, disposeBag: disposeBag)
        
        output.noticeData
            .observe(on: MainScheduler.instance)
            .bind(with: self, onNext: { owner, data in
                owner.rootView.noticeContentView.bindData(data: data)
            })
            .disposed(by: disposeBag)
        
        self.backButton.rx.tap
            .throttle(.seconds(3), latest: false, scheduler: MainScheduler.instance)
            .subscribe(with: self, onNext: { owner, _ in
                owner.popToLastViewController()
            })
            .disposed(by: disposeBag)
    }
}
