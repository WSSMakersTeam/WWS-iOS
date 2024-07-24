//
//  File.swift
//  WSSiOS
//
//  Created by 신지원 on 7/24/24.
//

import UIKit

import SnapKit
import Then

final class MyPageDeleteIDReasonTableViewCell: UITableViewCell {
    
    //MARK: - Components
    
    private let checkButton = UIButton()
    private let titleLabel = UILabel()
    
    //MARK: - Life Cycle
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
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
        
        checkButton.do {
            $0.setImage(.checkDefault, for: .normal)
        }
        
        titleLabel.do {
            $0.textColor = .wssBlack
        }
    }
    
    private func setHierarchy() {
        self.addSubviews(checkButton,
                         titleLabel)
    }
    
    private func setLayout() {
        checkButton.snp.makeConstraints {
            $0.leading.centerY.equalToSuperview()
            $0.size.equalTo(24)
        }
        
        titleLabel.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.equalTo(checkButton.snp.trailing).offset(8)
        }
    }
    
    //MARK: - Custom Method
    
    func isSeleted(isSeleted: Bool) {
        checkButton.setImage( isSeleted ? .checkSelected : .checkDefault , for: .normal)
    }
    
    //MARK: - Data
    
    func bindData(text: String) {
        titleLabel.applyWSSFont(.body2, with: text)
    }
}

