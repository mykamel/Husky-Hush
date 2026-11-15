import Foundation
import CoreAudio
import Combine

struct MicDevice: Identifiable {
    let id: AudioDeviceID
    let name: String
    let uid: String
    let channels: UInt32
}
struct AudioControl: Hashable, Codable {
    let selector: UInt32
    let element: UInt32
}
struct SavedControl: Codable {
    let control: AudioControl
    let value: Float
}

/// Controls device input properties only. Never opens an audio stream or records sound.
@MainActor final class AudioController: ObservableObject {
    @Published private(set) var wantsMuted = true
    @Published private(set) var devices: [MicDevice] = []
    @Published private(set) var issues: [String] = []
    @Published private(set) var confirmedMuted = false
    @Published private(set) var deviceStatus: [AudioDeviceID: String] = [:]
    private var saved: [String: [SavedControl]] = [:]
    private var knownUIDs: Set<String> = []
    private var timer: Timer?
    private let system = AudioObjectID(kAudioObjectSystemObject)
    private var deviceListener: AudioObjectPropertyListenerBlock?
    private let persistenceKey = "SavedInputControls.v1"
    
    init() {
        if let data = UserDefaults.standard.data(forKey: persistenceKey),
           let values = try? JSONDecoder().decode([String: [SavedControl]].self, from: data) { saved = values }
        refresh()
        let listener: AudioObjectPropertyListenerBlock = { [weak self] _, _ in
            Task { @MainActor in self?.refresh() }
        }
        deviceListener = listener
        var address = AudioObjectPropertyAddress(mSelector: kAudioHardwarePropertyDevices,
                                                mScope: kAudioObjectPropertyScopeGlobal, mElement: 0)
        AudioObjectAddPropertyListenerBlock(system, &address, .main, listener)
        timer = Timer.scheduledTimer(withTimeInterval: 0.4, repeats: true) { [weak self] _ in
            Task { @MainActor in self?.refresh() }
        }
        NSWorkspaceBridge.observeWake { [weak self] in self?.mute() }
    }
    func toggle() { wantsMuted ? unmute() : mute() }
    func mute() { wantsMuted = true; refresh() }
    func unmute() {
        // Only an explicit user action restores controls saved by this app.
        wantsMuted = false
        var failures: [String] = []
        for device in devices {
            guard let controls = saved[device.uid] else { continue }
            var failed: [SavedControl] = []
            for item in controls {
                if !write(device.id, item.control, item.value) { failed.append(item) }
            }
            if failed.isEmpty { saved.removeValue(forKey: device.uid) }
            else { saved[device.uid] = failed; failures.append("Could not restore \(device.name)") }
        }
        persist()
        issues = failures
        confirmedMuted = false
        refresh()
    }
    func refresh() {
        let found = inputDevices()
        let uids = Set(found.map(\.uid))
        if !uids.subtracting(knownUIDs).isEmpty { wantsMuted = true }
        knownUIDs = uids
        devices = found
        if wantsMuted {
            var failures: [String] = []
            for device in found {
                guard let controls = muteControls(device) else {
                    failures.append("\(device.name): no supported mute or input-volume control")
                    continue
                }
                var snapshot = saved[device.uid] ?? []
                for control in controls {
                    guard let current = read(device.id, control) else {
                        failures.append("\(device.name): cannot read input control")
                        continue
                    }
                    let target: Float = control.selector == kAudioDevicePropertyMute ? 1 : 0
                    if !snapshot.contains(where: { $0.control == control }) {
                        snapshot.append(SavedControl(control: control, value: current))
                        saved[device.uid] = snapshot
                        persist() // Keep restoration values even if the app is interrupted.
                    }
                    if current != target { _ = write(device.id, control, target) }
                    guard let actual = read(device.id, control), abs(actual - target) < 0.0001 else {
                        failures.append("\(device.name): mute could not be verified")
                        continue
                    }
                }
            }
            issues = Array(Set(failures)).sorted()
            confirmedMuted = !found.isEmpty && failures.isEmpty
        } else { confirmedMuted = false }
        deviceStatus = Dictionary(uniqueKeysWithValues: found.map { device in
            guard let controls = muteControls(device) else { return (device.id, "Unsupported input controls") }
            let values = controls.compactMap { read(device.id, $0) }
            guard values.count == controls.count else { return (device.id, "Cannot verify input controls") }
            if controls[0].selector == kAudioDevicePropertyMute {
                return (device.id, values.allSatisfy { $0 == 1 } ? "Hardware mute: on" : "Hardware mute: off")
            }
            let maximum = values.max() ?? 0
            return (device.id, "Input level: \(Int((maximum * 100).rounded()))%")
        })
    }
    private func persist() {
        if let data = try? JSONEncoder().encode(saved) { UserDefaults.standard.set(data, forKey: persistenceKey) }
    }
    private func address(_ control: AudioControl) -> AudioObjectPropertyAddress {
        AudioObjectPropertyAddress(mSelector: control.selector, mScope: kAudioDevicePropertyScopeInput, mElement: control.element)
    }
    private func writable(_ id: AudioDeviceID, _ control: AudioControl) -> Bool {
        var a = address(control); var settable: DarwinBoolean = false
        return AudioObjectHasProperty(id, &a) && AudioObjectIsPropertySettable(id, &a, &settable) == noErr && settable.boolValue
    }
    private func read(_ id: AudioDeviceID, _ control: AudioControl) -> Float? {
        var a = address(control); var size: UInt32 = 4
        if control.selector == kAudioDevicePropertyMute {
            var value: UInt32 = 0
            guard AudioObjectGetPropertyData(id, &a, 0, nil, &size, &value) == noErr else { return nil }
            return Float(value)
        }
        var value: Float32 = 0
        guard AudioObjectGetPropertyData(id, &a, 0, nil, &size, &value) == noErr else { return nil }
        return value
    }
    private func write(_ id: AudioDeviceID, _ control: AudioControl, _ value: Float) -> Bool {
        var a = address(control)
        if control.selector == kAudioDevicePropertyMute {
            var raw = UInt32(value)
            return AudioObjectSetPropertyData(id, &a, 0, nil, 4, &raw) == noErr
        }
        var raw = value
        return AudioObjectSetPropertyData(id, &a, 0, nil, 4, &raw) == noErr
    }
    private func muteControls(_ device: MicDevice) -> [AudioControl]? {
        // A master control covers all channels. Otherwise require controls on every channel.
        for selector in [kAudioDevicePropertyMute, kAudioDevicePropertyVolumeScalar] {
            let master = AudioControl(selector: selector, element: 0)
            if writable(device.id, master) { return [master] }
            let channels = (1...device.channels).map { AudioControl(selector: selector, element: $0) }
            if channels.allSatisfy({ writable(device.id, $0) }) { return channels }
        }
        return nil
    }
    private func inputDevices() -> [MicDevice] {
        var a = AudioObjectPropertyAddress(mSelector: kAudioHardwarePropertyDevices, mScope: kAudioObjectPropertyScopeGlobal, mElement: 0)
        var size: UInt32 = 0
        guard AudioObjectGetPropertyDataSize(system, &a, 0, nil, &size) == noErr else { return [] }
        var ids = [AudioDeviceID](repeating: 0, count: Int(size) / MemoryLayout<AudioDeviceID>.size)
        guard AudioObjectGetPropertyData(system, &a, 0, nil, &size, &ids) == noErr else { return [] }
        return ids.compactMap { id in
            var config = AudioObjectPropertyAddress(mSelector: kAudioDevicePropertyStreamConfiguration, mScope: kAudioDevicePropertyScopeInput, mElement: 0)
            var bytes: UInt32 = 0
            guard AudioObjectGetPropertyDataSize(id, &config, 0, nil, &bytes) == noErr, bytes > 0 else { return nil }
            let buffer = UnsafeMutableRawPointer.allocate(byteCount: Int(bytes), alignment: MemoryLayout<AudioBufferList>.alignment)
            defer { buffer.deallocate() }
            guard AudioObjectGetPropertyData(id, &config, 0, nil, &bytes, buffer) == noErr else { return nil }
            let list = UnsafeMutableAudioBufferListPointer(buffer.assumingMemoryBound(to: AudioBufferList.self))
            let channels = list.reduce(UInt32(0)) { $0 + $1.mNumberChannels }
            guard channels > 0, let uid = string(id, kAudioDevicePropertyDeviceUID) else { return nil }
            return MicDevice(id: id, name: string(id, kAudioObjectPropertyName) ?? "Microphone", uid: uid, channels: channels)
        }
    }
    private func string(_ id: AudioDeviceID, _ selector: UInt32) -> String? {
        var a = AudioObjectPropertyAddress(mSelector: selector, mScope: kAudioObjectPropertyScopeGlobal, mElement: 0)
        let value = UnsafeMutablePointer<CFString?>.allocate(capacity: 1)
        value.initialize(to: nil)
        defer { value.deinitialize(count: 1); value.deallocate() }
        var size = UInt32(MemoryLayout<CFString?>.size)
        guard AudioObjectGetPropertyData(id, &a, 0, nil, &size, value) == noErr else { return nil }
        return value.pointee as String?
    }
}

import AppKit
@MainActor enum NSWorkspaceBridge {
    static var observers: [NSObjectProtocol] = []
    static func observeWake(_ action: @escaping @MainActor () -> Void) {
        for name in [NSWorkspace.didWakeNotification, NSWorkspace.screensDidWakeNotification] {
            observers.append(NSWorkspace.shared.notificationCenter.addObserver(forName: name, object: nil, queue: .main) { _ in
                Task { @MainActor in action() }
            })
        }
    }
}
