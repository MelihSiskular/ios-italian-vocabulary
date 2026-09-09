import AVFoundation


final class PronunciationService {
    
    static let shared =
    PronunciationService()
    
    private let synthesizer =
    AVSpeechSynthesizer()
    
    
    private init() {}
    
    
    func speakItalian(
        _ text: String
    ) {
        
        let cleanText =
        text.trimmingCharacters(
            in: .whitespacesAndNewlines
        )
        
        guard !cleanText.isEmpty else {
            return
        }
        
        
        if synthesizer.isSpeaking {
            
            synthesizer.stopSpeaking(
                at: .immediate
            )
        }
        
        
        let utterance =
        AVSpeechUtterance(
            string: cleanText
        )
        
        utterance.voice =
        bestItalianVoice()
        ?? AVSpeechSynthesisVoice(
            language: "it-IT"
        )
        
        utterance.rate = 0.45
        utterance.pitchMultiplier = 1.0
        utterance.volume = 1.0
        
        
        do {
            
            let audioSession =
            AVAudioSession.sharedInstance()
            
            try audioSession.setCategory(
                .playback,
                mode: .spokenAudio
            )
            
            try audioSession.setActive(
                true
            )
            
        } catch {
            
            print(
                "⚠️ Audio session error:",
                error
            )
        }
        
        
        synthesizer.speak(
            utterance
        )
    }
    
    
    private func bestItalianVoice()
    -> AVSpeechSynthesisVoice? {
        
        AVSpeechSynthesisVoice
            .speechVoices()
            .filter {
                
                $0.language
                    .hasPrefix("it")
            }
            .sorted {
                
                $0.quality.rawValue
                > $1.quality.rawValue
            }
            .first
    }
}
