//
//  DBManager.swift
//  1to50
//
//  Created by dream on 2023/09/15.
//

import Foundation
import SQLite3

//SQLite 코드
class DatabaseManager {
    
    // 전역변수 설정
    static let shared = DatabaseManager()
    
    // db를 가리키는 포인터
    var db : OpaquePointer?
    
    // db 이름은 항상 "DB이름.sqlite" 형식으로 해줄 것.
    let databaseName = "mydb.sqlite"
    
    // 쿼리문
    var query:String = ""
    
    // SQLite 데이터베이스에서 SQL 쿼리를 실행할 때 사용되는 구문을 나타내는 객체
    var statement: OpaquePointer? = nil
    
    // top100유저 이름
    var top100User = [String]()
    
    // top100유저의 점수
    var top100Score = [Float]()
    
    deinit {
        sqlite3_close(db)
    }
    
    init() {
        // DB 열기
        if sqlite3_open(getDatabasePath(), &db) == SQLITE_OK {
            print("Successfully created DB. Path: \(getDatabasePath())")
            createTable()
            createScoreTable()
        }
    }
    
    /**
     데이터베이스 파일 경로를 반환하는 함수입니다.
     */
    private func getDatabasePath() -> String {
        // 앱의 문서 디렉토리 경로가 저장됩니다.
        let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        // 'databaseName`과 `documentsPath`를 조합하여 데이터베이스 파일의 전체 경로를 반환합니다.
        return (documentsPath as NSString).appendingPathComponent("\(databaseName)")
    }
    
    /**
     데이터베이스에 유저 테이블을 생성하는 함수입니다.
     */
    func createTable() {
        /*
         `CREATE TABLE IF NOT EXISTS` 쿼리는 `users` 테이블이 없을 때 생성하며,
         각 컬럼은 id(정수, 자동 증가 PRIMARY KEY),
         userID(텍스트),
         password(텍스트),
         creationDate(TIMESTAMP),
         highScore(실수, 기본값 99999.0)로 구성됩니다.
         */
        query = """
           CREATE TABLE IF NOT EXISTS users (
               id INTEGER PRIMARY KEY AUTOINCREMENT,
               userID TEXT,
               password TEXT,
               creationDate TIMSTAMP,
               highScore REAL DEFAULT 99999.0
           )
           """
        
        // `statement' 변수 초기화
        statement = nil
    
        // `defer` 블록을 사용하여 함수가 종료되기 전에 메모리 누수를 방지하기 위해 `sqlite3_finalize`를 호출합니다.
        defer {
            // statement가 nil이 아닐시
            if statement != nil {
                // 메모리에서 sqlite3 할당 해제.
                sqlite3_finalize(statement)
            }
        }
        
        // `sqlite3_prepare_v2` 함수를 사용하여 데이터베이스에 쿼리를 준비합니다. 성공하면 `statement`에 쿼리 정보가 저장됩니다.
        if sqlite3_prepare_v2(db, query, -1, &statement, nil) == SQLITE_OK {
            // `sqlite3_step` 함수를 사용하여 쿼리를 실행하고, 실행이 성공적으로 완료되면 "Creating table has been successfully done."을 출력합니다.
            if sqlite3_step(statement) == SQLITE_DONE {
                print("Creating table has been succesfully done. db: \(String(describing: db))")
            } else {
                // 쿼리의 실행이 실패하면 에러메시지 실행 후 함수를 종료합니다.
                print(String(cString: sqlite3_errmsg(db)))
                return
            }
        }
        
        // 쿼리의 준비를 실패하면 에러메시지 실행 후 함수를 종료합니다.
        print(String(cString: sqlite3_errmsg(db)))
        return

    }
    
    /**
     데이터베이스에 점수 테이블을 생성하는 함수입니다.
     */
    func createScoreTable() {
        // `CREATE TABLE IF NOT EXISTS` 쿼리는 `scores` 테이블이 없을 때 생성하며,
        // 각 컬럼은 userID(텍스트), score(실수)로 구성됩니다.
        query = """
           CREATE TABLE IF NOT EXISTS scores (
               userID TEXT,
               score REAL
           )
           """
        // `statement' 변수 초기화
        statement = nil
        
        // `defer` 블록을 사용하여 함수가 종료되기 전에 메모리 누수를 방지하기 위해 `sqlite3_finalize`를 호출합니다.
        defer {
            // statement가 nil이 아닐시
            if statement != nil {
                // 메모리에서 sqlite3 할당 해제합니다.
                sqlite3_finalize(statement)
            }
        }
        
        // `sqlite3_prepare_v2` 함수를 사용하여 데이터베이스에 쿼리를 준비합니다. 성공하면 `statement`에 쿼리 정보가 저장됩니다.
        if sqlite3_prepare_v2(db, query, -1, &statement, nil) == SQLITE_OK {
            // 쿼리를 실행하고, 실행이 성공적으로 완료되면 성공 메시지 출력 후 함수를 종료합니다.
            if sqlite3_step(statement) == SQLITE_DONE {
                print("Creating table has been succesfully done. db: \(String(describing: db))")
                return
            } else {
                // 쿼리의 실행이 실패하면 에러메시지 실행 후 함수를 종료합니다.
                print(String(cString: sqlite3_errmsg(db)))
                return
            }
        }
        
        // 쿼리의 준비를 실패하면 에러메시지 실행 후 함수를 종료합니다.
        print(String(cString: sqlite3_errmsg(db)))
        return

        
    }
    
    /**
     이 함수는 사용자 등록 함수입니다.
     */
    func registerUser(userID: NSString, userPWD: NSString, result: inout (Bool, String)) {
        // 주어진 사용자 ID가 이미 데이터베이스에 존재하는지 확입합니다.
        if userExists(username: userID) {
            // 이미 존재하는 경우, false를 반환합니다.
            result.0 = false
            result.1 = "이미있는 아이디입니다."
            return
        }
        
        // 현재 날짜 및 시간을 가져옵니다.
        let currentDate = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let formattedDate = dateFormatter.string(from: currentDate)
        
        // 사용자 정보를 데이터베이스에 삽입하기 위한 쿼리를 작성합니다.
        query = "INSERT INTO users (userID, password, creationDate) VALUES (?, ?, ?)"
        
        // `statement' 변수 초기화
        statement = nil
        
        // `defer` 블록을 사용하여 함수가 종료되기 전에 메모리 누수를 방지하기 위해 `sqlite3_finalize`를 호출합니다.
        defer {
            // statement가 nil이 아닐시
            if statement != nil {
                // 메모리에서 sqlite3 할당 해제합니다.
                sqlite3_finalize(statement)
            }
        }
        
        // `sqlite3_prepare_v2` 함수를 사용하여 데이터베이스에 쿼리를 준비합니다. 성공하면 `statement`에 쿼리 정보가 저장됩니다.
        if sqlite3_prepare_v2(db, query, -1, &statement, nil) == SQLITE_OK {
            /*
             sqlite3_bind_text는 쿼리문에 있는 ?에 원하는 값을 넣는 함수이다.
             예를 들어 sqlite3_bind_text(statement, 1, userID.utf8String, -1, nil)의 뜻은
             INSERT INTO users (userID, password) VALUES (?, ?);에 있는 1번째 ?에 userID.utf8String를 넣어준다는 뜻입니다.
             */
            sqlite3_bind_text(statement, 1, userID.utf8String, -1, nil)
            // 회원가입을 인증서로 할 때
            if userPWD as String == "인증서" {
                // sqlite3_bind_text를 사용하여 '인증서'를 query문에 넣어줍니다.
                sqlite3_bind_text(statement, 2, userPWD.utf8String, -1, nil)
            // 아이디, 비밀번호로 회원가입 할 때
            } else {
                // sqlite3_bind_text를 사용하여 암호화된 비밀번호를 query문에 넣어줍니다.
                sqlite3_bind_text(statement, 2, userPWD.utf8String, -1, nil)
            }
            
            // sqlite3_bind_text를 사용하여 현재 시간를 query문에 넣어줍니다.
            sqlite3_bind_text(statement, 3, (formattedDate as NSString).utf8String, -1, nil)
            
            // 쿼리를 실행하고, 실행이 성공적으로 완료되면 result에 true와 성공 메시지를 넣어준뒤 함수를 return합니다.
            if sqlite3_step(statement) == SQLITE_DONE {
                result.0 = true
                result.1 = "회원가입 성공!"
                return
                
            } else {
                // 쿼리의 실행을 실패하면 result에 false와 에러 메시지를 넣어준뒤 함수를 return합니다.
                result.0 = false
                result.1 = String(cString: sqlite3_errmsg(db))
                return
            }
        }
        
        // 쿼리 준비를 실패하면 result에 false와 에러 메시지를 넣어줍니다.
        result.0 = false
        result.1 = String(cString: sqlite3_errmsg(db))
    }
    
    /**
     이 함수는 사용자 로그인 함수입니다.
      */
    func loginUser(userID: NSString, password: NSString, keepLogin: Bool, result: inout (Bool, String)) -> User? {
        
        // 유저아이디로 user테이블에서 모든 데이터를 가져오는 쿼리문입니다.
        query = "SELECT * FROM users WHERE userID = ?"
        
        // `statement' 변수 초기화
        statement = nil
        
        // `defer` 블록을 사용하여 함수가 종료되기 전에 메모리 누수를 방지하기 위해 `sqlite3_finalize`를 호출합니다.
        defer {
            // statement가 nil이 아닐시
            if statement != nil {
                // 메모리에서 sqlite3 할당 해제합니다.
                sqlite3_finalize(statement)
            }
        }
        
        // `sqlite3_prepare_v2` 함수를 사용하여 데이터베이스에 쿼리를 준비합니다. 성공하면 `statement`에 쿼리 정보가 저장됩니다.
        if sqlite3_prepare_v2(db, query, -1, &statement, nil) == SQLITE_OK {
            // sqlite3_bind_text를 사용하여 유저ID를 query문에 넣어줍니다.
            sqlite3_bind_text(statement, 1, userID.utf8String, -1, nil)
            // 쿼리를 실행하고, 테이블 행에 내가 원하는 값이 있으면 데이터를 가져옵니다.
            if sqlite3_step(statement) == SQLITE_ROW {
                    
                let userPW = String(cString: sqlite3_column_text(statement, 2))
                if userPW == password as String {
                    
                    // 성공하면 user 구조체에 데이터 넣어준뒤 반환해줍니다.
                    let user = User(id: sqlite3_column_int64(statement, 0), userID: String(userID), userPWD: String(password), createdDate: String(cString: sqlite3_column_text(statement, 3)), highScore: sqlite3_column_double(statement, 4))
                    
                    // 실행이 성공적으로 완료되면 result에 true와 성공 메시지를 넣어준뒤 user를 반환합니다.
                    result.0 = true
                    result.1 = "로그인 성공"
                    return user
                    
                } else {
                    // 실패하면 result에 실행결과와 오류 메시지 저장후 nil를 반환합니다.
                    result.0 = false
                    result.1 = "아이디 또는 비밀번호가 다릅니다."
                    return nil
                    }
            // 쿼리를 실행 실패하면 result에 실행결과와 오류 메시지 저장후 nil를 반환합니다.
            } else {
                result.0 = false
                result.1 = "아이디 또는 비밀번호가 다릅니다."
                return nil
            }
        }
        
        // 쿼리 준비 실패하면 result에 실행결과와 오류 메시지 저장후 nil를 반환합니다.
        result.0 = false
        result.1 = String(cString: sqlite3_errmsg(db))
        return nil
    }
    
    /**
     이 함수는 로그인 유저의 비밀번호 변경 함수입니다.
     */
    func changeUserPWD(userName: NSString, currentPassword: NSString, newPassword: NSString, result: inout (Bool, String)) {
       
        // 유저아이디로 user테이블에서 비밀번호를 업데이트하는 쿼리문입니다.
        query = "UPDATE users SET password = ? WHERE userID = ?"
        // `statement' 변수 초기화
        statement = nil
        
        // `defer` 블록을 사용하여 함수가 종료되기 전에 메모리 누수를 방지하기 위해 `sqlite3_finalize`를 호출합니다.
        defer {
            // statement가 nil이 아닐시
            if statement != nil {
                // 메모리에서 sqlite3 할당 해제합니다.
                sqlite3_finalize(statement)
            }
        }
        
        // `sqlite3_prepare_v2` 함수를 사용하여 데이터베이스에 쿼리를 준비합니다. 성공하면 `statement`에 쿼리 정보가 저장됩니다.
        if sqlite3_prepare_v2(db, query, -1, &statement, nil) == SQLITE_OK {
            
            // sqlite3_bind_text를 사용하여 '새로운 비밀번호', '유저ID'를 query문에 넣어줍니다.
            sqlite3_bind_text(statement, 1, newPassword.utf8String , -1, nil)
            sqlite3_bind_text(statement, 2, userName.utf8String, -1, nil)
            
            // 쿼리를 실행하고, 실행이 성공적으로 완료되면 result에 true와 성공 메시지를 넣어줍니다.
            if sqlite3_step(statement) == SQLITE_DONE {
                result.0 = true
                result.1 = "비밀번호 변경 완료."
                return
                
            // 쿼리 실행 실패시 result에 실행결과와 오류 메시지를 넣어줍니다.
            } else {
                result.0 = false
                result.1 = "비밀번호 변경 실패."
                return
            }
        }
        
        // 쿼리 준비 실패시 result에 실행결과와 오류 메시지를 넣어줍니다.
        result.0 = false
        result.1 = String(cString: sqlite3_errmsg(db))
    }
    
    /**
    이 함수는 사용자의 점수를 저장하는 함수입니다.
     */
    func highScoreSave(userID: NSString, newScore: Double, result: inout (Bool, String)) {
        // users테이블에서 유저아이디의 최고점수를 업데이트 하는 쿼리문입니다.
        query = "UPDATE users SET highScore = ? WHERE userID = ?"
        // `statement' 변수 초기화
        statement = nil
        
        // `defer` 블록을 사용하여 함수가 종료되기 전에 메모리 누수를 방지하기 위해 `sqlite3_finalize`를 호출합니다.
        defer {
            // statement가 nil이 아닐시
            if statement != nil {
                // 메모리에서 sqlite3 할당 해제합니다.
                sqlite3_finalize(statement)
            }
        }
                    
        // `sqlite3_prepare_v2` 함수를 사용하여 데이터베이스에 쿼리를 준비합니다. 성공하면 `statement`에 쿼리 정보가 저장됩니다.
        if sqlite3_prepare_v2(db, query, -1, &statement, nil) == SQLITE_OK {
            
            // sqlite3_bind_text를 사용하여 '새로운 최고기록', '유저아이디'를 query문에 넣어줍니다.
            sqlite3_bind_double(statement, 1, newScore)
            sqlite3_bind_text(statement, 2, userID.utf8String, -1, nil)
            
            // 쿼리를 실행하고, 실행이 성공적으로 완료되면 result에 true와 성공 메시지를 넣어준뒤 return합니다.
            if sqlite3_step(statement) == SQLITE_DONE {
                result.0 = true
                result.1 = "신기록 저장 성공"
                return
                
            // 쿼리 실행 실패 시 result에 false와 실패 메시지를 넣어준뒤 return합니다.
            } else {
                result.0 = false
                result.1 = "신기록 저장 실패"
                return
            }
        }
        
        // 쿼리 준비 실패시 result에 실행결과와 오류 메시지를 넣어줍니다.
        result.0 = false
        result.1 = String(cString: sqlite3_errmsg(db))
    }
    
    /**
     이 함수는 모든점수를 저장하는 함수입니다.
     */
    func scoreSave(userID: NSString, score: Double, result: inout (Bool, String)) {
        
        // scores테이블에 (유저아이디, 점수)를 넣는 쿼리문입니다.
        query = "INSERT INTO scores (userID, Score) VALUES (?, ?)"
        
        // `statement' 변수 초기화
        statement = nil
        
        // `defer` 블록을 사용하여 함수가 종료되기 전에 메모리 누수를 방지하기 위해 `sqlite3_finalize`를 호출합니다.
        defer {
            // statement가 nil이 아닐시
            if statement != nil {
                // 메모리에서 sqlite3 할당 해제합니다.
                sqlite3_finalize(statement)
            }
        }
        
        // `sqlite3_prepare_v2` 함수를 사용하여 데이터베이스에 쿼리를 준비합니다. 성공하면 `statement`에 쿼리 정보가 저장됩니다.
        if sqlite3_prepare_v2(db, query, -1, &statement, nil) == SQLITE_OK {
            
            // sqlite3_bind_text를 사용하여 '유저아이디', '점수'를 query문에 넣어줍니다.
            sqlite3_bind_text(statement, 1, userID.utf8String, -1, nil)
            sqlite3_bind_double(statement, 2, score)
            
            // 쿼리를 실행하고, 실행이 성공적으로 완료되면 result에 true와 성공 메시지를 넣어준뒤 return합니다.
            if sqlite3_step(statement) == SQLITE_DONE {
                result.0 = true
                result.1 = "데이터 삽입 성공"
                return
            // 쿼리 실행 실패 시 result에 false와 실패 메시지를 넣어준뒤 return합니다.
            } else {
                result.0 = false
                result.1 = "데이터 삽입 실패"
                return
            }
        }
        
        // 쿼리 준비 실패시 result에 실행결과와 오류 메시지를 넣어줍니다.
        result.0 = false
        result.1 = String(cString: sqlite3_errmsg(db))
    }
    
    /**
     이 함수는 중복 ID확인하는 함수입니다.
     */
    func userExists(username: NSString) -> Bool {
        // users테이블에서 내가원하는 userID를 가져오는 쿼리문입니다.
        query = "SELECT userID FROM users WHERE userID = ?"
        
        // `statement' 변수 초기화
        statement = nil
        
        // `defer` 블록을 사용하여 함수가 종료되기 전에 메모리 누수를 방지하기 위해 `sqlite3_finalize`를 호출합니다.
        defer {
            // statement가 nil이 아닐시
            if statement != nil {
                // 메모리에서 sqlite3 할당 해제합니다.
                sqlite3_finalize(statement)
            }
        }
        
        // `sqlite3_prepare_v2` 함수를 사용하여 데이터베이스에 쿼리를 준비합니다. 성공하면 `statement`에 쿼리 정보가 저장됩니다.
        if sqlite3_prepare_v2(db, query, -1, &statement, nil) == SQLITE_OK {
            sqlite3_bind_text(statement, 1, username.utf8String, -1, nil)
            // 쿼리를 실행하고, 테이블 행에 내가 원하는 값이 있으면 데이터를 가져옵니다.
            if sqlite3_step(statement) == SQLITE_ROW {
                // 이미 사용자가 존재 했을 때
                return true
            } else {
                // 사용자가 존재 하지 않았을 떄
                return false
            }
        }
        
        return true
    }
    
    /**
      100순위 구하기
     */
    func getTop100User(isGlobal: Bool, userID: String) {
        // 배열초기화
        top100User.removeAll()
        top100Score.removeAll()
        
        // `statement' 변수 초기화
        statement = nil
        
        // `defer` 블록을 사용하여 함수가 종료되기 전에 메모리 누수를 방지하기 위해 `sqlite3_finalize`를 호출합니다.
        defer {
            // statement가 nil이 아닐시
            if statement != nil {
                // 메모리에서 sqlite3 할당 해제합니다.
                sqlite3_finalize(statement)
            }
        }
        
        // 모든 유저 100순위
        if isGlobal {
            // scores테이블에서 점수의 오름차순으로 유저아이디, 비밀번호를 가져오는 쿼리문입니다.
            query = "SELECT userID, score FROM scores ORDER BY score ASC LIMIT 100"
        // 내 기록 top100
        } else {
            // scores테이블에서 점수의 오름차순으로 유저아이디, 비밀번호를 가져오는 쿼리문입니다.
            query = "SELECT userID, score FROM scores Where userID = '\(userID)' ORDER BY score ASC LIMIT 100"
        }
        
        // `sqlite3_prepare_v2` 함수를 사용하여 데이터베이스에 쿼리를 준비합니다. 성공하면 `statement`에 쿼리 정보가 저장됩니다.
        if sqlite3_prepare_v2(db, query, -1, &statement, nil) == SQLITE_OK {
            // 쿼리를 실행하고, 테이블 행에 내가 원하는 값이 있으면 데이터를 가져옵니다.
            while sqlite3_step(statement) == SQLITE_ROW {
                // 배열에 데이터 추가
                top100User.append(String(cString: sqlite3_column_text(statement, 0)))
                top100Score.append(Float(sqlite3_column_double(statement, 1)))
            }
        }
    }
    
    /**
     테이블 삭제
     */
    func deleteTable(tableName: String) {
        query = "DROP TABLE \(tableName)"
        statement = nil
        
        defer {
            sqlite3_finalize(statement)  // 메모리에서 sqlite3 할당 해제.
        }
        
        if sqlite3_prepare(db, query, -1, &statement, nil) != SQLITE_OK {
            return
        }
        
        // 쿼리 실행.
        if sqlite3_step(statement) != SQLITE_DONE {
            return
        }
        print("drop table has been successfully done")
    }
    
}
