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
    
    private var _totalAccuracy: Double = 0
    var totalAccuracy: Double {
        get {
            return _totalAccuracy
            }
        set {
            _totalAccuracy = newValue
        }
    }
    
    private var _gamesCount: Int = 0
    var gamesCount: Int {
        get {
            return _gamesCount
        }
        set {
            _gamesCount = newValue
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
        let accuracy = Double (count) / Double (amount)
        
        gamesCount += 1
        
        let newTotalAccuracy = (_totalAccuracy * Double(gamesCount - 1) + accuracy) / Double(gamesCount)
        totalAccuracy = newTotalAccuracy
        
        let newGameRecord = GameRecord(correct: count, total: amount, date: Date())
                if GameRecord.newBestRecord(lhs: newGameRecord, rhs: bestGame) {
                    bestGame = newGameRecord
                }
    }

}
