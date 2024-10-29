import Combine
import Foundation

// Define a struct to hold both hostname and IP
struct TailscaleClient: Identifiable, Hashable {
    let id = UUID()
    let hostname: String
    let ipAddress: String
}


class TailscaleManager: ObservableObject {
    @Published var clients: [TailscaleClient] = []  // Now stores TailscaleClient objects
    
    private var cancellables = Set<AnyCancellable>()
    private let apiKey = "tskey-api-k4n8eUxW8b11CNTRL-92baUaDmvTdoMK8pA3T8ddmLVR9xMPbM"
    
    func fetchClients() {
        guard let url = URL(string: "https://api.tailscale.com/api/v2/tailnet/lemur-saurolophus.ts.net/devices") else {
            print("Invalid URL")
            return
        }
        
        var request = URLRequest(url: url)
        request.setValue("Basic \(Data("\(apiKey):".utf8).base64EncodedString())", forHTTPHeaderField: "Authorization")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error: \(error.localizedDescription)")
                return
            }
            
            guard let data = data else {
                print("No data received")
                return
            }
            
            // Print the raw JSON response
            if let jsonString = String(data: data, encoding: .utf8) {
                print("Raw JSON response: \(jsonString)")
            }
            
            do {
                let decodedResponse = try JSONDecoder().decode(TailscaleDevicesResponse.self, from: data)
                
                DispatchQueue.main.async {
                    // Populate clients with TailscaleClient objects
                    self.clients = decodedResponse.devices.compactMap { device in
                        guard let hostname = device.hostname,
                              let ipAddress = device.addresses?.first else { return nil }
                        return TailscaleClient(hostname: hostname, ipAddress: ipAddress)
                    }
                }
            } catch {
                print("Decoding error: \(error)")
            }
        }.resume()
    }

}

// Define response structure
struct TailscaleDevicesResponse: Codable {
    let devices: [TailscaleDevice]
}

struct TailscaleDevice: Codable {
    let hostname: String?
    let addresses: [String]?
}
