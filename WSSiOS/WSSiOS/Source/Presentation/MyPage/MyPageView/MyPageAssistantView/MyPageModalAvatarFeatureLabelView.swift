//
//  MyPageCustomModalLabelView.swift
//  WSSiOS
//
//  Created by 신지원 on 1/13/24.
//

import UIKit

import SnapKit
import Then

final class MyPageModalAvatarFeatureLabelView: UIView {
    
    //MARK: - UI Components
    
    private let stackView = UIStackView()
    public let modalAvaterBadgeImageView = UIImageView()
    public let modalAvaterTitleLabel = UILabel()
    
    
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
        self.do {
            $0.backgroundColor = .clear
            $0.layer.borderColor = UIColor.Gray100.cgColor
            $0.layer.borderWidth = 1
            $0.layer.cornerRadius = 26
        }
        
        stackView.do {
            $0.axis = .horizontal
            $0.alignment = .center
            $0.distribution = .fill
            $0.spacing = 6
            
            modalAvaterBadgeImageView.image = ImageLiterals.icon.Badge.logo
            
            modalAvaterTitleLabel.do {
                $0.text = "신지원 사랑해"
                $0.font = .HeadLine1
                $0.textColor = .Black
            }
        }
    }
    
    //MARK: - set Hierachy
    
    private func setHierachy() {
        self.addSubview(stackView)
        stackView.addArrangedSubviews(modalAvaterBadgeImageView,
                                      modalAvaterTitleLabel)
    }
    
    //MARK: - set Layout
    
    private func setLayout() {
        stackView.snp.makeConstraints() {
            $0.horizontalEdges.equalToSuperview().inset(20)
            $0.verticalEdges.equalToSuperview().inset(11)
        }
        
        modalAvaterBadgeImageView.snp.makeConstraints() {
            $0.size.equalTo(30)
        }
    }
}
