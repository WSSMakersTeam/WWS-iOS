//
//  StringLiterals.swift
//  WSSiOS
//
//  Created by 신지원 on 1/7/24.
//

import Foundation

enum StringLiterals {
    enum UserDefault {
        static let accessToken = "ACCESS_TOKEN"
        static let refreshToken = "REFRESH_TOKEN"
        static let userGender = "USER_GENDER"
        static let userNickname = "USER_NICKNAME"
        static let isRegister = "IS_REGISTER"
    }
    
    enum BirthPicker {
        static let title = "출생연도"
        static let completeButton = "완료"
    }
    
    enum Loading {
        static let loadingTitle = "로딩 중"
        static let loadingDescription = "잠시만 기다려주세요"
        static let novelTitle = "작품 제목"
        static let novelAuthor = "작품 작가"
        static let novelGenre = "작품 장르"
    }
    
    enum Error {
        static let title = "네트워크 연결에\n실패했어요"
        static let description = "연결 상태를 확인한 후\n다시 시도해 보세요"
        static let refreshButton = "페이지 다시 불러오기"
    }
    
    enum Tabbar {
        enum Title {
            static let home = "홈"
            static let search = "탐색"
            static let feed = "수다"
            static let myPage = "My"
        }
    }
    
    enum Navigation {
        enum Title {
            static let library = "내 서재"
            static let record = "내 기록"
            static let search = "검색"
            static let myPage = "마이페이지"
            static let changeNickname = "닉네임 변경"
            static let feed = "소소피드"
            static let notice = "알림"
            static let editProfile = "프로필 편집"
            static let deleteID = "회원탈퇴"
            static let myPageSetting = "설정"
            static let myPageInfo = "계정설정"
            static let myPageBlockUser = "차단유저 목록"
            static let myPageChangeUserInfo = "성별/나이 변경"
            static let isVisibleProfile = "프로필 공개 설정"
        }
    }
    
    enum Alert {
        static let logoutTitle = "로그아웃 할까요?"
        static let cancel = "취소"
        static let logout = "로그아웃"
    }
    
    enum Home {
        enum Title {
            static let todayPopular = "오늘의 인기작"
            static let realtimePopular = "지금 뜨는 수다글"
            static let interest = "님의 관심글"
            static let notLoggedInInterest = "관심글"
            static let recommend = "이 웹소설은 어때요?"
        }
        
        enum SubTitle {
            static let interest = "관심 등록한 작품의 최근 수다예요"
            static let recommend = "선호 장르를 기반으로 추천해드려요"
        }
        
        enum Login {
            static let induceTitle = "로그인하고 모든 기능을\n자유롭게 사용하세요!"
            static let loginButtonTitle = "로그인 하러가기"
            static let cancelButtonTitle = "닫기"
        }
        
        enum Unregister {
            enum Title {
                static let interest = "관심작품의 최신 소식을 모아서 볼 수 있어요.\n좋아하는 웹소설을 관심 등록 해볼까요?"
                static let recommend = "로맨스, 로판, 판타지, 현판 등\n선호장르를 기반으로 웹소설을 추천해드려요!"
                static let interestEmpty = "관심 등록한 작품과 관련된 글이 없어요"
            }
            
            enum ButtonTItle {
                static let interest = "관심작품 등록하기"
                static let recommend = "선호장르 설정하기"
            }
        }
        
        enum TodayPopular {
            static let feed = "님의 한마디"
            static let introduction = "작품 소개"
        }
        
        enum RealTimePopular {
            static let spoiler = "스포일러가 포함된 글 보기"
        }
        
        enum Interest {
            static let feed = "님의 한마디"
            static let empty = "관심 등록한 작품과 관련된 글이 없어요"
        }
    }
    
    enum Register {
        enum Normal {
            enum DatePicker {
                static let middle = "~"
                static let start = "시작 날짜"
                static let end = "종료 날짜"
                static let KoreaTimeZone = "ko_KR"
                static let dateFormat = "yyyy-MM-dd"
                static let complete = "완료"
            }
            
            enum SectionTitle {
                static let readStatus = "읽기 상태 *"
                static let readDate = "읽은 날짜"
                static let keyword = "키워드"
                static let plot = "작품 소개"
                static let genre = "장르"
                static let platform = "작품 보러가기"
            }
            
            enum Keyword {
                static let selectButton = "키워드 등록"
            }
            
            enum RegisterButton {
                static let new = "내 서재에 등록"
                static let edit = "수정 완료"
            }
        }
        
        enum Success {
            static let title = "내 서재에 작품이\n성공적으로 등록되었어요!"
            static let lottie = "animationRegistration"
            static let makeMemo = "작품에 메모 남기기"
            static let returnHome = "홈으로 돌아가기"
        }
    }
    
    
    enum MyPage {
        enum Modal {
            static let back = "돌아가기"
            static let baseTitle = "오늘 당신을 만날 걸 알고 있었어"
            static let baseExplanation = "메모를 작성해서 잠금해제 됐어요!"
            static let keepOriginally = "원래대로 유지하기"
            static let changeCharacter = "대표 캐릭터 설정하기"
        }
        
        enum Profile {
            static let registerNovel = "등록 작품"
            static let record = "기록"
            static let inventoryTitle = "보관함"
            static let preferenceEmpty = "취향 분석"
            static let preferenceEmptyLabel = "작품 취향을 파악할 수 없어요"
            static let genrePreferenceTitle = "장르 취향"
            static let novelPreferenceTitle = "작품 취향"
            static let novelPreferenceLabel = "가 매력적인 작품"
        }
        
        enum Character {
            static let select = "캐릭터 선택"
        }
        
        enum Setting: String, CaseIterable {
            case accountInfo = "계정정보"
            case profileStatus = "프로필 공개 여부 설정"
            case webSoso = "웹소소 공식 계정"
            case qNA = "문의하기 & 의견 보내기"
            case review = "개인정보 처리 방침"
            case termsOfService = "서비스 이용약관"
        }
        
        enum SettingURL {
            static let qnaURL = "http://pf.kakao.com/_kHxlWG"
            static let instaURL = "https://www.instagram.com/websoso_official/"
            static let termsURL = "https://kimmjabc.notion.site/4acd397608c146cbbf8dd4fe11a82e19"
            static let infoURL = "https://kimmjabc.notion.site/e55f0c0e95c249f7998f21563aefa4b4?pvs=4"
        }
        
        enum SettingInfo: String, CaseIterable {
            case changeProfile = "성별/나이 변경"
            case email = "이메일"
            case blockList = "차단유저 목록"
            case logout = "로그아웃"
            case secession = "회원탈퇴"
        }
        
        enum EditProfile {
            static let complete = "완료"
            static let nickname = "닉네임"
            static let nicknameCheck = "중복확인"
            static let intro = "소개"
            static let introPlaceholder = "소개글을 적어보세요!"
            static let genre = "선호장르"
            static let genreDescription = "선택한 장르에 맞춰 작품을 추천해 드려요"
        }
        
        enum EditProfileWarningMessage: String {
            case noGap = "공백은 포함될 수 없어요"
            case exist = "이미 사용 중인 닉네임이에요"
            case guid = "한글. 영문, 숫자 2~10자까지 입력가능해요"
            case noUse = "사용할 수 없는 단어가 포함되어 있어요"
        }
        
        enum BlockUser {
            static let buttonTitle = "차단 해제"
            static let emptyLabel = "차단한 유저가 없어요"
        }
        
        enum DeleteIDWarning {
            static let title = "정말 탈퇴하시겠어요?"
            static let description = "남겼던 평가와 기록들이 모두 사라져요.."
            static let buttonTitle = "탈퇴하기"
            
            static let interest = "관심"
            static let watching = "보는 중"
            static let watched = "봤어요"
            static let quit = "하차"
        }
        
        enum DeleteID {
            static let reasonTitle = "탈퇴사유를 알려주세요."
            static let reasonTitleColor = "탈퇴사유"
            static let reasonPlaceHolder = "위 항목 외의 탈퇴 사유를 자유롭게 작성해 주세요."
            static let checkTitle = "탈퇴하기 전에 확인해주세요"
            static let agreeTitle = "위 주의사항을 모두 확인했고, 탈퇴에 동의합니다."
        }
        
        enum DeleteIDReason: String, CaseIterable {
            case first = "자주 사용하지 않아서"
            case second = "이용이 불편하고 장애가 많아서"
            case third = "삭제하고 싶은 내용이 있어서"
            case fourth = " 원하는 작품이 없어서"
            case etc = "직접 입력"
        }
        
        enum DeleteIDCheckTitle: String, CaseIterable {
            case first = "삭제된 계정 정보는 복구할 수 없어요"
            case second = "게시글 및 댓글은 자동 삭제되지 않아요"
            case third = "처음부터 다시 가입해야 해요"
        }
        
        enum DeleteIDCheckContent: String, CaseIterable {
            case first = "회원님이 평가하고 기록한 서재 정보와 계정 정보는 탈퇴 즉시 삭제되며, 절대 복구할 수 없어요."
            case second = "리뷰, 피드 게시글, 댓글은 탈퇴 시 자동으로 삭제되지 않아요. 탈퇴 전 개별적으로 삭제해 주세요."
            case third = "계정 정보는 탈퇴 즉시 삭제되어 바로 재가입 가능하지만, 회원가입부터 작품 평가를 다시 해야 해요."
        }
        
        enum ChangeUserInfo {
            static let gender = "성별"
            static let male = "남성"
            static let female = "여성"
            static let birthYear = "출생연도"
            static let complete = "완료"
        }
        
        enum isVisiableProfile {
            static let completeTitle = "완료"
            static let isPrivateProfile = "비공개"
        }        
    }
    
    enum Library {
        static let empty = "아직 서재가 비어있네요!"
        static let register = "웹소설 등록하기"
    }
    
    enum Record {
        enum Empty {
            static let description = "읽은 웹소설에 대해\n기록을 남겨볼까요?"
            static let register = "웹소설 기록하기"
        }
    }
    
    enum TabBar: String, CaseIterable {
        case all = "전체"
        case finish = "읽음"
        case reading = "읽는 중"
        case drop = "하차"
        case wish = "읽고 싶음"
    }
    
    enum ReadStatus: String, CaseIterable {
        case all = "ALL"
        case finish = "FINISH"
        case reading = "READING"
        case drop = "DROP"
        case wish = "WISH"
    }
    
    enum Alignment {
        case newest, oldest
        
        var sortType: String {
            switch self {
            case .newest:
                return "NEWEST"
            case .oldest:
                return "OLDEST"
            }
        }
        
        var title: String {
            switch self {
            case .newest:
                return "최신 순"
            case .oldest:
                return "오래된 순"
            }
        }
        
        var lastId: Int {
            switch self {
            case .newest:
                return 999999
            case .oldest:
                return 0
            }
        }
        
        var sizeData: Int {
            return 500
        }
    }
    
    enum Onboarding {
        
        static let nextButton = "다음으로"
        
        enum Success {
            static let title = "웹소소와 계약 완료!"
            static func description(name: String) -> String {
                return "\(name)님, 만나서 반가워요!"
            }
            static let completeButton = "웹소소 시작하기"
        }
        
        enum GenrePreference {
            static let title = "평소 즐겨보는 장르를 선택하세요"
            static let description = "선호 장르를 기반으로 웹소설을 추천해드려요"
            static let completeButton = "완료"
            static let skipButton = "건너뛰기"
        }
        
        enum BirthGender {
            static let title = "성별, 출생연도를 선택하세요"
            static let description = "해당 정보는 추천에 활용되며, 언제든 변경할 수 있어요"
            static let genderTitle = "성별"
            static let birthTitle = "출생연도"
            static let birthPlaceholder = "태어난 해를 입력하세요"
        }
        
        enum NickName {
            static let title = "닉네임을 입력하세요"
            static let description = "10자 이내의 닉네임을 입력해주세요"
            static let textFieldPlaceholder = "닉네임"
            static let duplicateCheckButton = "중복확인"
        }
    
        enum Login {
            static let skip = "회원가입 없이 둘러보기"
        }
    }
    enum NovelDetail {
        enum Memo {
            static let memo = "메모"
            static let noMemo = "아직 작성된 메모가 없어요"
            static let newMemo = "새로운 메모를 작성해보세요"
        }
        
        enum Setting {
            static let novelDelete = "작품을 서재에서 삭제"
            static let novelEdit = "작품 정보 수정"
        }
        
        enum Header {
            static let complete = "  ·  완결작  ·  "
            static let inSeries = "  ·  연재중  ·  "
            static let interest = "관심"
            static let feedWrite = "나도 한마디"
            
            enum Loading {
                static let novelTitle = "작품 제목"
                static let novelAuthor = "작품 작가"
                static let novelGenre = "작품 장르"
                static let novelInterestCount = "0"
                static let novelRatingCount = "0.0 (0)"
                static let novelFeedCount = "0"
            }
        }
        
        enum Tab {
            static let info = "정보"
            static let feed = "수다"
        }
        
        enum Info {
            static let description = "작품 소개"
            static let platform = "작품 보러가기"
            static let reviewEmpty = "독자들의 평가"
            static let reviewEmptyDescription = "아직 평가가 없어요\n최초로 남겨보세요!"
            static let attractivePoint = "독자들의 감상평"
            static let attractivePointDescription = "(이)가 매력적인 작품이에요"
            static let readStatus = "명이 작품을\n"
            
            enum ReadStatus {
                static let watched = "봤어요"
                static let watching = "같이 보고 있어요"
                static let quit = "하차했어요"
            }
        }
        
        enum Feed {
            static let emptyDescription = "아직 글이 없어요\n최초로 남겨보세요!"
            
            enum Cell {
                static let isModified = "(수정됨)"
                static let isSpoiler = "스포일러가 포함된 글 보기"
            }
        }
    }
    
    enum NovelReview {
        enum Navigation {
            static let complete = "완료"
        }
        
        enum Status {
            static let watching = "보는 중"
            static let watched = "봤어요"
            static let quit = "하차"
        }
        
        enum Date {
            static let addDate = "날짜 추가"
            static let complete = "완료"
            static let removeDate = "날짜 삭제"
            static let startDate = "시작 날짜"
            static let endDate = "종료 날짜"
        }
        
        enum AttractivePoint {
            static let attractivePoint = "매력포인트"
        }
        
        enum Keyword {
            static let keyword = "키워드"
            static let placeholder = "키워드로 작품을 소개해 봐요"
        }
        
        enum KeywordSearch {
            static let keywordSelect = "키워드 선택"
            static let placeholder = "키워드를 검색하세요"
            static let searchResult = "검색결과"
            static let reset = "초기화"
            static let selectButtonText = "개 선택"
            static let unregisteredKeyword = "해당 키워드는\n아직 등록되지 않았어요.."
            static let contact = "키워드 문의하러 가기"
        }
        
        enum Alert {
            static let titleText = "평가를 그만할까요?"
            static let writeTitle = "계속 작성"
            static let stopTitle = "그만하기"
        }
    }
    
    enum Search {
        static let title = "탐색하기"
        static let searchbar = "작품 제목, 작가를 검색하세요"
        
        static let induceTitle = "뭐 읽을지 고민될 땐?"
        static let induceDescription = "장르, 연재상태, 별점, 키워드로 작품 찾기"
        static let induceButton = "내 취향에 맞는 웹소설 찾기"
        
        static let sosoTitle = "소소"
        static let sosoDescription = "다른 독자들이 최근에 읽고 있는 웹소설이에요"
        
        static let novel = "작품"
        
        enum Empty {
            static let description = "해당 검색어를 가진 작품은\n아직 등록되지 않았어요.."
            static let inquiryButton = "작품 문의하러 가기"
            static let kakaoChannelUrl = "https://pf.kakao.com/_kHxlWG"
        }
    }
    
    enum DetailSearch {
        static let info = "정보"
        static let keyword = "키워드"
        
        static let genre = "장르"
        
        static let serialStatus = "연재상태"
        static let statusIng = "연재중"
        static let statusFinished = "완결작"
        
        static let rating = "별점"
        static let ratingaboveThreePointFive = "3.5이상"
        static let ratingaboveFourPointZero = "4.0이상"
        static let ratingaboveFourPointFive = "4.5이상"
        static let ratingaboveFourPointEight = "4.8이상"
        
        static let reload = "초기화"
        static let searchNovel = "작품 찾기"
        
        static let world = "세계관"
        static let subject = "소재"
        static let character = "캐릭터"
        static let relation = "관계"
        static let vibe = "분위기/전개"
        
        static let placeHolder = "키워드를 검색하세요"
        
        static let empty = "해당하는 작품이 없어요\n검색의 범위를 더 넓혀보세요"
    }
    
    enum Memo {
        static let complete = "완료"
        static let edit = "수정"
    }
    
    enum FeedEdit {
        static let complete = "완료"
        static let edit = "수정"
        enum Category {
            static let category = "카테고리"
            static let multipleSelect = "중복 선택 가능"
        }
        enum Content {
            static let writeContent = "내용 작성하기"
            static let spoiler = "스포일러"
            static let placeHolder = "피드 작성 유의사항!\n\n욕설, 비방 등 상대방을 불쾌하게 하는 의견은\n작품 내용을 담은 글은 스포일러 체크해주세요."
        }
        enum Novel {
            static let novelConnect = "작품 연결하기"
            static let novelSearch = "작품 제목, 작가를 검색하세요"
            static let novelSelect = "작성 중인 글과 관련된 웹소설을 선택하세요"
            static let connectSelectedNovel = "해당 작품 연결"
        }
        enum Alert {
            static let titleText = "글 작성을 그만하시겠어요?"
            static let writeTitle = "계속 작성"
            static let stopTitle = "그만하기"
        }
    }
    
    enum DeletePopup {
        enum MemoEditCancel {
            static let titleText = "작성을 취소할까요?"
            static let descriptionText = "작성 중인 내용이 모두 사라져요!"
        }
        
        enum MemoDelete {
            static let titleText = "메모를 삭제하실 건가요?"
            static let descriptionText = "삭제한 메모는 다시 되돌릴 수 없어요!"
        }
        
        enum NovelDelete {
            static let titleText = "이 작품을 삭제하실 건가요?"
            static let descriptionText = "읽기 정보와 작성한 메모가 모두 사라져요!\n삭제한 내용은 절대 되돌릴 수 없어요ㅠ"
        }
        
        enum DeleteButtonText {
            static let exit = "나가기"
            static let delete = "삭제하기"
        }
        
        enum CancelButtonText {
            static let keepWriting = "계속 작성하기"
            static let cancel = "취소"
        }
    }
    
    enum Feed {
        static let spoilerText = "스포일러가 포함된 글 보기"
        static let modifiedText = "(수정됨)"
    }
    
    enum FeedDetail {
        static let title = "수다글"
        static let reply = "댓글"
        static let placeHolder = "댓글을 남겨보세요"
        
        static let edit = "수정하기"
        
        static let delete = "삭제하기"
        static let deleteTitle = "해당 글을 삭제할까요?"
        static let deleteContent = "삭제한 글은 되돌릴 수 없어요"
        
        static let cancel = "취소"
        static let report = "신고"
        static let confirm = "확인"
        
        static let reportSpoiler = "스포일러 신고"
        static let spoilerTitle = "해당 글이 스포일러를 포함하고 있나요?"
        
        static let reportImpertinence = "부적절한 표현 신고"
        static let impertinentTitle = "해당 글에 부적절한 표현이\n사용되었나요?"
        static let impertinentContent = "해당 글이 커뮤니티 가이드를\n위반했는지 검토할게요"
        
        static let reportResult = "신고가 접수되었어요!"
        
        static let deleteMineTitle = "내 댓글을 삭제할까요?"
        static let deleteMineContent = "삭제한 댓글은 되돌릴 수 없어요"
        
        static let deleteAccountUserNickname = "(알 수 없음)"
        static let hiddenComment = "숨김 처리된 댓글"
        static let spoilerComment = "스포일러가 포함된 댓글 보기"
        static let blckedUser = "차단한 유저"
        static let blockedComment = "차단한 유저의 댓글"
    }
}
