import SwiftUI



struct ContentView: View {
    
    // properties for settings state
    @State private var timesTablesAmount = 1
    @State private var initialNumQuestion = 10
    @State private var numQuestions = [5, 10, 20]
    @State private var values = Int.random(in: 1...12)
    
    // new view properties
    @State private var isSettingsScreen = true
    @State private var answer = ""
    @State private var score = 0
    
    // temporary correct/incorrect message state
    @State private var temporaryMessage = ""
    @State private var isTemporaryMessageVisable = false
    
    // end of game alert
    @State private var endGameAlert = false
    
    // add these properties to track the answer validation animation
    @State private var isCorrectAnswer = false
    @State private var isShowingAnswerAnimation = false

    var body: some View {
        ZStack {
            if isSettingsScreen {
                // Settings screen
                Color.blue.ignoresSafeArea()
                
                VStack {
                    Spacer()
                    Text("Edutainment Game")
                        .font(.largeTitle.bold())
                        .foregroundColor(.white)
                    Spacer()
                    Spacer()
                    Spacer()
                    
                    Form {
                        Text("Game settings")
                            .font(.headline)
                        
                        Section(header: Text("Select multiplication tables to practise")){
                            Picker("Times tables", selection: $timesTablesAmount) {
                                ForEach(1..<13) { number in
                                    Text("\(number) times tables")
                                        .tag(number)
                                }
                            }
                        }
                        
                        Section(header: Text("Number of questions to answer")) {
                            Picker("Number of questions", selection: $initialNumQuestion){
                                ForEach(numQuestions, id: \.self) {
                                    Text("\($0)")
                                }
                            }
                            .pickerStyle(.segmented)
                        }
                    }
                }
                
                Spacer()
                
                NavigationLink(destination: GameView()) {
                    Text("Start Game")
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .padding(.top, 50)
                .onTapGesture {
                    isSettingsScreen = false
                }
                

            } else {
                
                // Game screen
                Color.blue.ignoresSafeArea()
                
                VStack {
                    Spacer()
                    Text("Edutainment Game")
                        .font(.largeTitle.bold())
                        .foregroundColor(.white)
                    
                    Spacer()
                    Spacer()
                    
                    VStack {
                        Text("\(timesTablesAmount) times tables")
                            .font(.title)
                            .foregroundColor(.white)
                        
                        // randomly select value for RHS
                        Spacer()

                        
                        Form {
                            Section {
                                Text("\(timesTablesAmount) x \(values)")
                                    .font(.largeTitle.bold())
                                    .foregroundColor(.black)
                                    .frame(maxWidth: .infinity, alignment: .center)
                                    .opacity(isShowingAnswerAnimation ? (isCorrectAnswer ? 0.0 : 1.0) : 1.0) // fade out if incorrect
                                    .scaleEffect(isShowingAnswerAnimation ? (isCorrectAnswer ? 2.0 : 1.0) : 1.0) // scale up if correct
                            }
                            .animation(.easeInOut(duration: 0.5))
                            .onChange(of: values) { _ in
                                isShowingAnswerAnimation = true // trigger animation when the value changes (new question appears)
                            }
                            .onAppear {
                                isShowingAnswerAnimation = true // trigger animation when view appears
                            }
                            
                            Section {
                                // Show text entry field
                                TextField("Answer", text: $answer, onCommit: {
                                    processAnswer()
                                })
                                .font(.largeTitle.bold())
                                .foregroundColor(.black)
                                .keyboardType(.numberPad)
                                .multilineTextAlignment(.center) // Center align the text within the text field
                            }
                            
                           
                            // Show temporary message if it's visible
                            if isTemporaryMessageVisable {
                                VStack {
                                    Text(temporaryMessage)
                                        .font(.title3)
                                        .foregroundColor(temporaryMessage == "Correct!" ? .green : .red)
                                }
                                .frame(maxWidth: .infinity, alignment: .center)
                            }
                            
                        }
                        
                        
                        Text("Score: \(score)")
                            .font(.title)
                            .foregroundColor(.white)
                        
                        Spacer()
                        
                        Text("Remaining Questions: \(initialNumQuestion)")
                            .font(.title)
                            .foregroundColor(.white)
                        
                        Spacer()
                        
                        // WORKING HERE TO FIX RESTART BUTTON
                        HStack {
                                Button("Restart") {
                                    isSettingsScreen = true
                                    restartGame()
                                }
                                .font(.title.bold())
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                        } .background(Color.orange)
                        
                        
                    }.alert("Well done!", isPresented: $endGameAlert) {
                        Button("Play again?", action: restartGame)
                    } message: {
                        Text("Final score is \(score)")
                    }
                }
            }
        }
    }
    
    // restart game
    func restartGame() {
        
        // reset score
        score = 0
        
        // head back to contentView
        isSettingsScreen = true
        
    }

    // process answer (correct/incorrect)
    func processAnswer() {
        
        // unwrap optional Int answer value
        if let answerValue = Int(answer) {
            
            // calculate correct answer
            let correctAnswer = timesTablesAmount * values
            
            // check if answer is correct
            if (correctAnswer == answerValue) {
                
                // set correct answer
                temporaryMessage = "Correct!"
                
                // decrement remaining questions
                initialNumQuestion -= 1
                
                // update score
                score += 1
                
                // bool to track correct answer for animation
                isCorrectAnswer = true
                
            } else {
                
                // set correct answer
                temporaryMessage = "Incorrect!"
                
                // decrement remaining questions
                initialNumQuestion -= 1
                
                // bool to track incorrect answer for animation
                isCorrectAnswer = false
                
            }
            
            // show correct message
            showTemporaryMessage()
            
            // refresh answer to be blank
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                answer = ""
            }
            
            
            // if number remaining questions < 0, reshufflevalues else end game
            if (initialNumQuestion > 0) {
                
                // reshuffle values
                reshuffleValues()
                
            } else {
                
                // trigger alert that game is over
                endGameAlert = true
                
                // add fireworks to screen
                
            }
            
        }
        
        // Handle the case when the answer cannot be converted to an integer
        print("Answer invalid")
        
    }
    
    // reshuffle values
    func reshuffleValues() {
        var newValue = Int.random(in: 1...11)
        if newValue >= values {
            newValue += 1
        }
        values = newValue
    }
    
    // show incorrect/correct temporary message
    func showTemporaryMessage() {
        // set flag to true
        isTemporaryMessageVisable = true
        
        // set timer to make disappear
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            isTemporaryMessageVisable = false
            isShowingAnswerAnimation = false // Hide the animation
            
        }
    }
}



struct GameView: View {
    var body: some View {
        ZStack {
            Color.blue.ignoresSafeArea()
            Text("This is the new view!")
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}


// TODO
// Fix restart button positioning
// Add answers to persist after answered
// Remove section box around correct / incorrect text
