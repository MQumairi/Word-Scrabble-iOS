//
//  ViewController.swift
//  Word Scramble
//
//  Created by Mohammed Alqumairi on 30/09/2020.
//

import UIKit

class ViewController: UITableViewController {
    
    var allWords = [String]()
    var usedWords = [String]()
    var chosenWord : String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        if let textFile = Bundle.main.url(forResource: "start", withExtension: "txt") {
            if let wordsString = try? String(contentsOf: textFile) {
                allWords = wordsString.components(separatedBy: "\n")
            }
        }
        
        if(allWords.isEmpty) {
            print("Empty!")
            allWords = ["silkworm", "king", "silk", "worm"]
        }
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(promptForWord))
        
        startGame()
        
    }
    
    func startGame() {
        chosenWord = allWords.randomElement()!
        title = chosenWord
        usedWords.removeAll(keepingCapacity: true)
        tableView.reloadData()
    }
    
    @objc func promptForWord() {
        print("prompt")
        
        let buttonAlert = UIAlertController(title: "Pick a word", message: nil, preferredStyle: .alert)
        buttonAlert.addTextField()
        
        buttonAlert.addAction(UIAlertAction(title: "Submit", style: .default)
        { [weak self, weak buttonAlert] action in
            if let answer = buttonAlert?.textFields?[0].text {
                self?.submit(answer)
            }
        })
        present(buttonAlert, animated: true)
    }
    
    func submit(_ answer: String) {
        
        let isOriginalVar = isOriginal(answer.lowercased())
        let isPossibleVar = isPossible(answer.lowercased())
        let isRealVar = isReal(answer.lowercased())
        
        if isOriginalVar && isPossibleVar && isRealVar {
            usedWords.insert(answer.lowercased(), at: 0)
            tableView.insertRows(at: [IndexPath(row: 0, section: 0)], with: .automatic)
            return
        }
        
        var errorTitle: String = "Error"
        
        if(!isOriginalVar) {
            errorTitle = "Word already used"
        }
        
        if(!isPossibleVar) {
            errorTitle = "Word is not possible from \(title!.lowercased())"
        }
        
        if(!isRealVar) {
            errorTitle = "Not a real world"
        }
        //comment
        let buttonAlert = UIAlertController(title: errorTitle, message: nil, preferredStyle: .alert)
        buttonAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(buttonAlert, animated: true)
    }
    
    func isOriginal(_ word: String) -> Bool {
        if(!usedWords.contains(word)) {
            return true
        }
        print("failed isOriginal")
        return false
    }
    
    func isPossible(_ word: String) -> Bool {
        
        var chosenWordArr = Array(chosenWord)
        
        for char in word {
            print("Checking: " + String(char) + " from " + word)
            if(!chosenWordArr.contains(char)) {
                return false
            } else {
                if let firstPosOfChar = chosenWordArr.firstIndex(of: char) {
                    chosenWordArr.remove(at: firstPosOfChar)
                    print(chosenWordArr)
                } else {
                    print("failed isPossible")
                    return false
                }
            }
        }
        return true
    }
    
    func isReal(_ word: String) -> Bool {
        let checker = UITextChecker()
        let range = NSRange(location: 0, length: word.utf16.count)
        let misspelledRange = checker.rangeOfMisspelledWord(in: word, range: range, startingAt: 0, wrap: false, language: "en")
        return misspelledRange.location == NSNotFound
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return usedWords.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Word", for: indexPath)
        cell.textLabel?.text = usedWords[indexPath.row]
        return cell
    }
    
    
}

