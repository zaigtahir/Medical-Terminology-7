//
//  QuizHome.swift
//  Medical Terminology
//
//  Created by Zaigham Tahir on 7/29/19.
//  Copyright © 2019 Zaigham Tahir. All rights reserved.
//



import UIKit

class QuizHome: UIViewController, QuizOptionsUpdated {

    
    @IBOutlet weak var favoritesLabel: UILabel!
    @IBOutlet weak var favoritesSwitch: UISwitch!
    @IBOutlet weak var percentLabel: UILabel!
    @IBOutlet weak var circleBarView: UIView!
    @IBOutlet weak var newQuizButton: UIButton!
    @IBOutlet weak var currentQuizButton: UIButton!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var redoButton: UIButton!
    @IBOutlet weak var heartImage: UIImageView!
    
    let quizHomeVCH = QuizHomeVCH()
    let dIC = DItemController()
    let utilities = Utilities()
    var progressBar: CircularBar!
    
    private var optionsMenu: UIAlertController!
    
    //button colors
    let enabledButtonColor = myTheme.colorQuizButton
    let enabledButtonTint = myTheme.colorButtonEnabledTint
    let disabledButtonColor = myTheme.colorButtonDisabled
    let disabledButtonTint = myTheme.colorButtonDisabledTint
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        favoritesSwitch.layer.cornerRadius = 16
        favoritesSwitch.clipsToBounds = true
        favoritesSwitch.onTintColor = myTheme.colorFavorite
    
        
        newQuizButton.layer.cornerRadius = myConstants.button_cornerRadius
        currentQuizButton.layer.cornerRadius = myConstants.button_cornerRadius
        
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "Home", style: .plain, target: nil, action: nil)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        updateDisplay()
    }
    
    func updateDisplay () {
        
        let favoritesCount = dIC.getCount(favoriteState: 1)
        
        favoritesSwitch.isOn = quizHomeVCH.isFavoriteMode
        
        favoritesLabel.text = "\(favoritesCount)"
        
        if quizHomeVCH.isFavoriteMode && favoritesCount == 0 {
            
            //isFavorite = true, but the user has not selected any favorites
            circleBarView.isHidden = true
            percentLabel.isHidden = true
            heartImage.isHidden = false
            redoButton.isHidden = true
            messageLabel.text = quizHomeVCH.getMessageText()
            newQuizButton.isEnabled = false
            
            return
        }
        
        let counts = quizHomeVCH.getCounts()
        circleBarView.isHidden = false
        percentLabel.isHidden = false
        heartImage.isHidden = true
        redoButton.isHidden = false
        
      let foregroundColor = myTheme.color_pb_quiz_foreground?.cgColor
      let backgroundColor = myTheme.color_pb_quiz_background?.cgColor
      let fillColor =  myTheme.color_pb_quiz_fillcolor?.cgColor
              
      progressBar = CircularBar(referenceView: circleBarView, foregroundColor: foregroundColor!, backgroundColor: backgroundColor!, fillColor: fillColor!
        , lineWidth: myTheme.progressBarWidth)
        
        progressBar.setStrokeEnd(partialCount: counts.answeredCorrectly, totalCount: (counts.availableToAnswer + counts.answeredCorrectly) )
        heartImage.isHidden = true
        
        let percentText = utilities.getPercentage(number: counts.answeredCorrectly, numberTotal: (counts.answeredCorrectly + counts.availableToAnswer))
        
        percentLabel.text = "\(percentText)% DONE"
        messageLabel.text = quizHomeVCH.getMessageText()
        
        if counts.answeredCorrectly > 0 {
            redoButton.isEnabled = true
        } else {
            redoButton.isEnabled = false
        }
        
        if counts.availableToAnswer > 0 {
            newQuizButton.isEnabled = true
        } else {
            newQuizButton.isEnabled = false
        }
        
        //state of see current quiz button
        currentQuizButton.isEnabled = quizHomeVCH.isQuizSetAvailable()

        for b in [newQuizButton, currentQuizButton] {
            utilities.formatButtonColor(button: b!, enabledBackground: enabledButtonColor!, enabledTint: enabledButtonTint!, disabledBackground: disabledButtonColor!, disabledTint: disabledButtonTint!)
        }
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "segueToQuiz" {
            let vc = segue.destination as! QuizSetVC
                        
            if quizHomeVCH.startNewQuiz {
                vc.quizSetVCH.quizSet = quizHomeVCH.getNewQuizSet()
            } else {
                vc.quizSetVCH.quizSet = quizHomeVCH.getQuizSet()
            }
        }
        
        if segue.identifier == "segueQuizOptions" {
            let vc = segue.destination as! QuizOptionsVC
            vc.delegate = self
            vc.questionsType = quizHomeVCH.questionsType
            vc.numberOfQuestions = quizHomeVCH.numberOfQuestions
            vc.isFavoriteMode = quizHomeVCH.isFavoriteMode
        }
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        //redraw the progress bar
        updateDisplay()
    }
    
    @IBAction func favoritesSwitchChanged(_ sender: UISwitch) {
        quizHomeVCH.isFavoriteMode = sender.isOn
        updateDisplay()
    }
        
    func confirmRestart () {
        
        let alert = UIAlertController(title: "Redo Quiz Questions", message: "Are you sure you want to clear the answers to these questions and redo them?", preferredStyle: .actionSheet)
        
        let yesAction = UIAlertAction(title: "Yes", style: .default, handler: {
            action in self.restartNow()})
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: nil)
        
        alert.addAction(yesAction)
        alert.addAction(cancelAction)
        self.present(alert, animated: true, completion: nil)
    }
    
    func restartNow() {
        quizHomeVCH.restartOver()
        updateDisplay()
    }
    
    @IBAction func optionsButtonAction(_ sender: Any) {
        performSegue(withIdentifier: "segueQuizOptions", sender: nil)
    }
    
    @IBAction func redoButtonAction(_ sender: Any) {
        confirmRestart()
    }
    
    @IBAction func newQuizButtonAction(_ sender: UIButton) {
        quizHomeVCH.startNewQuiz = true
        performSegue(withIdentifier: "segueToQuiz", sender: nil)
    }
    
    @IBAction func currentQuizButtonAction(_ sender: Any) {
        //will manually segue
        quizHomeVCH.startNewQuiz  = false
        performSegue(withIdentifier: "segueToQuiz", sender: nil)
    }
    //MARK: - Delegate functions
    
    func quizOptionsUpdate(numberOfQuestions: Int, questionsTypes: QuestionsType, isFavoriteMode: Bool) {
        //update settings
        quizHomeVCH.numberOfQuestions = numberOfQuestions
        quizHomeVCH.questionsType = questionsTypes
        quizHomeVCH.isFavoriteMode = isFavoriteMode
        updateDisplay()
    }
    
}
