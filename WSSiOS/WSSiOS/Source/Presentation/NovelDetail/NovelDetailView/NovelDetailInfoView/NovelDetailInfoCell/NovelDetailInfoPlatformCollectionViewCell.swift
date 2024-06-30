//
//  NovelDetailInfoPlatformCollectionViewCell.swift
//  WSSiOS
//
//  Created by 이윤학 on 6/27/24.
//

import UIKit

import SnapKit
import Then

final class NovelDetailInfoPlatformCollectionViewCell: UICollectionViewCell {
    
    //MARK: - UI Components
    
    private let platformImageView = UIImageView()
    
    //MARK: - Life Cycle
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setUI()
        setHierarchy()
        setLayout()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - UI
    
    private func setUI() {
        platformImageView.do {
            $0.contentMode = .scaleAspectFill
            $0.layer.cornerRadius = 12
            $0.clipsToBounds = true
        }
    }
    
    private func setHierarchy() {
        self.addSubview(platformImageView)
    }
    
    private func setLayout() {
        platformImageView.snp.makeConstraints {
            $0.edges.equalToSuperview()
            $0.size.equalTo(48)
        }
    }
    
    func bindData(data: Platform) {
        platformImageView.image = UIImage(named: data.platformImage)
    }
}
