//
//  MyPagePushNotificationView.swift
//  WSSiOS
//
//  Created by YunhakLee on 1/22/25.
//

import UIKit

import SnapKit
import Then

final class MyPagePushNotificationView: UIView {
    
    //MARK: - Components
    
    private let activePushSettingSection = UIView()
    private let activePushSettingTitleLabel = UILabel()
    private let activePushSettingDescriptionLabel = UILabel()
    let activePushSettingToggleButton = WSSToggleButton()
    
    //In VC
    let backButton = UIButton()
    
    // MARK: - Life Cycle
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setUI()
        setHierarchy()
        setLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - UI
    
    private func setUI() {
        self.do {
            $0.backgroundColor = .wssWhite
        }
        
        activePushSettingSection.do {
            $0.backgroundColor = .wssWhite
        }
        
        activePushSettingTitleLabel.do {
            $0.textColor = .wssBlack
            $0.applyWSSFont(.body1, with: StringLiterals.MyPage.PushNotification.activePushTitle)
        }
        
        activePushSettingDescriptionLabel.do {
            $0.textColor = .wssGray200
            $0.applyWSSFont(.body4, with: StringLiterals.MyPage.PushNotification.activePushDescription)
        }
                
        backButton.do {
            $0.setImage(.icNavigateLeft.withRenderingMode(.alwaysOriginal), for: .normal)
        }
    }
    
    private func setHierarchy() {
        self.addSubview(activePushSettingSection)
        activePushSettingSection.addSubviews(activePushSettingTitleLabel,
                                             activePushSettingDescriptionLabel,
                                             activePushSettingToggleButton)
    }
    
    private func setLayout() {
        activePushSettingSection.snp.makeConstraints {
            $0.top.equalTo(safeAreaLayoutGuide.snp.top)
            $0.height.equalTo(63)
            $0.horizontalEdges.equalToSuperview()
        }
        
        activePushSettingTitleLabel.snp.makeConstraints {
            $0.top.equalToSuperview().inset(9)
            $0.leading.equalToSuperview().inset(20)
        }
        
        activePushSettingDescriptionLabel.snp.makeConstraints {
            $0.bottom.equalToSuperview().inset(9)
            $0.leading.equalToSuperview().inset(20)
        }
        
        activePushSettingToggleButton.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.trailing.equalToSuperview().inset(20)
        }
    }
    
    //MARK: - Data
    
    func bindData(isPrivate: Bool) {
     
    }
    
    func changeCompleteButton(change: Bool) {

    }
}
