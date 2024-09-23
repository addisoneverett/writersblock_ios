import Foundation
import UIKit
import DeviceActivity
import FamilyControls
import ManagedSettings

class ScreenTimeAPI {
    static let shared = ScreenTimeAPI()
    private let center = AuthorizationCenter.shared
    private let store = ManagedSettingsStore()
    
    func requestAuthorization(completion: @escaping (Bool) -> Void) {
        Task {
            do {
                try await center.requestAuthorization(for: .individual)
                DispatchQueue.main.async {
                    completion(true)
                }
            } catch {
                print("Failed to request authorization: \(error)")
                DispatchQueue.main.async {
                    completion(false)
                }
            }
        }
    }
    
    func fetchInstalledApps(completion: @escaping (Result<[AppInfo], Error>) -> Void) {
        Task {
            do {
                try await center.requestAuthorization(for: .individual)
                let selection = FamilyActivitySelection()
                let appTokens = selection.applicationTokens
                let appInfos = appTokens.map { token in
                    AppInfo(name: token.hashValue.description,
                            bundleIdentifier: token.hashValue.description,
                            icon: UIImage(systemName: "app") ?? UIImage()) // Use a placeholder icon
                }
                DispatchQueue.main.async {
                    completion(.success(appInfos))
                }
            } catch {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
        }
    }
    
    func blockApps(_ applicationTokens: Set<ApplicationToken>, until date: Date) {
        let schedule = DeviceActivitySchedule(intervalStart: DateComponents(hour: 0, minute: 0),
                                              intervalEnd: DateComponents(hour: 23, minute: 59),
                                              repeats: true)
        
        let activityName = DeviceActivityName("DailyRestriction")
        let center = DeviceActivityCenter()
        
        do {
            try center.startMonitoring(activityName, during: schedule)
        } catch {
            print("Failed to start monitoring: \(error)")
        }
        
        store.shield.applications = applicationTokens
        store.dateAndTime.requireAutomaticDateAndTime = true
    }
}

struct AppInfo: Identifiable {
    let id = UUID()
    let name: String
    let bundleIdentifier: String
    let icon: UIImage
}