//
//  model.swift
//  1to50
//
//  Created by dream on 2023/08/30.
//

import Foundation
import SQLite3
import UIKit

// 유저 프로필 구조체
struct User : Codable {
    var id: Int64
    var userID: String
    var userPWD: String
    var createdDate: String
    var highScore: Double
}

// 기본베이스설정
class BaseViewController: UIViewController {

    // 전역변수 설정
    static let shared = BaseViewController()
    
    // 결과 튜플
    var myResult: (Bool, String) = (false, "Init Result")
    
    // 로그인 유저 정보 저장 장소
    var userProfile: User?
    
    // DB class 접근
    let databaseManager = DatabaseManager.shared
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    /**
     비밀번호 정규표현식 확인
     최소 8자에서 20자까지의 길이를 가져야 합니다.
     적어도 하나의 알파벳 (대소문자 구분)
     적어도 하나의 숫자
     적어도 하나의 특수 문자 (여기서는 @, $, !, %, *, #, ?, &)를 가져야 합니다.
     */
    func isPasswordValid(_ password: String) -> Bool {
        let passwordRegex = "^(?=.*[A-Za-z])(?=.*\\d)(?=.*[@$!%*#?&])[A-Za-z\\d@$!%*#?&]{8,20}$"
        let passwordTest = NSPredicate(format: "SELF MATCHES %@", passwordRegex)
        return passwordTest.evaluate(with: password)
    }
    
    /// Description
    /// - Parameter number: ["LoginViewController", "CreateAccountViewController", "MainViewController", "ProfileViewController", "RankingViewController", "GameViewController", "ChangePWViewController"]
    func moveView(index: Int) {
        let identifiers = ["LoginViewController", "CreateAccountViewController", "MainViewController", "ProfileViewController", "RankingViewController", "GameViewController", "ChangePWViewController"]
        
        guard let VC = storyboard?.instantiateViewController(withIdentifier: identifiers[index]) else {return}
        
        self.navigationController?.pushViewController(VC, animated: true)
//        let mainVC = storyboard?.instantiateViewController(withIdentifier: identifiers[index])
//        
//        show(mainVC!, sender: nil)
    }
    
    // 화면에 출력하는코드
    func showToast(message: String) {
        let alertController = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        present(alertController, animated: true, completion: nil)

        // 지정된 시간(여기서는 1.5초) 후에 자동으로 닫히도록 설정
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1.5) {
            alertController.dismiss(animated: true, completion: nil)
        }
    }
}

class CustomStackView: UIStackView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupStackView()
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupStackView()
    }
    
    private func setupStackView() {
        backgroundColor = UIColor.white
        
        layer.borderWidth = 3
        layer.borderColor = UIColor.black.cgColor
        layer.cornerRadius = 20
    }
}

class CustomButton: UIButton {
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupButton()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupButton()
    }
    
    private func setupButton() {
        backgroundColor = UIColor(red: 1.0, green: 0.976, blue: 0.564, alpha: 1.0)  // 색상은 프로젝트에서 정의한 것으로 변경
        
        layer.borderWidth = 3
        layer.borderColor = UIColor.black.cgColor
        
        layer.cornerRadius = 20
        contentEdgeInsets = UIEdgeInsets(top: 7, left: 7, bottom: 7, right: 7)
    }
}

class CustomTextField: UITextField {
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupTextField()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupTextField()
    }
    
    private func setupTextField() {
        backgroundColor = UIColor.white  // 색상은 프로젝트에서 정의한 것으로 변경
        
        layer.borderWidth = 3
        layer.borderColor = UIColor.black.cgColor
        layer.cornerRadius = 20
        
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: frame.height))
        leftView = paddingView
        leftViewMode = ViewMode.always
        
        autocorrectionType = .no
    }
}

class CustomLabel: UILabel {
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupTextField()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupTextField()
    }
    
    private func setupTextField() {
        backgroundColor = UIColor.white  // 색상은 프로젝트에서 정의한 것으로 변경
        
        layer.borderWidth = 3
        layer.borderColor = UIColor.black.cgColor
        
        layer.cornerRadius = 20
    }
}
// 비밀번호 눈알버튼 클릭 시 설정
extension UITextField {
    
    func secureToggleActions(_ button: UIButton, mode: UITextField.ViewMode) {
        button.contentMode = .scaleAspectFit
        button.addTarget(self, action: #selector(UITextField.secureToggleAction(_:)), for: .touchUpInside)
        self.rightView = button
        self.rightViewMode = .always
    }
    
    // password show/hide 버튼 액션
    @objc func secureToggleAction(_ button: UIButton) {
        
        button.isSelected.toggle()
        
        isSecureTextEntry.toggle()
        
        // 값 초기화 후 다시 채워주기
        if let existingText = text, isSecureTextEntry {
            deleteBackward()
            text = existingText
        }
        
        // 포커스 맞추기
        if let existingSelectedTextRange = selectedTextRange {
            selectedTextRange = nil
            selectedTextRange = existingSelectedTextRange
        }
    }
    
    // 버튼 클릭 시 secureToggleAction 액션 실행
    func secureToggle(_ button: UIButton) {
        button.addTarget(self, action: #selector(secureToggleAction), for: .touchUpInside)
    }
    
    
}

