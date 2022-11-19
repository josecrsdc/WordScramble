//
//  ContentView.swift
//  WordScramble
//
//  Created by Jose carlos Rodriguez on 18/11/22.
//

import SwiftUI

struct ContentView: View {
    @State private var usedWords = [String]()
    @State private var rootWord = ""
    @State private var newWord = ""
    @State private var score = 0
    @State private var errorTitle = ""
    @State private var errorMessage = ""
    @State private var showingError = false
    
    
    var body: some View {
        NavigationView {
            List {
                HStack {
                    Section {
                        TextField("nsert word", text: $newWord)
                            .textInputAutocapitalization(.never)
                    }
                    VStack {
                        Text("Score")
                        Text("\(score)")
                    }
                }
                Section {
                    ForEach(usedWords, id: \.self) { word in
                        HStack {
                            Image(systemName: "\(word.count).circle")
                            Text(word)
                        }
                    }
                }
            }
            .navigationTitle(rootWord)
            .toolbar(content: {
                Button("Reset") {
                    startGame()
                }
            })
            .onSubmit(addNewWord)
            .onAppear(perform: startGame)
            .alert(errorTitle, isPresented: $showingError) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(errorMessage)
            }
        }
    }
}

extension ContentView {
    func addNewWord() {
        let answer = newWord.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        guard answer.count > 2 else {
            wordError(title: "Short word", message: "The word must have at least 3 letters")
            return
        }
        
        guard isOriginal(word: answer) else {
            wordError(title: "Word used already", message: "Be more original")
            return
        }
        guard isSameRoot(word: answer) else {
            wordError(title: "Word root", message: "You can't use the root word")
            return
        }
        guard isPosible(word: answer) else {
            wordError(title: "Word not possible", message: "You can't spell that word from '\(rootWord)'!")
            return
        }
        guard isReal(word: answer) else {
            wordError(title: "Word not recognized", message: "You can't just make them up, you know!")
            return
        }
        withAnimation {
            usedWords.insert(answer, at: 0)
        }
        score += answer.count
        newWord = ""
    }
    
    func startGame() {
        if let startWordsURL = Bundle.main.url(forResource: "start", withExtension: "txt") {
            if let startWords = try? String(contentsOf: startWordsURL) {
                let allWords = startWords.components(separatedBy: "\n")
                rootWord = allWords.randomElement() ?? "silkworm"
                resetGame()
                return
            }
        }
        fatalError("Could not load file start.txt")
    }
    
    func resetGame() {
        usedWords.removeAll()
        newWord = ""
        score = 0
    }
    
    func isOriginal(word: String) -> Bool {
        !usedWords.contains(word)
    }
    
    func isSameRoot(word: String) -> Bool {
        word != rootWord
    }
    
    func isPosible(word: String) -> Bool {
        var tempWord = rootWord
        for letter in word {
            if let pos = tempWord.firstIndex(of: letter) {
                tempWord.remove(at: pos)
            } else {
                return false
            }
        }
        return true
    }
    
    func isReal(word: String) -> Bool {
        let checker = UITextChecker()
        let range = NSRange(location: 0, length: word.utf16.count)
        let misslledRange = checker.rangeOfMisspelledWord(in: word, range: range, startingAt: 0, wrap: false, language: "en")
        return misslledRange.location == NSNotFound
    }
    
    
    func wordError(title: String, message: String) {
        errorTitle = title
        errorMessage = message
        showingError = true
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
