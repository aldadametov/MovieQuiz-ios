//
//  StatisticService.swift
//  MovieQuiz
//
//  Created by Алишер Дадаметов on 24.04.2023.
//

import Foundation


protocol StatisticService {
    
    func store(correct count: Int, total amount: Int)
    
    var totalAccuracy: Double { get }
    var gamesCount: Int { get }
    var bestGame: GameRecord { get }
    
}

struct GameRecord: Codable {
    let correct: Int
    let total: Int
    let date: Date
    
    static func newBestRecord (lhs: GameRecord, rhs: GameRecord) -> Bool {
        return lhs.correct > rhs.correct
    }
}

final class StatisticServiceImplementation: StatisticService {
    
    var correct: Int {
        return userDefaults.integer(forKey: Keys.correct.rawValue)
    }
    
    var total: Int {
        return userDefaults.integer(forKey: Keys.total.rawValue)
    }
    
    var totalAccuracy: Double {
        guard total > 0 else { return 0 }
        return Double(correct) / Double(total)
    }
    
    var gamesCount: Int {
        get {
            guard let data = userDefaults.data(forKey: Keys.gamesCount.rawValue),
                  let record = try? JSONDecoder().decode(Int.self, from: data) else {
                return 0
            }
            return record
        }
        set {
            guard let data = try? JSONEncoder().encode(newValue) else {
                print("Невозможно сохранить результат")
                return
            }
            
            userDefaults.set(data, forKey: Keys.gamesCount.rawValue)
        }
    }
    
    var bestGame: GameRecord {
        get {
            guard let data = userDefaults.data(forKey: Keys.bestGame.rawValue),
                  let record = try? JSONDecoder().decode(GameRecord.self, from: data) else {
                return .init(correct: 0, total: 0, date: Date())
            }
            
            return record
        }
        
        set {
            guard let data = try? JSONEncoder().encode(newValue) else {
                print("Невозможно сохранить результат")
                return
            }
            
            userDefaults.set(data, forKey: Keys.bestGame.rawValue)
        }
    }
    
    private let userDefaults = UserDefaults.standard
    
    private enum Keys: String {
        case correct, total, bestGame, gamesCount
    }
    
    func store(correct count: Int, total amount: Int) {
        gamesCount += 1
        let newCorrectCount = userDefaults.integer(forKey: Keys.correct.rawValue) + count
        let newTotalAmount = userDefaults.integer(forKey: Keys.total.rawValue) + amount
        let newGameRecord = GameRecord(correct: count, total: amount, date: Date())
        if GameRecord.newBestRecord(lhs: newGameRecord, rhs: bestGame) {
            bestGame = newGameRecord
        }
        userDefaults.set(newCorrectCount, forKey: Keys.correct.rawValue)
        userDefaults.set(newTotalAmount, forKey: Keys.total.rawValue)
    }
    
}
