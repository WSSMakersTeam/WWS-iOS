//
//  TableViewCell.swift
//  WSSiOS
//
//  Created by 신지원 on 1/11/24.
//

import UIKit

import SnapKit
import Then

class MyPageInventoryCollectionViewCell: UICollectionViewCell {

    //MARK: - Properties
    
    static let identifier: String = "MyPageInventoryTableViewCell"
    
    //MARK: - UI Components
    
    private let avaterImageView = UIImageView()
    
    //MARK: - Life Cycle
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setUI()
        setHierachy()
        setLayout()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Set UI
    
    private func setUI() {
        avaterImageView.do {
            $0.layer.cornerRadius = 12
            $0.layer.masksToBounds = true
        }
    }
    
    //MARK: - Set Hierachy
    
    private func setHierachy() {
        self.addSubviews(avaterImageView)
    }
    
    //MARK: - Set Layout
    
    private func setLayout() {
        avaterImageView.snp.makeConstraints() {
            $0.edges.equalToSuperview()
        }
    }
    
    
    func bindData(_ selected: Bool) {
//        avaterImageView.image = UIImage(named: "exampleAvater")
        avaterImageView.layer.backgroundColor = UIColor.blue.cgColor

        if selected {
            avaterImageView.layer.borderColor = UIColor.Primary100.cgColor
            avaterImageView.layer.borderWidth = 1
        }else {
            avaterImageView.layer.borderColor = UIColor.Primary100.cgColor
            avaterImageView.layer.borderWidth = 1
        }
    }
}
