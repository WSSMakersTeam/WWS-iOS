//
//  BannerImageView.swift
//  WSSiOS
//
//  Created by 이윤학 on 1/6/24.
//

import UIKit

import SnapKit
import Then
import UIImageViewAlignedSwift

final class RegisterNormalBannerImageView: UIView {
    
    // MARK: - UI Components
    
    private let bannerImageView = UIImageViewAligned()
    private let gradientView = UIImageView()
    
    // MARK: - Life Cycle
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setHieararchy()
        setUI()
        setLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Custom Method
    
    private func setUI() {
        bannerImageView.do {
            $0.image = .registerNormalNovelCover//.applyBannerImageBlur(radius: 16)

            $0.contentMode = .scaleAspectFill
            $0.alignment = .top
            $0.clipsToBounds = true
        }
        gradientView.do {
            $0.contentMode = .scaleAspectFill
            $0.clipsToBounds = true
            $0.image = .registerNormalGradientDummy
        }
    }
    
    private func setHieararchy() {
        self.addSubview(bannerImageView)
        bannerImageView.addSubview(gradientView)
    }
    
    private func setLayout() {
        bannerImageView.snp.makeConstraints {
            $0.edges.equalToSuperview()
            $0.height.equalTo(251)
        }
        
        gradientView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
}
