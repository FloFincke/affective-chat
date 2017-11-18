//
//  MBDataStore.swift
//  affective-chat
//
//  Created by Vincent Füseschi on 18.11.17.
//  Copyright © 2017 Florian Fincke. All rights reserved.
//

import Foundation
import Zip

private let sensorDataFileName = "sensor-data.json"
private let heartRatesKey = "heartRates"

class MBDataStore {

    private var documentsDirectory: URL!
    private var sensorDataFileUrl: URL! {
        return documentsDirectory.appendingPathComponent(sensorDataFileName)
    }

    // MARK: - Lifecycle

    init() {
        documentsDirectory = FileManager.default
            .urls(for: .documentDirectory, in: .userDomainMask)
            .first
    }

    // MARK: - Public Functions

    func saveHeartRates(_ newHeartRateData: [HeartRateData]) {
        var sensorData = getSensorData()
        let heartRateDataInFile = sensorData[heartRatesKey] as? [[String: Any]] ?? []
        let heartRateData = heartRateDataInFile + newHeartRateData.map { $0.json }
        sensorData[heartRatesKey] = heartRateData
        saveSensorData(sensorData)
    }

    func compressSensorData() {
        do {
            let _ = try Zip.quickZipFiles([sensorDataFileUrl], fileName: "sensor-data")
        } catch {
            print(error)
        }
    }

    // MARK: - Private Functions

    private func saveSensorData(_ sensorData: [String: Any]) {
        guard let jsonData = try? JSONSerialization.data(withJSONObject: sensorData, options: []),
            let jsonString = String(data: jsonData, encoding: .utf8)
            else {
                return
        }

        try? jsonString.write(to: sensorDataFileUrl, atomically: true, encoding: .utf8)
    }

    private func getSensorData() -> [String: Any] {
        guard let jsonString = try? String(contentsOf: sensorDataFileUrl, encoding: .utf8),
            let jsonData = jsonString.data(using: .utf8),
            let json = try? JSONSerialization.jsonObject(with: jsonData, options: []),
            let validJson = json as? [String: Any]
            else {
                return [:]
        }

        return validJson
    }
}
