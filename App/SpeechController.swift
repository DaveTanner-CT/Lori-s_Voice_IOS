import AVFoundation

final class SpeechController {
    private let synthesizer = AVSpeechSynthesizer()

    func speak(
        text: String,
        webRate: Double,
        voiceIdentifier: String?,
        voiceName: String?,
        language: String?
    ) {
        guard !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }

        do {
            let session = AVAudioSession.sharedInstance()
            // Playback keeps speech available even when the device's Ring/Silent switch
            // is muted, which is important for an AAC communication app.
            try session.setCategory(.playback, mode: .spokenAudio, options: [.duckOthers])
            try session.setActive(true)
        } catch {
            // Speech can still work if the audio session cannot be changed.
        }

        synthesizer.stopSpeaking(at: .immediate)

        let utterance = AVSpeechUtterance(string: text)
        utterance.pitchMultiplier = 1.0
        utterance.rate = Self.nativeRate(fromWebRate: webRate)

        if let voiceIdentifier,
           !voiceIdentifier.isEmpty,
           let exactVoice = AVSpeechSynthesisVoice(identifier: voiceIdentifier) {
            utterance.voice = exactVoice
        } else if let voiceName, !voiceName.isEmpty,
                  let namedVoice = AVSpeechSynthesisVoice.speechVoices().first(where: { $0.name == voiceName }) {
            utterance.voice = namedVoice
        } else if let language, !language.isEmpty {
            utterance.voice = AVSpeechSynthesisVoice(language: language)
        } else {
            utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
        }

        synthesizer.speak(utterance)
    }

    private static func nativeRate(fromWebRate webRate: Double) -> Float {
        // Lori's Voice intentionally uses three clearly separated speech speeds.
        // The HTML stores 0.62 / 0.74 / 0.92 for backward compatibility with
        // existing saved boards, but native iOS speech uses these fixed AVSpeech rates.
        if webRate < 0.69 {
            return 0.30   // Slow
        }
        if webRate < 0.85 {
            return 0.40   // Normal
        }
        return 0.52       // Fast
    }
}
