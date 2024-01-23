//
//  MyPageTallyReuseView.swift
//  WSSiOS
//
//  Created by 신지원 on 1/10/24.
//

import UIKit

import SnapKit
import Then

final class MyPageTallyReuseView: UIView {
    
    //MARK: - UI Components
    
    let titleView = UIStackView()
    let titleIconImageView = UIImageView()
    let titleLabel = UILabel()
    let tallyLabel = UILabel()
    
    // MARK: - Life Cycle
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setUI()
        setHierachy()
        setLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - set UI
    
    private func setUI() {
        self.backgroundColor = .clear
        
        titleView.do {
            $0.axis = .horizontal
            $0.alignment = .center
            $0.distribution = .fill
            $0.spacing = 4
            
            titleLabel.do {
                $0.font = .Body2
                $0.textColor = .Gray300
            }
        }
        
        tallyLabel.do {
            $0.font = .Title1
            $0.textColor = .Black
        }
    }
    
    //MARK: - set Hierachy
    
    private func setHierachy() {
        self.addSubviews(titleView,
                         tallyLabel)
        titleView.addArrangedSubviews(titleIconImageView,
                                      titleLabel)
    }
    
    //MARK: - set Layout
    
    private func setLayout() {
        titleView.snp.makeConstraints() {
            $0.top.centerX.equalToSuperview()
            
            titleIconImageView.snp.makeConstraints() {
                $0.size.equalTo(18)
            }
        }
        
        tallyLabel.snp.makeConstraints() {
            $0.top.equalTo(titleView.snp.bottom).offset(4)
            $0.centerX.equalToSuperview()
            $0.bottom.equalToSuperview().inset(5)
        }
    }
}
