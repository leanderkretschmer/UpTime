//
//  ContentView.swift
//  UpTime
//
//  Created by Leander Kretschmer on 25.11.24.
//

import SwiftUI
import UserNotifications

// Füge diese Color Extension am Anfang der Datei hinzu
extension Color {
    static let systemCardBackground = Color(.tertiarySystemBackground)
    static let systemSecondaryCardBackground = Color(.secondarySystemBackground)
    static let systemGroupedBackground = Color(.systemGroupedBackground)
    static let systemLabel = Color(.label)
    static let systemSecondaryLabel = Color(.secondaryLabel)
    
    // Status Colors
    static let statusOnline = Color.green
    static let statusOffline = Color.red
    static let statusWarning = Color.orange
    static let statusSeparator = Color(.separator)
}

struct ContentView: View {
    @StateObject private var apiManager = APIManager()
    @State private var systems: [System] = []
    @State private var services: [Service] = []
    @State private var showSettings = false
    @AppStorage("hostServer") private var hostServer = ""
    @StateObject private var networkMonitor = NetworkMonitor()
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 0) {
                    StatusCardView(
                        onlineSystems: systems.filter { $0.isOnline }.count,
                        totalSystems: systems.count,
                        onlineServices: services.filter { $0.isOnline }.count,
                        totalServices: services.count
                    )
                    .padding(.bottom, 20)
                    
                    SystemsCardView(systems: systems)
                    
                    ServicesCardView(services: services)
                        .padding(.top, 20)
                }
                .padding(.horizontal, 15)
                .padding(.top, 15)
            }
            .navigationTitle("System Status")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: { showSettings = true }) {
                        Image(systemName: "gear")
                    }
                }
            }
            .sheet(isPresented: $showSettings) {
                SettingsView(
                    hostServer: $hostServer,
                    networkMonitor: networkMonitor,
                    apiManager: apiManager
                )
            }
            .task {
                if apiManager.isAuthenticated {
                    await fetchData()
                }
            }
        }
    }
    
    private func fetchData() async {
        do {
            systems = try await apiManager.fetchSystems()
            services = try await apiManager.fetchServices()
        } catch {
            print("Error fetching data: \(error)")
        }
    }
}

// Testdaten
let testSystems = [
    System(
        id: UUID(),
        name: "Hauptserver",
        icon: "server.rack",
        isOnline: true,
        errors: [],
        pingTimes: [23, 25, 24, 26, 23],
        uptimeData: (0...23).map { _ in Double.random(in: 95...100) }
    ),
    System(
        id: UUID(),
        name: "Backup Server",
        icon: "externaldrive.server",
        isOnline: false,
        errors: ["Verbindung unterbrochen seit 14:30"],
        pingTimes: [150, 200, 0, 0, 0],
        uptimeData: (0...23).map { _ in Double.random(in: 80...100) }
    )
]

let testServices = [
    Service(
        id: UUID(),
        name: "Web API",
        icon: "network",
        isOnline: true,
        errors: [],
        pingTimes: [45, 42, 44, 43, 45],
        uptimeData: (0...23).map { _ in Double.random(in: 98...100) }
    ),
    Service(
        id: UUID(),
        name: "Datenbank",
        icon: "cylinder.split",
        isOnline: true,
        errors: ["Hohe Latenz"],
        pingTimes: [95, 98, 120, 110, 90],
        uptimeData: (0...23).map { _ in Double.random(in: 90...100) }
    )
]

// Modelle
struct System: Identifiable {
    let id: UUID
    let name: String
    let icon: String
    var isOnline: Bool
    var errors: [String]
    var pingTimes: [Int] // Letzte 5 Ping-Zeiten in ms
    var uptimeData: [Double] // 24h Uptime-Daten in Prozent
}

struct Service: Identifiable {
    let id: UUID
    let name: String
    let icon: String
    var isOnline: Bool
    var errors: [String]
    var pingTimes: [Int] // Letzte 5 Ping-Zeiten in ms
    var uptimeData: [Double] // 24h Uptime-Daten in Prozent
}

// Hilfskomponenten
struct StatusCardView: View {
    let onlineSystems: Int
    let totalSystems: Int
    let onlineServices: Int
    let totalServices: Int
    
    var body: some View {
        VStack(spacing: 12) {
            HStack(alignment: .top, spacing: 20) {
                // Linke Seite mit Statistiken
                VStack(alignment: .leading, spacing: 12) {
                    // Systems Status
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Systeme")
                            .font(.title3)
                            .foregroundColor(.systemSecondaryLabel)
                        HStack(alignment: .firstTextBaseline) {
                            Text("\(onlineSystems)/\(totalSystems)")
                                .font(.title)
                                .foregroundColor(onlineSystems == totalSystems ? .statusOnline : .statusWarning)
                            Text("Online")
                                .font(.subheadline)
                                .foregroundColor(.systemSecondaryLabel)
                        }
                    }
                    
                    Divider()
                    
                    // Services Status
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Services")
                            .font(.title3)
                            .foregroundColor(.systemSecondaryLabel)
                        HStack(alignment: .firstTextBaseline) {
                            Text("\(onlineServices)/\(totalServices)")
                                .font(.title)
                                .foregroundColor(onlineServices == totalServices ? .statusOnline : .statusWarning)
                            Text("Online")
                                .font(.subheadline)
                                .foregroundColor(.systemSecondaryLabel)
                        }
                    }
                }
                .frame(width: 150)
                
                // Vertikaler Trenner
                Rectangle()
                    .fill(Color.statusSeparator)
                    .frame(width: 1)
                    .padding(.vertical, 4)
                
                // Rechte Seite mit Graphen
                VStack(alignment: .leading, spacing: 4) {
                    Text("24h Uptime")
                        .font(.title3)
                        .foregroundColor(.systemSecondaryLabel)
                    if totalSystems > 0 || totalServices > 0 {
                        UptimeGraphView(
                            data: (0...23).map { _ in Double.random(in: 90...100) },
                            errors: []
                        )
                        .frame(height: 72)
                    } else {
                        Text("Keine Systeme verbunden")
                            .font(.caption)
                            .foregroundColor(.systemSecondaryLabel)
                            .frame(height: 72)
                            .frame(maxWidth: .infinity)
                            .background(Color(.tertiarySystemFill))
                            .cornerRadius(8)
                    }
                }
            }
        }
        .padding(15)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.systemCardBackground)
                .shadow(color: Color(.sRGBLinear, white: 0, opacity: 0.13), radius: 5, x: 0, y: 2)
        )
        .frame(maxHeight: 144)
        .padding(.bottom, 15)
    }
}

struct StatusItemView: View {
    let title: String
    let online: Int
    let total: Int
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.headline)
            HStack {
                Text("\(online)/\(total)")
                    .font(.title2)
                    .foregroundColor(online == total ? .green : .orange)
            }
        }
    }
}

struct SectionHeaderView: View {
    let title: String
    
    var body: some View {
        HStack {
            Text(title)
                .font(.headline)
                .foregroundColor(.secondary)
            Spacer()
        }
        .padding(.top)
    }
}

// Angepasste SystemRowView mit Navigation
struct SystemRowView: View {
    let system: System
    
    var body: some View {
        NavigationLink(destination: SystemDetailView(system: system)) {
            HStack {
                Image(systemName: system.icon)
                    .foregroundColor(system.isOnline ? .statusOnline : .statusOffline)
                
                VStack(alignment: .leading) {
                    Text(system.name)
                        .font(.headline)
                        .foregroundColor(.systemLabel)
                    if !system.errors.isEmpty {
                        Text(system.errors.first ?? "")
                            .font(.caption)
                            .foregroundColor(.statusOffline)
                    }
                }
                
                Spacer()
                
                Image(systemName: system.isOnline ? "checkmark.circle.fill" : "xmark.circle.fill")
                    .foregroundColor(system.isOnline ? .statusOnline : .statusOffline)
            }
        }
        .frame(height: 60)
        .padding()
        .background(Color.systemSecondaryCardBackground)
        .cornerRadius(10)
    }
}

// Angepasste ServiceRowView mit Navigation
struct ServiceRowView: View {
    let service: Service
    
    var body: some View {
        NavigationLink(destination: ServiceDetailView(service: service)) {
            HStack {
                Image(systemName: service.icon)
                    .foregroundColor(service.isOnline ? .green : .red)
                
                VStack(alignment: .leading) {
                    Text(service.name)
                        .font(.headline)
                    if !service.errors.isEmpty {
                        Text(service.errors.first ?? "")
                            .font(.caption)
                            .foregroundColor(.red)
                    }
                }
                
                Spacer()
                
                Image(systemName: service.isOnline ? "checkmark.circle.fill" : "xmark.circle.fill")
                    .foregroundColor(service.isOnline ? .green : .red)
            }
        }
        .frame(height: 60)
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(10)
    }
}

// Neue Detail Views
struct SystemDetailView: View {
    let system: System
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                HStack {
                    Image(systemName: system.icon)
                        .font(.largeTitle)
                        .foregroundColor(system.isOnline ? .green : .red)
                    Text(system.name)
                        .font(.title)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal)
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("24h Uptime & Fehler")
                        .font(.headline)
                    UptimeGraphView(
                        data: system.uptimeData,
                        errors: system.errors
                    )
                    .frame(height: 200)
                }
                .padding()
                .background(Color(.systemBackground))
                .cornerRadius(12)
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Ping Zeiten")
                        .font(.headline)
                    HStack {
                        ForEach(system.pingTimes, id: \.self) { time in
                            Text("\(time)ms")
                                .padding(8)
                                .background(pingTimeColor(time))
                                .cornerRadius(8)
                        }
                    }
                }
                .padding()
                .background(Color(.systemBackground))
                .cornerRadius(12)
                
                if !system.errors.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .foregroundColor(.red)
                            Text("Fehlermeldungen")
                                .font(.headline)
                                .padding(5.0)
                        }
                        ForEach(system.errors, id: \.self) { error in
                            Text(error)
                                .foregroundColor(.red)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color(.systemBackground))
                    .cornerRadius(12)
                }
            }
            .padding()
        }
        .navigationBarTitleDisplayMode(.inline)
        .background(Color(.systemGroupedBackground))
    }
    
    private func pingTimeColor(_ time: Int) -> Color {
        if time == 0 { return .red }
        if time < 50 { return .green }
        if time < 100 { return .yellow }
        return .orange
    }
}

struct ServiceDetailView: View {
    let service: Service
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                HStack {
                    Image(systemName: service.icon)
                        .font(.largeTitle)
                        .foregroundColor(service.isOnline ? .green : .red)
                    Text(service.name)
                        .font(.title)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal)
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("24h Uptime & Fehler")
                        .font(.headline)
                    UptimeGraphView(
                        data: service.uptimeData,
                        errors: service.errors
                    )
                    .frame(height: 200)
                }
                .padding()
                .background(Color(.systemBackground))
                .cornerRadius(12)
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Ping Zeiten")
                        .font(.headline)
                    HStack {
                        ForEach(service.pingTimes, id: \.self) { time in
                            Text("\(time)ms")
                                .padding(8)
                                .background(pingTimeColor(time))
                                .cornerRadius(8)
                        }
                    }
                }
                .padding()
                .background(Color(.systemBackground))
                .cornerRadius(12)
                
                if !service.errors.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .foregroundColor(.red)
                            Text("Fehlermeldungen")
                                .font(.headline)
                        }
                        ForEach(service.errors, id: \.self) { error in
                            Text(error)
                                .foregroundColor(.red)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color(.systemBackground))
                    .cornerRadius(12)
                }
            }
            .padding()
        }
        .navigationBarTitleDisplayMode(.inline)
        .background(Color(.systemGroupedBackground))
    }
    
    private func pingTimeColor(_ time: Int) -> Color {
        if time == 0 { return .red }
        if time < 50 { return .green }
        if time < 100 { return .yellow }
        return .orange
    }
}

// Verbesserter UptimeGraphView
struct UptimeGraphView: View {
    let data: [Double]
    let errors: [String]
    
    var body: some View {
        GeometryReader { geometry in
            VStack(alignment: .leading, spacing: 8) {
                // Uptime Graph
                ZStack {
                    // Uptime Linie
                    Path { path in
                        let width = geometry.size.width
                        let height = geometry.size.height * 0.7
                        let points = generatePointsFromData(data, in: CGRect(x: 0, y: 0, width: width, height: height))
                        
                        path.move(to: points[0])
                        for point in points.dropFirst() {
                            path.addLine(to: point)
                        }
                    }
                    .stroke(Color.statusOnline, style: StrokeStyle(lineWidth: 2, lineCap: .round, lineJoin: .round))
                }
                .frame(height: geometry.size.height * 0.7)
                
                // Fehler Timeline
                ZStack(alignment: .leading) {
                    Rectangle()
                        .fill(Color(.tertiarySystemFill))
                        .frame(height: geometry.size.height * 0.2)
                    
                    // Fehler-Indikatoren mit fester Breite
                    HStack(spacing: 0) {
                        ForEach(0..<24) { hour in
                            if !errors.isEmpty && hour % 3 == 0 {
                                Rectangle()
                                    .fill(Color.red.opacity(0.3))
                                    .frame(width: 2)
                            }
                            if hour < 23 { // Verhindert extra Spacer am Ende
                                Spacer()
                            }
                        }
                    }
                    .frame(width: geometry.size.width) // Explizite Breite
                }
                
                // Zeitskala
                HStack {
                    Text("00:00")
                        .font(.caption2)
                        .foregroundColor(.systemSecondaryLabel)
                    Spacer()
                    Text("12:00")
                        .font(.caption2)
                        .foregroundColor(.systemSecondaryLabel)
                    Spacer()
                    Text("23:59")
                        .font(.caption2)
                        .foregroundColor(.systemSecondaryLabel)
                }
            }
        }
    }
    
    private func generatePointsFromData(_ data: [Double], in rect: CGRect) -> [CGPoint] {
        var points: [CGPoint] = []
        let width = rect.width
        let height = rect.height
        
        for (index, value) in data.enumerated() {
            let x = width * CGFloat(index) / CGFloat(data.count - 1)
            let normalizedValue = (value - 0) / (100 - 0)
            let y = height * (1 - CGFloat(normalizedValue))
            points.append(CGPoint(x: x, y: y))
        }
        return points
    }
}

struct SettingsView: View {
    @Binding var hostServer: String
    @ObservedObject var networkMonitor: NetworkMonitor
    @ObservedObject var apiManager: APIManager
    @Environment(\.dismiss) private var dismiss
    
    @State private var showingAuthSheet = false
    @State private var username = ""
    @State private var password = ""
    @State private var showingError = false
    @State private var errorMessage = ""
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Server Konfiguration")) {
                    TextField("Host Server URL", text: $hostServer)
                        .autocapitalization(.none)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                        .onSubmit {
                            if !hostServer.isEmpty {
                                apiManager.setBaseURL(hostServer)
                                showingAuthSheet = true
                            }
                        }
                        .onChange(of: hostServer) { _ in
                            // Entfernung des automatischen Auth-Sheet-Triggers
                        }
                    if apiManager.isAuthenticated {
                        Label("Verbunden", systemImage: "checkmark.circle.fill")
                            .foregroundColor(.green)
                    }
                }
                
                Section(header: Text("Benachrichtigungen")) {
                    Toggle("Benachrichtigungen aktivieren", isOn: Binding(
                        get: { networkMonitor.notificationsEnabled },
                        set: { networkMonitor.setNotificationsEnabled($0) }
                    ))
                    
                    if networkMonitor.notificationsEnabled {
                        Stepper("Benachrichtigung nach \(networkMonitor.maxFailedPings) Pings",
                               value: Binding(
                                get: { networkMonitor.maxFailedPings },
                                set: { networkMonitor.setMaxFailedPings($0) }
                               ),
                               in: 1...10)
                        
                        Text("Die App wird Sie benachrichtigen, wenn ein Service \(networkMonitor.maxFailedPings) mal hintereinander nicht erreichbar ist.")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                Section(header: Text("Hintergrund-Aktualisierung")) {
                    Picker("Aktualisierungsintervall", selection: Binding(
                        get: { networkMonitor.backgroundRefreshInterval },
                        set: { networkMonitor.setBackgroundRefreshInterval($0) }
                    )) {
                        ForEach(Array(networkMonitor.refreshIntervals.keys).sorted(), id: \.self) { minutes in
                            Text(networkMonitor.refreshIntervals[minutes] ?? "\(minutes) Minuten")
                                .tag(minutes)
                        }
                    }
                    
                    Text("Die App wird im Hintergrund alle \(networkMonitor.refreshIntervals[networkMonitor.backgroundRefreshInterval] ?? "\(networkMonitor.backgroundRefreshInterval) Minuten") nach Änderungen suchen")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .navigationTitle("Einstellungen")
            .navigationBarItems(trailing: Button("Fertig") {
                dismiss()
            })
            .sheet(isPresented: $showingAuthSheet) {
                AuthenticationView(
                    username: $username,
                    password: $password,
                    apiManager: apiManager,
                    showingError: $showingError,
                    errorMessage: $errorMessage
                )
            }
            .alert("Fehler", isPresented: $showingError) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(errorMessage)
            }
        }
    }
}

struct AuthenticationView: View {
    @Binding var username: String
    @Binding var password: String
    @ObservedObject var apiManager: APIManager
    @Binding var showingError: Bool
    @Binding var errorMessage: String
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Anmeldedaten")) {
                    TextField("Benutzername", text: $username)
                        .autocapitalization(.none)
                    SecureField("Passwort", text: $password)
                }
            }
            .navigationTitle("Anmeldung")
            .navigationBarItems(
                leading: Button("Abbrechen") {
                    dismiss()
                },
                trailing: Button("Anmelden") {
                    authenticate()
                }
            )
        }
    }
    
    private func authenticate() {
        Task {
            do {
                try await apiManager.authenticate(username: username, password: password)
                dismiss()
            } catch {
                errorMessage = error.localizedDescription
                showingError = true
            }
        }
    }
}

// Neue Card Views für Systeme und Services
struct SystemsCardView: View {
    let systems: [System]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Systeme")
                .font(.headline)
                .foregroundColor(.systemSecondaryLabel)
            
            ForEach(systems) { system in
                SystemRowView(system: system)
            }
        }
        .padding(15)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.systemCardBackground)
                .shadow(color: Color(.sRGBLinear, white: 0, opacity: 0.13), radius: 5, x: 0, y: 2)
        )
    }
}

struct ServicesCardView: View {
    let services: [Service]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Services")
                .font(.headline)
                .foregroundColor(.systemSecondaryLabel)
            
            ForEach(services) { service in
                ServiceRowView(service: service)
            }
        }
        .padding(15)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.systemCardBackground)
                .shadow(color: Color(.sRGBLinear, white: 0, opacity: 0.13), radius: 5, x: 0, y: 2)
        )
    }
}

#Preview {
    ContentView()
}
