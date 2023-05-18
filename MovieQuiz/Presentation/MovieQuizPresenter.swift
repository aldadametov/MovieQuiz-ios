//
//  MovieQuizPresenter.swift
//  MovieQuiz
//
//  Created by Алишер Дадаметов on 17.05.2023.
//

import UIKit

final class MovieQuizPresenter {
    
    private var currentQuestionIndex: Int = 0
    var questionFactory: QuestionFactoryProtocol?
    var statisticService: StatisticService?
    var currentQuestion: QuizQuestion?
    var correctAnswers: Int = 0
    weak var viewController: MovieQuizViewController?
    let questionsAmount: Int = 10
    
    func yesButtonClicked() {
        didAnswer(isYes: true)
    }
    
    func noButtonClicked() {
        didAnswer(isYes: false)
    }
    
    private func didAnswer(isYes: Bool) {
        guard let currentQuestion = currentQuestion else {
            return
        }
        let givenAnswer = isYes
        
        viewController?.showAnswerResult(isCorrect: givenAnswer == currentQuestion.correctAnswer)
    }
    
    func isLastQuestion() -> Bool {
        currentQuestionIndex == questionsAmount - 1
    }
    
    func resetQuestionIndex() {
        currentQuestionIndex = 0
    }
    
    func switchToNextQuestion() {
        currentQuestionIndex += 1
    }
    
    func convert(model: QuizQuestion) -> QuizStepViewModel {
            
        let questionStep = QuizStepViewModel(
            image: UIImage(data: model.image) ?? UIImage(),
            question: model.text,
            questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)"
        )
        return questionStep
    }
    
    func showNextQuestionOrResults() {
        if self.isLastQuestion() {
            viewController?.imageView.layer.borderColor = UIColor.clear.cgColor
            guard let statisticService = statisticService else { return }
            statisticService.store(correct: correctAnswers, total: questionsAmount)
            let text = """
            Ваш результат: \(correctAnswers)/\(questionsAmount)
            Количество сыгранных квизов: \(statisticService.gamesCount)
            Рекорд: \(statisticService.bestGame.correct)/10 \(statisticService.bestGame.date.dateTimeString)
            Средняя точность: \(String(format: "%.2f", statisticService.totalAccuracy * 100))%
            """
            let viewModel = QuizResultsViewModel(
                title: "Этот раунд окончен!",
                text: text,
                buttonText: "Сыграть ещё раз")
            viewController?.show(quiz: viewModel)
        } else {
            viewController?.imageView.layer.borderColor = UIColor.clear.cgColor
            self.switchToNextQuestion()
            self.questionFactory?.requestNextQuestion()
        }
    }
    
    func didReceiveNextQuestion(question: QuizQuestion?) {
        guard let question = question else {
            return
        }
        
        currentQuestion = question
        let viewModel = convert(model: question)
        DispatchQueue.main.async { [weak self] in
            self?.viewController?.show(quiz: viewModel)
        }
    }
}

