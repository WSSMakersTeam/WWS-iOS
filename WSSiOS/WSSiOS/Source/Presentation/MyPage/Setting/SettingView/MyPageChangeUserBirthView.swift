//
//  MyPageChangeUserBirthView.swift
//  WSSiOS
//
//  Created by 신지원 on 9/23/24.
//

import UIKit

import SnapKit
import Then

final class MyPageChangeUserBirthView: UIView {
    
    static let cellHeight: CGFloat = 37
    
    //MARK: - Components
    
    let contentView = UIView()
    private let titleLabel = UILabel()
    let cancelButton = UIButton()
    let completeButton = WSSMainButton(title: "완료")
    
    private let tableView = UITableView()
    
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
        contentView.do {
            $0.backgroundColor = .wssWhite
            $0.layer.cornerRadius = 12
            $0.layer.maskedCorners = [.layerMinXMinYCorner,
                                      .layerMaxXMinYCorner]
        }
        
        titleLabel.do {
            $0.textColor = .wssBlack
            $0.applyWSSFont(.title1, with: "출생연도")
        }
        
        cancelButton.do {
            $0.setImage(.icCancelModal.withRenderingMode(.alwaysOriginal).withTintColor(.wssGray300), for: .normal)
        }
        
        tableView.do {
            $0.rowHeight = MyPageChangeUserBirthView.cellHeight
            $0.isScrollEnabled = true
            $0.showsVerticalScrollIndicator = false
        }
    }
    
    private func setHierarchy() {
        self.addSubview(contentView)
        contentView.addSubviews(tableView,
                                titleLabel,
                                cancelButton,
                                completeButton)
    }
    
    private func setLayout() {
        contentView.snp.makeConstraints {
            $0.leading.trailing.bottom.equalToSuperview()
            $0.height.equalTo(375)
        }
        
        titleLabel.snp.makeConstraints {
            $0.top.leading.equalToSuperview().inset(25)
        }
        
        cancelButton.snp.makeConstraints {
            $0.top.trailing.equalToSuperview()
            $0.size.equalTo(65)
        }
        
        tableView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.top.equalTo(cancelButton.snp.bottom).offset(10)
            $0.height.equalTo(MyPageChangeUserBirthView.cellHeight * 3)
        }
        
        completeButton.snp.makeConstraints {
            $0.bottom.equalTo(self.safeAreaLayoutGuide.snp.bottom).offset(-10)
        }
    }
}
