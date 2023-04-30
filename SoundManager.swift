//
//  SoundManager.swift
//  Quaver
//
//  Created by Eduardo Stefanel Paludo on 07/04/23.
//

import AVFoundation

class SoundManager {
    
    private var soundDict: [Sound:AVAudioPlayer?] = [:]
    
    init() {
        for sound in Sound.allCases {
            soundDict[sound] = getAudioPlayer(sound: sound)
        }
    }
    
    private func getAudioPlayer(sound: Sound) -> AVAudioPlayer? {
        guard let url = Bundle.main.url(
            forResource: sound.rawValue,
            withExtension: ".m4a"
        ) else {
            print("Fail to get url for \(sound)")
            return nil
        }

        var audioPlayer: AVAudioPlayer?
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.prepareToPlay()
            return audioPlayer
        } catch {
            print("Fail to load \(sound)")
            return nil
        }
    }
        
    func playLoop(sound: Sound) {
        guard let audioPlayer = soundDict[sound, default: nil] else { return }
        audioPlayer.numberOfLoops = -1
        audioPlayer.play()
    }
    
    func play(_ sound: Sound, withVolume volume: Float = 2) {
        guard let audioPlayer = soundDict[sound, default: nil] else { return }
        audioPlayer.volume = volume
        audioPlayer.play()
    }
    
    func pause(sound: Sound) {
        guard let audioPlayer = soundDict[sound, default: nil] else { return }
        audioPlayer.pause()
    }
    
    func stop(_ sound: Sound) {
        guard let audioPlayer = soundDict[sound, default: nil] else { return }
        audioPlayer.currentTime = 0
        audioPlayer.pause()
        
    }
    
    func fadeIn(sound: Sound, withVolume volume: Float = 1) {
        guard let audioPlayer = soundDict[sound, default: nil] else { return }
        audioPlayer.volume = 0
        audioPlayer.play()
        audioPlayer.setVolume(volume, fadeDuration: 1)
    }
    
    func fadeOut(sound: Sound) {
        guard let audioPlayer = soundDict[sound, default: nil] else { return }
        audioPlayer.setVolume(0, fadeDuration: 2)
    }
    
    
    func isPlaying(sound: Sound) -> Bool {
        guard let audioPlayer = soundDict[sound, default: nil] else { return false }
        return audioPlayer.isPlaying
    }
    
    func currentTime(sound: Sound) -> TimeInterval {
        guard let audioPlayer = soundDict[sound, default: nil] else { return 0 }
        return audioPlayer.currentTime
    }
    
    enum Sound: String, CaseIterable {
        case swanLakeOrchestra
        
        // MelodyScene
        case E4
        case Dsharp4
        case B3
        case D4
        case C4
        case A3
        case furElise
        
        // PitchScene
        case C0
        case C1
        case C2
        case C3
        //case C4
        case C5
        case C6
        case winterWind
        
        // RhythmScene
        case Fsharp4
        case B3x
        case Csharp4
        case D4x
        case E4x
        case swanLake
        case cortaJaca
        
        // HarmonyScene
        case Am
        case Dm7
        case G7
        case Cmaj
        case Fmaj
        case E7
        case Amx
        case clairDeLune
        
        // DynamicsScene
        case Eflat3
        case F3
        case G3x
        case Aflat3
        case Bflat3
        case B3y
        case C4x
        case Eflat4
        case pathetique
    }
}
