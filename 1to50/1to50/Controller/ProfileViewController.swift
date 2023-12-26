//
//  ProfileViewController.swift
//  1to50
//
//  Created by dream on 2023/10/16.
//

class ProfileViewController: BaseViewController {

    // 유저 아이디
    @IBOutlet weak var userIDLabel: CustomLabel!
    
    // 최고점수
    @IBOutlet weak var highScoreLabel: CustomLabel!
    
    var baseVC = BaseViewController.shared
    
    // 화면이 로드 되었을때 실행되는 함수입니다.
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 유저아이디 표시
        userIDLabel.text = baseVC.userProfile!.userID
        userIDLabel.sizeToFit()
        
        // 최고기록 표시
        if baseVC.userProfile!.highScore == 9999.99 {
            highScoreLabel.text = "기록 없음"
        } else {
            highScoreLabel.text = "\(Float(baseVC.userProfile!.highScore))"
        }
       
    }
    
    @IBAction func clickChangePWBtn(_ sender: Any) {
        moveView(index: 6)
    }
    
    // 로그아웃버튼 클릭 시
    @IBAction func logoutBtn(_ sender: Any) {
        // 매인화면으로 이동
        moveView(index: 0)
    }
    
}
