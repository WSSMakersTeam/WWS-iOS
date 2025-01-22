//
//  MyPagePushNotificationViewController.swift
//  WSSiOS
//
//  Created by YunhakLee on 1/22/25.
//

import UIKit

import RxSwift

final class MyPagePushNotificationViewController: UIViewController {
    
    //MARK: - Properties
    
    private let viewModel: MyPagePushNotificationViewModel
    private let disposeBag = DisposeBag()
    
    //MARK: - Components
    
    private let rootView = MyPagePushNotificationView()
    
    // MARK: - Life Cycle
    
    init(viewModel: MyPagePushNotificationViewModel) {
        
        self.viewModel = viewModel
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        hideTabBar()
        swipeBackGesture()
        setNavigationBar()
    }
    
    //MARK: - Bind
    
    private func bindViewModel() {
        let input = MyPagePushNotificationViewModel.Input(
            activePushSettingSectionDidTap: rootView.activePushSettingSection.rx.tapGesture()
        )
        let output = viewModel.transform(from: input,
                                         disposeBag: disposeBag)
        output.activePushIsEnabled
            .drive(with: self, onNext: { owner, isEnabled in
                owner.rootView.bindData(isEnabled: isEnabled)
            })
            .disposed(by: disposeBag)
        
        rootView.backButton.rx.tap
            .asDriver()
            .drive(with: self, onNext: {owner, _ in
                owner.popToLastViewController()
            })
            .disposed(by: disposeBag)
        
    }
}

//MARK: - UI

extension MyPagePushNotificationViewController {
    private func setNavigationBar() {
        setWSSNavigationBar(title: StringLiterals.Navigation.Title.pushNotification,
                            left: self.rootView.backButton,
                            right: nil)
    }
}
