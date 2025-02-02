//
//  HomeTodayPopularCollectionViewCell.swift
//  WSSiOS
//
//  Created by Seoyeon Choi on 4/15/24.
//

import UIKit

final class HomeTodayPopularCollectionViewCell: UICollectionViewCell {
    
    //MARK: - UI Components
    
    /// 소설 정보
    private let backgroundImageView = UIImageView()
    private let bestTagImageView = UIImageView()
    private let novelTitleLabel = UILabel()
    private let novelImageView = UIImageView()
    
    /// 유저 피드 글 정보
    private let blurBackgroundView = UIView()
    private let userProfileView = UIImageView()
    private let introductionImageView = UIImageView()
    private let commentTitleLabel = UILabel()
    private let commaStartedImageView = UIImageView()
    private let commaFinishedImageView = UIImageView()
    private let commentContentLabel = UILabel()
    
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
        backgroundImageView.do {
            $0.image = .imgTodayPopularBackground
            $0.contentMode = .scaleAspectFit
            $0.layer.cornerRadius = 14
            $0.clipsToBounds = true
        }
        
        bestTagImageView.do {
            $0.image = .imgBest
        }
        
        novelTitleLabel.do {
            $0.textColor = .wssBlack
            $0.numberOfLines = 1
        }
        
        novelImageView.do {
            $0.image = .imgLoadingThumbnail
            $0.layer.cornerRadius = 9
            $0.layer.shadowColor = UIColor.wssBlack.cgColor
            $0.layer.shadowOpacity = 0.1
            $0.layer.shadowRadius = 15.44
            $0.layer.shadowOffset = CGSize(width: 0, height: 2.06)
            $0.contentMode = .scaleAspectFill
            $0.clipsToBounds = true
        }
        
        blurBackgroundView.do {
            $0.frame = UIScreen.main.bounds
            $0.backgroundColor = .wssWhite.withAlphaComponent(0.3)
            let blurEffect = UIBlurEffect(style: .regular)
            let visualEffectView = UIVisualEffectView(effect: blurEffect)
            visualEffectView.frame = $0.bounds
            $0.addSubview(visualEffectView)
        }
        
        userProfileView.do {
            $0.layer.cornerRadius = 8
            $0.contentMode = .scaleAspectFill
            $0.clipsToBounds = true
        }
        
        introductionImageView.do {
            $0.image = .icIntroduction
            $0.contentMode = .scaleAspectFit
        }
        
        commentTitleLabel.do {
            $0.textColor = .wssGray300
        }
        
        commaStartedImageView.do {
            $0.image = .icCommasStarted
        }
        
        commaFinishedImageView.do {
            $0.image = .icCommasFinished
        }
        
        commentContentLabel.do {
            $0.textColor = .wssGray300
            $0.numberOfLines = 3
        }
    }
    
    private func setHierarchy() {
        self.addSubview(backgroundImageView)
        backgroundImageView.addSubviews(bestTagImageView,
                                        novelTitleLabel,
                                        novelImageView,
                                        blurBackgroundView)
        blurBackgroundView.addSubviews(userProfileView,
                                       introductionImageView,
                                       commentTitleLabel,
                                       commaStartedImageView,
                                       commentContentLabel,
                                       commaFinishedImageView)
    }
    
    private func setLayout() {
        backgroundImageView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        bestTagImageView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(20)
            $0.centerX.equalToSuperview()
        }
        
        novelTitleLabel.snp.makeConstraints {
            $0.top.equalTo(bestTagImageView.snp.bottom).offset(7)
            $0.centerX.equalToSuperview()
            $0.horizontalEdges.equalToSuperview().inset(20)
        }
        
        novelImageView.snp.makeConstraints {
            $0.top.equalTo(novelTitleLabel.snp.bottom).offset(15)
            $0.centerX.equalToSuperview()
            $0.width.equalTo(127)
            $0.height.equalTo(188)
        }
        
        blurBackgroundView.snp.makeConstraints {
            $0.height.equalTo(139)
            $0.bottom.equalToSuperview()
            $0.leading.trailing.equalToSuperview()
        }
        
        userProfileView.snp.makeConstraints {
            $0.top.leading.equalToSuperview().offset(18)
            $0.size.equalTo(24)
        }
        
        introductionImageView.snp.makeConstraints {
            $0.top.leading.equalToSuperview().offset(18)
            $0.size.equalTo(18)
        }
        
        commentTitleLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(19)
            $0.leading.equalTo(userProfileView.snp.trailing).offset(10)
        }
        
        commaStartedImageView.snp.makeConstraints {
            $0.top.equalTo(commentTitleLabel.snp.bottom).offset(16)
            $0.leading.equalToSuperview().inset(18)
        }
        
        commentContentLabel.snp.makeConstraints {
            $0.top.equalTo(commaStartedImageView.snp.top)
            $0.leading.equalTo(commaStartedImageView.snp.trailing).offset(6)
            $0.width.equalTo(204)
        }
        
        commaFinishedImageView.snp.makeConstraints {
            $0.bottom.equalToSuperview().inset(24)
            $0.leading.equalTo(commentContentLabel.snp.trailing).offset(6)
        }
    }
    
    func bindData(data: TodayPopularNovel) {
        self.novelTitleLabel.do {
            $0.applyWSSFont(.title2, with: data.title)
            $0.lineBreakMode = .byTruncatingTail
            $0.textAlignment = .center
        }
        self.novelImageView.kfSetImage(url: data.novelImage)
        
        if let avatarImage = data.avatarImage {
            self.userProfileView.kfSetImage(url: makeBucketImageURLString(path: avatarImage))
            self.userProfileView.isHidden = false
            self.introductionImageView.isHidden = true
            
            self.commentTitleLabel.snp.remakeConstraints {
                $0.top.equalTo(userProfileView.snp.top)
                $0.leading.equalTo(userProfileView.snp.trailing).offset(10)
            }
        }
        else {
            self.userProfileView.isHidden = true
            self.introductionImageView.isHidden = false
            
            self.commentTitleLabel.snp.remakeConstraints {
                $0.top.equalTo(introductionImageView.snp.top).offset(-2)
                $0.leading.equalTo(introductionImageView.snp.trailing).offset(8)
            }
        }
        
        self.commentTitleLabel.do {
            if let nickname = data.nickname {
                $0.applyWSSFont(.title2, with: "\(nickname)\(StringLiterals.Home.TodayPopular.feed)")
            }
            else {
                $0.applyWSSFont(.title2, with: StringLiterals.Home.TodayPopular.introduction)
            }
        }
        self.commentContentLabel.do {
            $0.applyWSSFont(.label1, with: data.feedContent)
            $0.lineBreakStrategy = .hangulWordPriority
            $0.lineBreakMode = .byTruncatingTail
        }
    }
}
