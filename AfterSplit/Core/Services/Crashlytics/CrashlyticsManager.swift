//
//  CrashlyticsManager.swift
//  AfterSplit
//
//  Crash reporting and error tracking
//

import Foundation
import FirebaseCrashlytics

class CrashlyticsManager {
    static let shared = CrashlyticsManager()
    
    private init() {}
    
    // MARK: - Logging
    
    func log(_ message: String) {
        guard AppConfig.enableCrashlytics else { return }
        Crashlytics.crashlytics().log(message)
    }
    
    func logError(_ error: Error, userInfo: [String: Any]? = nil) {
        guard AppConfig.enableCrashlytics else { return }
        
        let nsError = error as NSError
        let crashlyticsError = NSError(
            domain: nsError.domain,
            code: nsError.code,
            userInfo: nsError.userInfo.merging(userInfo ?? [:]) { _, new in new }
        )
        
        Crashlytics.crashlytics().record(error: crashlyticsError)
    }
    
    func logNonFatalError(_ error: Error, context: String) {
        guard AppConfig.enableCrashlytics else { return }
        
        log("Non-fatal error in context: \(context)")
        logError(error, userInfo: ["context": context])
    }
    
    // MARK: - User Identification
    
    func setUserID(_ userID: String) {
        guard AppConfig.enableCrashlytics else { return }
        Crashlytics.crashlytics().setUserID(userID)
    }
    
    func setCustomKey(_ key: String, value: String) {
        guard AppConfig.enableCrashlytics else { return }
        Crashlytics.crashlytics().setCustomValue(value, forKey: key)
    }
    
    func setCustomKey(_ key: String, value: Int) {
        guard AppConfig.enableCrashlytics else { return }
        Crashlytics.crashlytics().setCustomValue(value, forKey: key)
    }
    
    func setCustomKey(_ key: String, value: Bool) {
        guard AppConfig.enableCrashlytics else { return }
        Crashlytics.crashlytics().setCustomValue(value, forKey: key)
    }
    
    // MARK: - Context Setting
    
    func setSubscriptionStatus(_ isActive: Bool) {
        setCustomKey("subscription_active", value: isActive)
    }
    
    func setCameraSessionState(_ isActive: Bool) {
        setCustomKey("camera_session_active", value: isActive)
    }
    
    func setRecordingState(_ isRecording: Bool) {
        setCustomKey("recording_active", value: isRecording)
    }
}
