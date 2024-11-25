import Foundation

class APIManager: ObservableObject {
    @Published var isAuthenticated = false
    private var baseURL: String = ""
    private var authToken: String = ""
    
    struct Credentials: Codable {
        let username: String
        let password: String
    }
    
    struct AuthResponse: Codable {
        let token: String
    }
    
    struct APIError: Codable {
        let message: String
    }
    
    // API Response Strukturen
    struct APISystem: Codable {
        let id: String
        let name: String
        let icon: String
        let isOnline: Bool
        let errors: [String]
        let pingTimes: [Int]
        let uptimeData: [Double]
        
        func toSystem() -> System {
            return System(
                id: UUID(uuidString: id) ?? UUID(),
                name: name,
                icon: icon,
                isOnline: isOnline,
                errors: errors,
                pingTimes: pingTimes,
                uptimeData: uptimeData
            )
        }
    }
    
    struct APIService: Codable {
        let id: String
        let name: String
        let icon: String
        let isOnline: Bool
        let errors: [String]
        let pingTimes: [Int]
        let uptimeData: [Double]
        
        func toService() -> Service {
            return Service(
                id: UUID(uuidString: id) ?? UUID(),
                name: name,
                icon: icon,
                isOnline: isOnline,
                errors: errors,
                pingTimes: pingTimes,
                uptimeData: uptimeData
            )
        }
    }
    
    func setBaseURL(_ url: String) {
        baseURL = url.hasSuffix("/") ? url : url + "/"
    }
    
    func authenticate(username: String, password: String) async throws {
        guard let url = URL(string: "\(baseURL)auth") else {
            throw URLError(.badURL)
        }
        
        let credentials = Credentials(username: username, password: password)
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONEncoder().encode(credentials)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw URLError(.badServerResponse)
        }
        
        if httpResponse.statusCode == 200 {
            let authResponse = try JSONDecoder().decode(AuthResponse.self, from: data)
            self.authToken = authResponse.token
            DispatchQueue.main.async {
                self.isAuthenticated = true
            }
        } else {
            let error = try JSONDecoder().decode(APIError.self, from: data)
            throw NSError(domain: "", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: error.message])
        }
    }
    
    func fetchSystems() async throws -> [System] {
        guard let url = URL(string: "\(baseURL)systems") else {
            throw URLError(.badURL)
        }
        
        var request = URLRequest(url: url)
        request.setValue("Bearer \(authToken)", forHTTPHeaderField: "Authorization")
        
        let (data, _) = try await URLSession.shared.data(for: request)
        let apiSystems = try JSONDecoder().decode([APISystem].self, from: data)
        return apiSystems.map { $0.toSystem() }
    }
    
    func fetchServices() async throws -> [Service] {
        guard let url = URL(string: "\(baseURL)services") else {
            throw URLError(.badURL)
        }
        
        var request = URLRequest(url: url)
        request.setValue("Bearer \(authToken)", forHTTPHeaderField: "Authorization")
        
        let (data, _) = try await URLSession.shared.data(for: request)
        let apiServices = try JSONDecoder().decode([APIService].self, from: data)
        return apiServices.map { $0.toService() }
    }
} 