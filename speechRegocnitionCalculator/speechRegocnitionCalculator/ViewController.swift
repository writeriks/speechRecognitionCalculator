//
//  ViewController.swift
//  speechRegocnitionCalculator
//
//  Created by Emir haktan Ozturk on 24/07/2017.
//  Copyright © 2017 emirhaktan. All rights reserved.
//

import UIKit
import Speech

class ViewController: UIViewController,SFSpeechRecognizerDelegate {
    @IBOutlet var calculationLabel: UILabel!
    @IBOutlet var recordButton: UIButton!

    private let speechRecognizer = SFSpeechRecognizer(locale: Locale.init(identifier: "en-US"))
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private let audioEngine = AVAudioEngine()
    var finalString:String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.recordButton.isEnabled = false
        speechRecognizer?.delegate = self
        
        SFSpeechRecognizer.requestAuthorization { (authStatus) in  //4
            
            var isButtonEnabled = false
            
            switch authStatus {
            case .authorized:
                isButtonEnabled = true
                
            case .denied:
                isButtonEnabled = false
                print("User denied access to speech recognition")
                
            case .restricted:
                isButtonEnabled = false
                print("Speech recognition restricted on this device")
                
            case .notDetermined:
                isButtonEnabled = false
                print("Speech recognition not yet authorized")
            }
            OperationQueue.main.addOperation() {
                self.recordButton.isEnabled = isButtonEnabled
            }
    }
}
    // start recording and get the best transcription
    func startRecording(){
        if recognitionTask != nil {
            recognitionTask?.cancel()
            recognitionTask = nil
        }
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(AVAudioSessionCategoryRecord)
            try audioSession.setMode(AVAudioSessionModeMeasurement)
            try audioSession.setActive(true, with: .notifyOthersOnDeactivation)
        } catch {
            print("audioSession properties weren't set because of an error.")
        }
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        
        guard let inputNode = audioEngine.inputNode else {
            fatalError("Audio engine has no input node")
        }
        
        guard let recognitionRequest = recognitionRequest else {
            fatalError("Unable to create an SFSpeechAudioBufferRecognitionRequest object")
        }
        
        recognitionRequest.shouldReportPartialResults = true
        
        recognitionTask = speechRecognizer?.recognitionTask(with: recognitionRequest, resultHandler: { (result, error) in
            
            var isFinal = false
            if result != nil {
                
            self.finalString = (result?.bestTranscription.formattedString)!
            isFinal = (result?.isFinal)!
            }
            
            if error != nil || isFinal {
                self.audioEngine.stop()
                inputNode.removeTap(onBus: 0)
                
                self.recognitionRequest = nil
                self.recognitionTask = nil
                
                self.recordButton.isEnabled = true
                let finalFinalString = self.reArrangeDigits(Str: self.finalString)
                self.calculationLabel.text = finalFinalString
                self.calculateString(calculationStr: self.calculationLabel.text!)
            }
        })
        
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { (buffer, when) in
            self.recognitionRequest?.append(buffer)
        }
        audioEngine.prepare()
        
        do {
            try audioEngine.start()
        } catch {
            print("audioEngine couldn't start because of an error.")
        }
        
        
    }
    
    // Rearrange String to numbers
    func reArrangeDigits(Str:String) -> String{
        
        var Str = Str
        var newString : String = ""

        if(Str.range(of: "+") != nil){
            newString = ""
            let array = Str.components(separatedBy: "+")
            for i in 0..<array.count {
            newString.append(array[i])
                if(i != array.count - 1 ){
                    newString.append(" + ")
                }
            }
            Str = newString
        }
        
        if(Str.range(of: "-") != nil){
            newString = ""
            let array = Str.components(separatedBy: "-")
            for i in 0..<array.count {
                newString.append(array[i])
                if(i != array.count - 1 ){
                    newString.append(" - ")
                }
            }
            Str = newString
        }
        if(Str.range(of: "×") != nil){
            newString = ""
            let array = Str.components(separatedBy: "×")
            for i in 0..<array.count {
                newString.append(array[i])
                if(i != array.count - 1 ){
                    newString.append(" × ")
                }
            }
            Str = newString
        }
        if(Str.range(of: "÷") != nil){
            newString = ""
            let array = Str.components(separatedBy: "÷")
            for i in 0..<array.count {
                newString.append(array[i])
                if(i != array.count - 1 ){
                    newString.append(" ÷ ")
                }
            }
            Str = newString
        }
        
        return Str
    }
    
    // make the calculation
    func calculateString(calculationStr:String){
        let parser = infixparser()
        if let calculation = parser.solve(expression: calculationStr){
            self.calculationLabel.text =  "\(calculationStr) = \(String(calculation)) " 
        }
    }
    
    // record button action to start and stop recording
    @IBAction func recordAction(_ sender: Any) {
        if audioEngine.isRunning {
            audioEngine.stop()
            recognitionRequest?.endAudio()
            recordButton.isEnabled = false
            recordButton.setTitle("Start Recording", for: .normal)
            self.calculationLabel.text = nil
        } else {
            startRecording()
            recordButton.setTitle("Stop Recording", for: .normal)
        }

    }

    func speechRecognizer(_ speechRecognizer: SFSpeechRecognizer, availabilityDidChange available: Bool) {
        if available {
            recordButton.isEnabled = true
        } else {
            recordButton.isEnabled = false
        }
    }
    
}

