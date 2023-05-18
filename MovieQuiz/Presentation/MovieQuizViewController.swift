import UIKit

final class MovieQuizViewController: UIViewController, QuestionFactoryDelegate {
    // MARK: - Actions
    
    @IBOutlet private var counterLabel: UILabel!
    
    @IBOutlet private var imageView: UIImageView!
    
    @IBOutlet private var textLabel: UILabel!
    
    @IBOutlet private var activityIndicator:UIActivityIndicatorView!
    
    @IBAction private func yesButtonClicked(_ sender: UIButton) {
        presenter.currentQuestion = currentQuestion
        presenter.yesButtonClicked()
    }
        
    @IBAction private func noButtonClicked(_ sender: UIButton) {
        presenter.currentQuestion = currentQuestion
        presenter.noButtonClicked()
    }
    
    // MARK: - Variables
    
    private var correctAnswers = 0
    private var questionFactory: QuestionFactoryProtocol?
    private var currentQuestion: QuizQuestion?
    private var statisticService: StatisticService?
    private let presenter = MovieQuizPresenter()
    
    // MARK: - Private functions
    
    private func show(quiz step: QuizStepViewModel) {
      imageView.image = step.image
      textLabel.text = step.question
      counterLabel.text = step.questionNumber
    } 
    
    func showAnswerResult(isCorrect: Bool) {
        
        if isCorrect {
               correctAnswers += 1
           }
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 8
        imageView.layer.borderColor = isCorrect ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self = self else { return }
            showNextQuestionOrResults()
        }
    }
    
    private func showNextQuestionOrResults() {
        if presenter.isLastQuestion() {
            imageView.layer.borderColor = UIColor.clear.cgColor
            guard let statisticService = statisticService else { return }
            statisticService.store(correct: correctAnswers, total: presenter.questionsAmount)
            let text = """
            Ваш результат: \(correctAnswers)/\(presenter.questionsAmount)
            Количество сыгранных квизов: \(statisticService.gamesCount)
            Рекорд: \(statisticService.bestGame.correct)/10 \(statisticService.bestGame.date.dateTimeString)
            Средняя точность: \(String(format: "%.2f", statisticService.totalAccuracy * 100))%
            """
            let viewModel = QuizResultsViewModel(
                title: "Этот раунд окончен!",
                text: text,
                buttonText: "Сыграть ещё раз")
            show(quiz: viewModel)
        } else {
            imageView.layer.borderColor = UIColor.clear.cgColor
            self.presenter.switchToNextQuestion()
            
            self.questionFactory?.requestNextQuestion()
        }
    }
    
    private func show(quiz result: QuizResultsViewModel) {
        let alertModel = AlertModel(
            title: result.title,
            message: result.text,
            buttonText: result.buttonText,
            completion: { [weak self] in
                guard let self = self else { return }
                self.presenter.resetQuestionIndex()
                self.correctAnswers = 0
                self.questionFactory?.requestNextQuestion()
            })
        
        AlertPresenter.show(from: self, with: alertModel)
    }
    
    private func showLoadingIndicator() {
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
    }
    
    private func hideLoadingIndicator() {
        activityIndicator.isHidden = true
        activityIndicator.stopAnimating()
    }
    
    private func showNetworkError(message: String) {
        hideLoadingIndicator()
        
        let model = AlertModel(title: "Ошибка",
                               message: message,
                               buttonText: "Попробовать еще раз") { [weak self] in
            guard let self = self else { return }
            
            self.presenter.resetQuestionIndex()
            self.correctAnswers = 0
            
            self.questionFactory?.requestNextQuestion()
        }
        
        AlertPresenter.show(from: self, with: model)
    }
    
    func didFailToLoadData(with error: Error) {
        showNetworkError(message: error.localizedDescription)
    }
    
    func didLoadDataFromServer() {
        activityIndicator.isHidden = true // скрываем индикатор загрузки
        questionFactory?.requestNextQuestion()
    }
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        presenter.viewController = self
        questionFactory = QuestionFactory(moviesLoader: MoviesLoader(), delegate: self)
        
        showLoadingIndicator()
        questionFactory?.loadData()
        
        statisticService = StatisticServiceImplementation ()
        
    }
    
    // MARK: - QuestionFactoryDelegate

    func didReceiveNextQuestion(question: QuizQuestion?) {
        guard let question = question else {
            return
        }
        
        currentQuestion = question
        let viewModel = presenter.convert(model: question)
        DispatchQueue.main.async { [weak self] in
            self?.show(quiz: viewModel)
        }
    }
}
