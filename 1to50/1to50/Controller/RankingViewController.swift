//
//  RankingViewController.swift
//  1to50
//
//  Created by dream on 2023/10/10.
//

import UIKit


class RankignViewController : BaseViewController, UITableViewDelegate, UITableViewDataSource {
    
    // 테이블 뷰(랭킹 뷰)
    @IBOutlet weak var myTableView: UITableView!
    
    // 전체랭킹버튼
    @IBOutlet weak var globalRanking: UIButton!
    
    // 나의기록버튼
    @IBOutlet weak var myRanking: UIButton!
    
    // 전역변수
    var baseVC = BaseViewController.shared
    
    // 화면이 로드 되었을때 실행되는 함수입니다.
    override func viewDidLoad() {
        myTableView.dataSource = self
        myTableView.delegate = self
        myRanking.isSelected.toggle()
        databaseManager.getTop100User(isGlobal: true, userID: baseVC.userProfile!.userID)
    }
    
    // 전체랭킹버튼을 눌렀을 때 실행되는 함수입니다.
    @IBAction func top100UserBtn(_ sender: Any) {
        if !globalRanking.isSelected {
            return
        }
        
        
        
        // 전체랭킹버튼이 선택되어 있으면
        if globalRanking.isSelected {
            // 전체TOP100를 가져온다
            databaseManager.getTop100User(isGlobal: true, userID: baseVC.userProfile!.userID)
            // 테이블뷰 리로드
            myTableView.reloadData()
        }

        // 버튼 선택 뒤바꿔 주기
        globalRanking.isSelected.toggle()
        myRanking.isSelected.toggle()
    }
    
    // 나의기록버튼을 눌렀을 때 실행되는 함수입니다.
    @IBAction func top100myRanking(_ sender: Any) {
        if !myRanking.isSelected {
            return
        }

        // 나의 기록이 선택되어 있으면
        if myRanking.isSelected {
            // 나의 기록 TOP100개를 가져온다
            databaseManager.getTop100User(isGlobal: false, userID: baseVC.userProfile!.userID)
            // 테이블뷰 리로드
            myTableView.reloadData()

        }
        // 버튼 선택 뒤바꿔 주기
        globalRanking.isSelected.toggle()
        myRanking.isSelected.toggle()
    }
    
    // 테이블뷰 셀의 갯수 반환
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // DB의 갯수가 100개 이하이면
        if databaseManager.top100User.count < 100 {
            // DB 개수 만큼 반환
            return databaseManager.top100User.count
        } else {
            // 100개 반환
            return 100
        }
    }
    
    // 테이블뷰 셀 내용
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "RankingCell", for: indexPath) as! RankingTableView
        
        let rankingNumber = indexPath.row
        cell.updateWithRankingNumber(with: rankingNumber)
        
        return cell
    }
    
    // 테이블뷰 셀 선택했을 때 아무것도 안하게 nil를 반환해줍니다.
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        return nil
    }
    
}


class RankingTableView: UITableViewCell {
    
    // 순위 라벨
    @IBOutlet weak var ranking: UILabel!
    
    // 유저 아이디 라벨
    @IBOutlet weak var userIDTextLabel: UILabel!
    
    // 유저 점수 라벨
    @IBOutlet weak var userScoreTextLabel: UILabel!
      
    // DB클래스 연결
    let databaseManager = DatabaseManager.shared
    
    // 라벨 텍스트 변경
    func updateWithRankingNumber(with RankingNumber: Int) {
        ranking.text            = "\(RankingNumber+1)"
        userIDTextLabel.text    = databaseManager.top100User[RankingNumber]
        userScoreTextLabel.text = "\(databaseManager.top100Score[RankingNumber])"
    }
}
