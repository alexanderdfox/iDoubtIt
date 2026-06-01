//
//  GameAudio.swift
//  iDoubtIt
//
//  Procedural SFX and ambient music (no bundled audio files).
//

import AVFoundation
import UIKit

final class GameAudio {

    static let shared = GameAudio()

    private let engine = AVAudioEngine()
    private let sfxNode = AVAudioPlayerNode()
    private var musicTimer: Timer?
    private var musicStep = 0
    private var unlocked = false
    private var musicGain: Float = 0.35

    /// Must match buffer channel count (main mixer input is stereo).
    private let bufferFormat: AVAudioFormat = {
        AVAudioFormat(standardFormatWithSampleRate: 44_100, channels: 2)!
    }()

    private init() {
        engine.attach(sfxNode)
        engine.connect(sfxNode, to: engine.mainMixerNode, format: bufferFormat)
    }

    func unlock() {
        guard !unlocked else { return }
        unlocked = true
        do {
            try AVAudioSession.sharedInstance().setCategory(.ambient, options: [.mixWithOthers])
            try AVAudioSession.sharedInstance().setActive(true)
            if !engine.isRunning {
                engine.prepare()
                try engine.start()
            }
        } catch {
            print("GameAudio unlock failed: \(error)")
        }
    }

    func applyVolumes() {
        let sfx = Pref.shared.soundOn ? Float(Pref.shared.sfxVolume) : 0
        musicGain = Pref.shared.musicOn ? Float(Pref.shared.musicVolume) : 0
        engine.mainMixerNode.outputVolume = 1
        sfxNode.volume = sfx
    }

    private func playTone(
        frequency: Double,
        duration: TimeInterval,
        peak: Float,
        forMusic: Bool = false
    ) {
        if forMusic {
            guard Pref.shared.musicOn, musicGain > 0, unlocked else { return }
        } else {
            guard Pref.shared.soundOn, unlocked else { return }
        }
        unlock()
        applyVolumes()

        let effectivePeak = forMusic ? peak * musicGain : peak
        guard effectivePeak > 0 else { return }

        let sampleRate = bufferFormat.sampleRate
        let frameCount = AVAudioFrameCount(max(1, duration * sampleRate))
        guard let buffer = AVAudioPCMBuffer(pcmFormat: bufferFormat, frameCapacity: frameCount) else { return }

        buffer.frameLength = frameCount
        guard let left = buffer.floatChannelData?[0],
              let right = buffer.floatChannelData?[1] else { return }

        let twoPi = 2.0 * Double.pi
        let attack = 40.0
        let release = 40.0
        let vol = forMusic ? 1.0 : sfxNode.volume

        for i in 0..<Int(frameCount) {
            let t = Double(i) / sampleRate
            let attackEnv = min(1.0, t * attack)
            let releaseEnv = min(1.0, (duration - t) * release)
            let env = Float(attackEnv * releaseEnv)
            let sample = Float(sin(twoPi * frequency * t)) * effectivePeak * env * vol
            left[i] = sample
            right[i] = sample
        }

        sfxNode.scheduleBuffer(buffer, at: nil, options: [], completionHandler: nil)
        if !sfxNode.isPlaying { sfxNode.play() }
    }

    func ui() { playTone(frequency: 520, duration: 0.04, peak: 0.08) }
    func select() { playTone(frequency: 660, duration: 0.05, peak: 0.1) }
    func playCards() { playTone(frequency: 440, duration: 0.08, peak: 0.12) }
    func doubt() { playTone(frequency: 180, duration: 0.15, peak: 0.18) }
    func doubtWin() {
        playTone(frequency: 523, duration: 0.1, peak: 0.14)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { self.playTone(frequency: 784, duration: 0.12, peak: 0.14) }
    }
    func doubtLose() { playTone(frequency: 220, duration: 0.2, peak: 0.14) }
    func turn() { playTone(frequency: 392, duration: 0.06, peak: 0.09) }
    func deal() { playTone(frequency: 330, duration: 0.05, peak: 0.08) }
    func win() {
        playTone(frequency: 523, duration: 0.12, peak: 0.14)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.12) { self.playTone(frequency: 659, duration: 0.12, peak: 0.14) }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.24) { self.playTone(frequency: 784, duration: 0.2, peak: 0.16) }
    }

    func syncMusic() {
        stopMusic()
        guard Pref.shared.musicOn else { return }
        unlock()
        applyVolumes()
        musicStep = 0
        let timer = Timer.scheduledTimer(withTimeInterval: 0.55, repeats: true) { [weak self] _ in
            self?.musicTick()
        }
        musicTimer = timer
        RunLoop.main.add(timer, forMode: .common)
    }

    func stopMusic() {
        musicTimer?.invalidate()
        musicTimer = nil
    }

    private func musicTick() {
        guard Pref.shared.musicOn, unlocked else { return }
        let notes: [Double] = [262, 294, 330, 349, 392, 349, 330, 294]
        let freq = notes[musicStep % notes.count]
        musicStep += 1
        playTone(frequency: freq, duration: 0.45, peak: 0.04, forMusic: true)
    }

    func hapticLight() {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
    }

    func hapticMedium() {
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
    }
}
