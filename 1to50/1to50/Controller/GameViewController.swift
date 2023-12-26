//
//  ViewController.swift
//  1to50
//
//  Created by dream on 2023/08/21.
//

import UIKit

class GameViewController: BaseViewController,
                          UICollectionViewDataSource,
                          UICollectionViewDelegate,
                          UICollectionViewDelegateFlowLayout, ModalDelegate {
    
    // cell
    @IBOutlet weak var collectionView: UICollectionView!

    // 타이머
    @IBOutlet weak var timerLabel: UILabel!
    
    // 현재 숫자
    @IBOutlet weak var currentNumberLabel: UILabel!

    
    @IBOutlet weak var loadingNumber: UIImageView!
    
    
    // 게임숫자
    var gameNumbers: [String] = []
    
    // 현재 숫자
    var currentNumber:Int = 1
    
    // 25이후 숫자
    var numberAfter25: [String] = []
    
    // 전역변수
    let baseVC = BaseViewController.shared
    
    weak var delegate: SendDataDelegate?
    
    // 타이머
    var timer: Timer?
    
    // 카운터
    var counter: Double = 0.00
    
    // 시작 카운터
    var loadCounter: Int = 0
    
    // 화면이 로드 되었을때 실행되는 함수입니다.
    override func viewDidLoad() {
        super.viewDidLoad()
        let backgroundImage = UIImage(named: "MainLogo")
        let backgroundImageView = UIImageView(image: backgroundImage)
        backgroundImageView.contentMode = .scaleAspectFill // 이미지의 크기에 맞게 조절
        backgroundImageView.alpha = 0.3
        // 배경 이미지를 UICollectionView의 backgroundView로 설정
        collectionView.backgroundView = backgroundImageView

        collectionView.dataSource = self
        collectionView.delegate = self
        
        
        // mode가 0이면 기본 1이면 카운트다운 ON
        
        readyGame(mode: 1)
    }
    
    // 숫자를 랜덤으로 섞어주는 함수 입니다.
    func readyGame(mode: Int) {
        collectionView.isHidden = true
        
        // 배열 초기화
        gameNumbers = []
        numberAfter25 = []
        
        // gameNumber에 1~25까지 추가후 섞기
        for number in 1...25 {
            gameNumbers.append(String(number))
        }
        gameNumbers.shuffle()
        
        // numberAfter25에 26~50 추가후 섞기
        for number in 26...50 {
            numberAfter25.append(String(number))
        }
        numberAfter25.shuffle()
        
        // gameNumber에 numberAfter25 추가해주기
        for number in 0...24 {
            gameNumbers.append(numberAfter25[number])
        }
        
        // 타이머 중지
        timer?.invalidate()
        
        loadingNumber.image = UIImage(named: "3")
        // 시작 카운터 초기화
        loadCounter = 3
        
        // 시작라벨 보이게하기
        loadingNumber.isHidden = false
        
        // 카운트 다운 시작 1초마다 updateLoadLabel함수 호출
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateLoadLabel), userInfo: nil, repeats: true)
        
    }
    
    /**
     게임 초기화 함수
     */
    func startGame() {
        
        // collectionView(게임화면) 보이게
        collectionView.isHidden = false
        
        // 1초마다 updateCounter함수 호출
        timer = Timer.scheduledTimer(timeInterval: 0.01, target: self, selector: #selector(updateCounter), userInfo: nil, repeats: true)
        
        // 현재 숫자 초기화
        currentNumber = 1
        currentNumberLabel.text = "1"
        
        // 점수판 초기화
        counter = 0
        timerLabel.text = "0"
        
        // collectionView 리로드
        collectionView.reloadData()
    }

    // 리셋 버튼
    @IBAction func resetBtn(_ sender: Any) {
        readyGame(mode: 0)
    }
    
    // 타이머에 의해 1초마다 호출되는 코드
    @objc func updateCounter() {
        counter += 0.01
        timerLabel.text = String(format: "%.2f", counter)
    }
    
    @objc func updateLoadLabel() {
        
        // 함수가 끝날때마다 카운트 1감소
        loadCounter -= 1
        
        // 카운트가 0보다 크면 카운트 출력
        if loadCounter > 0 {
            loadingNumber.image = UIImage(named: "\(loadCounter)")
        // 카운트가 0이면 "Start!" 출력
        } else if loadCounter == 0 {
            loadingNumber.image = UIImage(named: "start")
        // 카운트가 0보다 작으면
        } else if loadCounter < 0 {
            // 타이머 중지
            timer?.invalidate()
            
            // 카운트다운 라벨 숨기기
            loadingNumber.isHidden = true
            
            // 카운트다운 라벨 숫자 초기화
            loadingNumber.image = UIImage(named: "3")
            
            // 게임시작 함수 호출
            startGame()
        }
    }
    
    // cell 갯수 리턴
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 25
    }
    
    // cell 숫자 설정
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! Cell
        
        let number = gameNumbers[indexPath.item]
        cell.update(with: number)
        
        return cell
    }
    
    // cell 클릭했을때
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // 선택한셀의 숫자를 가져오는 작업
        let selectCell = collectionView.cellForItem(at: indexPath) as! Cell
        let selectedNumber:String = selectCell.numberLabel.text!
        // 선택한 숫자가 현재 숫자와 같을 떄
        if selectedNumber == "\(currentNumber)" {
            // 50을 누르면 타이머 종료
            if currentNumber == 50 {
                timer?.invalidate()
                timer = nil
                // 최고 기록 달성시
                if baseVC.userProfile!.highScore > counter {
                    // DB에 저장
                    databaseManager.highScoreSave(userID: baseVC.userProfile!.userID as NSString, newScore: counter, result: &myResult)
                    baseVC.userProfile!.highScore = counter
                }
                databaseManager.scoreSave(userID: baseVC.userProfile!.userID as NSString, score: counter, result: &myResult)
                end()
            }
            
            // 현재 숫자가 26보다 작을 시, 숫자와 색깔을 바꿔준다.
            if currentNumber < 26 {
                selectCell.numberLabel.text = gameNumbers[currentNumber+24]
                selectCell.numberLabel.backgroundColor = UIColor.systemIndigo
            // 25보다 클 시, 빈칸으로 변경
            } else if currentNumber > 25 {
                selectCell.numberLabel.text = ""
                selectCell.numberLabel.backgroundColor = UIColor.clear
                selectCell.numberLabel.layer.borderColor = UIColor.clear.cgColor
            }
            // 현재 숫자 증가
            currentNumber += 1
            currentNumberLabel.text = "\(currentNumber)"
        } else {
            print("틀림\(selectedNumber)", currentNumber)
        }
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
            let collectionViewWidth = collectionView.frame.width
            let cellWidth = collectionViewWidth / 5 // 5분의 1로 설정
            let cellHeight = cellWidth
            return CGSize(width: cellWidth, height: cellHeight)
        }
    
    func end() {
        
        // "Main"은 여러분의 스토리보드 이름입니다.
        guard let gameResultVC = storyboard?.instantiateViewController(withIdentifier: "GameResutlViewController") as? GameResultViewController else {return}
        gameResultVC.modalPresentationStyle = .overCurrentContext
        gameResultVC.delegate = self
        gameResultVC.count = counter
        gameResultVC.modalTransitionStyle = .crossDissolve
        
        // 네비게이션 컨트롤러를 모달로 표시
        self.present(gameResultVC, animated: true) {
            self.navigationController?.popViewController(animated: false)
        }
    }
    
    func didDismissModal() {
        readyGame(mode: 0)
    }
    
    
}

protocol ModalDelegate: AnyObject {
    func didDismissModal()
}

class Cell: UICollectionViewCell {
    @IBOutlet weak var numberLabel: UILabel!
    
    // 셀 텍스트 지정, 셀 컬러 지정
    func update(with number: String) {
        numberLabel.text = number
        numberLabel.backgroundColor = UIColor.link
        
        // 라벨 테두리 설정
        numberLabel.layer.borderWidth = 4.0
        numberLabel.layer.cornerRadius = 10.0
        numberLabel.layer.borderColor = UIColor.black.cgColor
        // 라벨의 경계 내부에서만 배경색이 보이도록
        numberLabel.clipsToBounds = true
    }
}
