//
//  on .swift
//  pingon
//
//  Created by Roland Wenzlofsky on 28.10.24.
//
import Foundation
import SwiftUI
struct ContentView: View {
    @State private var serverAddress: String = "1.1.1.1"
    @StateObject private var pingManager = PingManager()

    var body: some View {
        VStack(spacing: 20) {
            TextField("Enter server address", text: $serverAddress)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            
            Button(action: {
                if pingManager.isPinging {
                    pingManager.stopPing()
                } else {
                    pingManager.startPing(host: serverAddress)
                }
            }) {
                Text(pingManager.isPinging ? "Stop" : "Start")
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(pingManager.isPinging ? Color.red : Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            
            // Display the currently pinged host
            Text("Pinging: \(pingManager.currentHost.isEmpty ? "None" : pingManager.currentHost)")
                .font(.subheadline)
                .foregroundColor(.gray)
                .padding()

            Text(pingManager.pingResult)
                .font(.headline)
                .padding()

            Spacer()
        }
        .padding()
    }
}
