//
//  ViewController.swift
//  firstScreen
//
//  Created by Renata Faria on 17/03/19.
//  Copyright © 2019 Renata Faria. All rights reserved.
//

import UIKit
import AVFoundation
import PlaygroundSupport

@objc(Book_Sources_FirstScreenController)
public class FirstScreenController: UIViewController, UIGestureRecognizerDelegate, AVSpeechSynthesizerDelegate, PlaygroundLiveViewMessageHandler, PlaygroundLiveViewSafeAreaContainer {
    
    //  MARK: variables
    var index = 0
    var isAutomaticMode = true
    var voiceSynth: AVSpeechSynthesizer!
    var isPaused = true
    
    //  MARK: Outlets
    @IBOutlet weak var textLabel: UILabel!
    @IBOutlet weak var rectangle: UIImageView!
    @IBOutlet weak var backgroundImage: UIImageView!
    @IBAction func isAutomaticMode(_ sender: UISwitch) {
        isAutomaticMode = sender.isOn
        if isAutomaticMode {
            isPaused = true
            self.pause()
            self.move()
        }
    }
    
    var isSpeaking = false
    override public func viewDidLoad() {
        super.viewDidLoad()
        self.configureGestures()
        self.voiceSynth = AVSpeechSynthesizer()
        self.voiceSynth.delegate = self
    }
    func configureGestures() {
        let pauseTap = UITapGestureRecognizer(target: self, action:#selector(self.pause(_:)))
        pauseTap.numberOfTapsRequired = 1
        view.addGestureRecognizer(pauseTap)
        let rightSwipe = UISwipeGestureRecognizer(target: self, action: #selector(self.didSwipe(_:)))
        rightSwipe.direction = .right
        view.addGestureRecognizer(rightSwipe)
        let leftSwipe = UISwipeGestureRecognizer(target: self, action: #selector(self.didSwipe(_:)))
        rightSwipe.direction = .left
        view.addGestureRecognizer(leftSwipe)
    }
    func pause() {
        let player = CustomAudioPlayer()
        if isPaused {
            player.play("wwdc19", format: "wav", volume: 0.1, numberOfLoops: -1)
            voiceSynth.continueSpeaking()
            index -= index == 0 ? 0 : 1
            isPaused = false
            self.move()
        } else {
            player.pauseAudio()
            voiceSynth.stopSpeaking(at: .immediate)
            isPaused = true
        }
    }
    @objc func pause(_ sender: UITapGestureRecognizer) {
        if !isAutomaticMode || self.textLabel.isHidden {
            self.pause()
        }
    }
    @objc func didSwipe(_ sender: UISwipeGestureRecognizer) {
        if index == 0 { return }
        if !isAutomaticMode {
            let isFoward = sender.direction == .left
            index += isFoward ? 0 : index < 2 ? -1 : -2
            move()
        }
    }
    
    private func move() {
        if index == 0 { self.textLabel.isHidden = false }
        guard textList.count - 1 >= index else { return }
        self.speak(textList[index], delay: true, imageString: backgroundImages[index], isKaren: index != 8)
        index += 1
    }
    private func speak(_ what: String, delay: Bool, imageString: String, isKaren: Bool) {
        self.setBackImage(imageString)
        self.textLabel.text = what
        if !isPaused {
            self.speak(this: what, isKaren)
        }
        if delay { sleep(UInt32(0.5)) }
    }
    private func setBackImage(_ imageName: String) {
        if let image = UIImage.init(named: imageName) {
            if imageName == "main" || imageName == "anotherPerson"{
                self.backgroundImage.image = image
                self.backgroundImage.isHidden = false
                self.rectangle.isHidden = true
            } else {
                self.backgroundImage.isHidden = true
                self.rectangle.isHidden = false
                self.rectangle.image = image
            }
        } else {
            if let defaultImage = UIImage.init(named: "main") {
                self.backgroundImage.image = defaultImage
            }
        }
        
    }
    public func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        isSpeaking = false
        if self.isAutomaticMode {
            self.move()
        }
    }
    private func speak(this text: String, _ isKaren: Bool) {
        let utterance = AVSpeechUtterance(string: text)
        utterance.pitchMultiplier = 1.5
        utterance.rate =  0.4
        let voice = isKaren ? "Karen" : "Daniel"
        utterance.voice = AVSpeechSynthesisVoice.speechVoices().filter({ $0.name == voice }).first
        voiceSynth.stopSpeaking(at: .immediate)
        voiceSynth.speak(utterance)
    }
    // MARK: - arrays
    var backgroundImages = ["main","main","main","main", // 0 1 2 3
        "staf", "lines", "space", // 4 5 6
        "spaces", "anotherPerson", "main", // 7 8 9
        "gClef", "withG", "withG", // 10 11 12
        "notesPosition","main", "main", "main", "whole", // 13 14 15 16 17
        "half", "quarter", "eight", "noteWithStem", // 18 19 20 21
        "noteWithStem", "main", "main", "xylophone", "main" ] // 22 23 24 25 26
    var textList =
        [
            // Introduction
            "Hello my name is Renata, is a pleasure to have you here!", //0
            "In this playground you will learn about basic score reading, and in the end you'll have the chance to practice in an augmented reality Xylophone!", //1
            "Hope you are as excited as I am!", //2
            "The first thing you need to know is the components that make the score", //3
            "The main one is called staff. Is in it that you will put the notes, it contains..",//4
            "5 lines", //5
            "and 4 spaces", //6
            "But's possible to add new lines and spaces before and after the staff, you will see it happening soon. ", //7
            "But how do I know where to put every note,  in which line or in which space?", // 8
            "That's why we have clefs", //9
            "In this playground we will just introduce the G one", // 11
            "The function of the clef is to indicate the pitch of written notes", // 10
            "Knowing that the score have this clef you also know that the G note will be localized in the second line", // 12
            "The same way we know the position of the next and previous notes", // 13
            "Besides the position, the notes also have different timing, which means how fast you will play each one of them", // 14
            "To be possible to recognize how long the timing will be, we change the drawing and the name of them", // 15
            "In this playground we will just know the following:", //16
            // notes:
            "Whole Note: Its length is equal to four beats","Half Note: half of the time of the whole note","Quarter Note: quarter part of the time of the whole note","Eighth Note: eighth part of the time of the whole note", // 17, 18, 19, 20
            //
            "Knowing the form, you can identify the notes in the staff, but notice that from the 4th space on the stem of the note will be drawn upside down", //21
            "Also, sometimes when we use the eighth to much close to another note, we connect it with the next note using what we call beam, what will make your staff looks organized", //22
            // How to use my xylophone
            "That's all.. I know that it is not enough to play everything you want, but it’s just an introduction", // 23
            "But, to prove you learnt a bit, let’s try to play in almost real instrument!",// 24
            "Before you go to xylophone, this is a picture of it, that will be available in the contents, to you to check during the whole experience.", // 25
            "That’s it! Hope you have fun!" // 26
    ]
}

