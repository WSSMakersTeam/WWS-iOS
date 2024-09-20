//
//  MyPageChangeUserInfoView.swift
//  WSSiOS
//
//  Created by 신지원 on 9/20/24.
//

import UIKit

import SnapKit
import Then

final class MyPageChangeUserInfoView: UIView {
    
    //MARK: - Components
    
    private let genderLabel = UILabel()
    let genderMaleButton = UIButton()
    let genderFemaleButton = UIButton()
    
    private let dividerView = UIView()
    
    private let birthLabel = UILabel()
    private let birthButtonView = UIView()
    var birthYearLabel = UILabel()
    private let birthArrowImageView = UIImageView()
    
    //In VC
    let backButton = UIButton()
    let completeButton = UIButton()
    
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
        
        genderLabel.do {
            $0.textColor = .wssBlack
            $0.applyWSSFont(.body2, with: StringLiterals.MyPage.ChangeUserInfo.gender)
        }
        
        [genderMaleButton, genderFemaleButton].enumerated().forEach { index, button in
            selectGenderButton(button: button, index: index, select: false)
        }
        
        dividerView.do {
            $0.backgroundColor = .wssGray50
        }
        
        birthLabel.do {
            $0.textColor = .wssBlack
            $0.applyWSSFont(.body2, with: StringLiterals.MyPage.ChangeUserInfo.birthYear)
        }
        
        birthButtonView.do {
            $0.backgroundColor = .wssGray50
            $0.layer.cornerRadius = 8
            
            birthYearLabel.do {
                $0.textColor = .wssBlack
            }
            
            birthArrowImageView.do {
                $0.image = .icDropDown.withTintColor(.wssGray300, renderingMode: .alwaysOriginal)
            }
        }
        
        backButton.do {
            $0.setImage(.icNavigateLeft.withRenderingMode(.alwaysOriginal).withTintColor(.wssGray300), for: .normal)
        }
        
        completeButton.do {
            $0.setTitle(StringLiterals.MyPage.ChangeUserInfo.complete, for: .normal)
            $0.setTitleColor(.wssGray200, for: .normal)
            $0.titleLabel?.applyWSSFont(.title2, with: StringLiterals.MyPage.ChangeUserInfo.complete)
            $0.isEnabled = false
        }
    }
    
    private func setHierarchy() {
        self.addSubviews(genderLabel,
                         genderMaleButton,
                         genderFemaleButton,
                         dividerView,
                         birthLabel,
                         birthButtonView)
        birthButtonView.addSubviews(birthYearLabel,
                                    birthArrowImageView)
    }
    
    private func setLayout() {
        genderLabel.snp.makeConstraints {
            $0.top.equalTo(safeAreaLayoutGuide.snp.top).offset(30)
            $0.leading.equalToSuperview().inset(20)
        }
        
        genderMaleButton.snp.makeConstraints {
            $0.top.equalTo(genderLabel.snp.bottom).offset(10)
            $0.leading.equalToSuperview().inset(20)
            $0.trailing.equalTo(self.snp.centerX).offset(-6.5)
            $0.height.equalTo(43)
        }
        
        genderFemaleButton.snp.makeConstraints {
            $0.top.equalTo(genderLabel.snp.bottom).offset(10)
            $0.leading.equalTo(self.snp.centerX).offset(6.5)
            $0.trailing.equalToSuperview().inset(20)
            $0.height.equalTo(43)
        }
        
        dividerView.snp.makeConstraints {
            $0.top.equalTo(genderFemaleButton.snp.bottom).offset(30)
            $0.width.equalToSuperview()
            $0.height.equalTo(1)
        }
        
        birthLabel.snp.makeConstraints {
            $0.top.equalTo(dividerView.snp.bottom).offset(15)
            $0.leading.equalToSuperview().inset(20)
        }
        
        birthButtonView.snp.makeConstraints {
            $0.top.equalTo(birthLabel.snp.bottom).offset(6)
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.height.equalTo(43)
            
            birthYearLabel.snp.makeConstraints {
                $0.centerY.equalToSuperview()
                $0.leading.equalToSuperview().inset(20)
            }
            
            birthArrowImageView.snp.makeConstraints {
                $0.centerY.equalToSuperview()
                $0.trailing.equalToSuperview().inset(13.5)
                $0.size.equalTo(16)
            }
        }
        
        backButton.snp.makeConstraints {
            $0.size.equalTo(44)
        }
        
        completeButton.snp.makeConstraints {
            $0.width.equalTo(48)
            $0.height.equalTo(42)
        }
    }
    
    //MARK: - Data
    
    //MARK: - CustomMethod
    
    private func selectGenderButton(button: UIButton, index: Int, select: Bool) {
        button.do {
            var config = UIButton.Configuration.filled()
            config.title = index == 0 ? StringLiterals.MyPage.ChangeUserInfo.male : StringLiterals.MyPage.ChangeUserInfo.female
            config.baseBackgroundColor = select ? .wssPrimary50 : .wssGray50
            config.baseForegroundColor = select ? .wssPrimary100 : .wssGray300
            
            $0.layer.borderWidth = 1
            $0.layer.borderColor = select ? UIColor.wssPrimary50.cgColor : UIColor.clear.cgColor
            $0.layer.cornerRadius = 8
            $0.configuration = config
        }
    }
    
    func isEnabledCompleteButton(isEnabled: Bool) {
        completeButton.do {
            $0.setTitleColor(isEnabled ? .wssPrimary100 : .wssGray200, for: .normal)
            $0.isEnabled = isEnabled
        }
    }
}
