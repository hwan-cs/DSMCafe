//
//  TTSManager.swift
//  DSMCafe
//
//  Created by Jung Hwan Park on 2022/10/26.
//

import AVFoundation

class TTSManager
{
    
    static let shared = TTSManager()
    
    private let synthesizer = AVSpeechSynthesizer()
    
    internal func play(_ string: String)
    {
        let utterance = AVSpeechUtterance(string: string)
        utterance.voice = AVSpeechSynthesisVoice(language: "ko-KR")
        utterance.rate = 0.4
        synthesizer.stopSpeaking(at: .immediate)
        synthesizer.speak(utterance)
    }
    
    internal func stop() {
        synthesizer.stopSpeaking(at: .immediate)
    }
}
