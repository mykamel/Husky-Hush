import SwiftUI
import ServiceManagement

@main struct HuskyHushApp: App {
    @StateObject private var audio = AudioController()
    var body: some Scene {
        Window("Husky Hush", id: "controls") {
            HushPanel(audio: audio)
                .onAppear { audio.refresh() }
        }
        .windowResizability(.contentSize)
        .defaultPosition(.center)
        MenuBarExtra {
            HushPanel(audio: audio)
                .onAppear { audio.refresh() }
        } label: {
            Label(audio.wantsMuted ? (audio.confirmedMuted ? "MIC OFF" : "CHECK MIC") : "MIC ON",
                  systemImage: audio.wantsMuted ? (audio.confirmedMuted ? "mic.slash.fill" : "exclamationmark.triangle.fill") : "mic.fill")
        }
        .menuBarExtraStyle(.window)
    }
}

struct HushPanel: View {
    @ObservedObject var audio: AudioController
    @StateObject private var settings = PanelSettings()
    var color: Color { audio.wantsMuted ? (audio.confirmedMuted ? .red : .orange) : .green }
    var title: String { audio.wantsMuted ? (audio.confirmedMuted ? "Microphones muted" : "Check your microphones") : "Microphones enabled" }
    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            HStack {
                Image(systemName: "pawprint.fill").foregroundStyle(.cyan)
                Text("HUSKY HUSH").font(.system(size: 12, weight: .bold, design: .rounded)).tracking(2)
                Spacer()
                Text("FREE").font(.system(size: 9, weight: .bold)).foregroundStyle(.secondary)
            }
            VStack(spacing: 12) {
                Image(systemName: audio.wantsMuted ? "mic.slash.fill" : "mic.fill")
                    .font(.system(size: 46, weight: .medium)).foregroundStyle(color)
                    .frame(width: 94, height: 94).background(color.opacity(0.13), in: Circle())
                Text(title).font(.title3.bold())
                Text(audio.wantsMuted ? "Only you decide when to speak." : "Your apps can receive microphone audio.")
                    .font(.caption).foregroundStyle(.secondary)
            }.frame(maxWidth: .infinity)
            Button { audio.toggle() } label: {
                Text(audio.wantsMuted ? "Turn microphones on" : "Mute microphones")
                    .font(.headline).frame(maxWidth: .infinity).padding(.vertical, 10)
            }.buttonStyle(HushActionButtonStyle())
            Divider()
            VStack(alignment: .leading, spacing: 8) {
                Text("INPUT DEVICES").font(.system(size: 9, weight: .bold)).foregroundStyle(.secondary).tracking(1.5)
                if audio.devices.isEmpty { Text("No input devices detected").font(.caption).foregroundStyle(.orange) }
                ForEach(audio.devices) { device in
                    VStack(alignment: .leading, spacing: 3) {
                        Label(device.name, systemImage: "waveform").font(.caption).lineLimit(2)
                        Text(audio.deviceStatus[device.id] ?? "Checking…").font(.system(size: 10)).foregroundStyle(.secondary)
                    }
                }
                ForEach(audio.issues, id: \.self) { issue in
                    Text(issue).font(.caption).foregroundStyle(.orange).fixedSize(horizontal: false, vertical: true)
                }
            }
            Text("Controls input mute or volume on supported devices. Does not revoke app permissions. New devices and waking your Mac return Hush to mute mode. Device changes may briefly pass audio.")
                .font(.system(size: 10)).foregroundStyle(.secondary).fixedSize(horizontal: false, vertical: true)
            Toggle("Open at login", isOn: $settings.login).font(.caption).onChange(of: settings.login) { _, value in
                do {
                    if value { try SMAppService.mainApp.register() } else { try SMAppService.mainApp.unregister() }
                    settings.loginError = nil
                } catch { settings.loginError = error.localizedDescription; settings.login = SMAppService.mainApp.status == .enabled }
            }
            if let loginError = settings.loginError { Text(loginError).font(.caption).foregroundStyle(.orange) }
            HStack {
                Button("Privacy") { settings.showPrivacy.toggle() }.popover(isPresented: $settings.showPrivacy) {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Your voice stays yours.").font(.headline)
                        Link("Read the full privacy policy", destination: URL(string: "https://mykamel.github.io/Husky-Hush/privacy.html")!)
                        Text("Husky Hush does not record, listen to, transmit, or collect audio. It uses Core Audio device controls to mute input or set supported input volumes to zero. Saved device identifiers and previous input settings stay on this Mac so they can be restored when you explicitly enable microphones. No accounts, ads, analytics, or network connections.")
                        Text("Quitting leaves the current device controls unchanged. You can restore input volume in System Settings → Sound → Input if necessary.")
                    }.font(.caption).padding(20).frame(width: 330)
                }
                Link("Support", destination: URL(string: "https://mykamel.github.io/Husky-Hush/support.html")!)
                Spacer()
                Button("Quit") { NSApplication.shared.terminate(nil) }
            }.font(.caption).buttonStyle(.plain).foregroundStyle(.secondary)
        }.padding(22).frame(width: 350)
    }
}

private struct HushActionButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundStyle(.white)
            .background(
                configuration.isPressed
                    ? Color(red: 0.08, green: 0.20, blue: 0.46)
                    : Color(red: 0.12, green: 0.30, blue: 0.66),
                in: RoundedRectangle(cornerRadius: 10)
            )
            .contentShape(RoundedRectangle(cornerRadius: 10))
    }
}

@MainActor final class PanelSettings: ObservableObject {
    @Published var login = SMAppService.mainApp.status == .enabled
    @Published var loginError: String?
    @Published var showPrivacy = false
}
