//
//  AlertModel.swift
//  MovieQuiz
//
//  Created by Алишер Дадаметов on 15.04.2023.
//

import Foundation

struct AlertModel {
    let title:  String
    let message: String
    let buttonText: String
    let completion: (() -> Void)?
}
