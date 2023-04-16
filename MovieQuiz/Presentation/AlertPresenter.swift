//
//  AlertPresenter.swift
//  MovieQuiz
//
//  Created by Алишер Дадаметов on 15.04.2023.
//

import Foundation
import UIKit

class AlertPresenter {
    
    static func show(from viewController: UIViewController, with model: AlertModel) {
        let alert = UIAlertController(title: model.title, message: model.message, preferredStyle: .alert)
        
        let action = UIAlertAction(title: model.buttonText, style: .default) { _ in
            model.completion?()
        }
        
        alert.addAction(action)
        
        viewController.present(alert, animated: true, completion: nil)
    }
}
