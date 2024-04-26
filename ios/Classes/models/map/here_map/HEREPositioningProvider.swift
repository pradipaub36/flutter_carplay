/*
 * Copyright (C) 2019-2024 HERE Europe B.V.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 *
 * SPDX-License-Identifier: Apache-2.0
 * License-Filename: LICENSE
 */

import CoreLocation
import heresdk

// A reference implementation using HERE Positioning to get notified on location updates
// from various location sources available from a device and HERE services.
class HEREPositioningProvider: NSObject,
    // Needed to check device capabilities.
    CLLocationManagerDelegate,
    // Optionally needed to listen for status changes.
    LocationStatusDelegate,
    // Conforms to the LocationDelegate protocol.
    LocationDelegate
{
    // We need to check if the device is authorized to use location capabilities like GPS sensors.
    // Results are handled in the CLLocationManagerDelegate below.
    private let locationManager = CLLocationManager()
    private let locationEngine: LocationEngine
    private var locationUpdateDelegate: LocationDelegate?
    private var accuracy = LocationAccuracy.bestAvailable
    private var isLocating = false
    private var locationEngineStatus: LocationEngineStatus?
    private var lastKnownLocation: Location?
    var isLocationEngineStarted: Bool {
        return locationEngineStatus == .engineStarted || locationEngineStatus == .alreadyStarted
    }

    override init() {
        do {
            try locationEngine = LocationEngine()
        } catch let engineInstantiationError {
            fatalError("Failed to initialize LocationEngine. Cause: \(engineInstantiationError)")
        }

        super.init()
        authorizeNativeLocationServices()
    }

    /// Returns the last known location.
    /// - Returns: The last known location.
    func getLastKnownLocation() -> Location? {
        return locationEngine.lastKnownLocation
    }

    /// Authorizes native location services.
    private func authorizeNativeLocationServices() {
        locationManager.delegate = self
        locationManager.requestAlwaysAuthorization()
    }

    // Conforms to the CLLocationManagerDelegate protocol.
    // Handles the result of the native authorization request.
    func locationManager(_: CLLocationManager,
                         didChangeAuthorization status: CLAuthorizationStatus)
    {
        switch status {
        case .restricted, .denied, .notDetermined:
            print("Native location services denied or disabled by user in device settings.")
        case .authorizedWhenInUse, .authorizedAlways:
            if let locationUpdateDelegate = locationUpdateDelegate, isLocating {
                startLocating(locationDelegate: locationUpdateDelegate, accuracy: accuracy)
            }
            print("Native location services authorized by user.")
        default:
            fatalError("Unknown location authorization status.")
        }
    }

    /// Starts the location engine.
    /// Does nothing when engine is already running.
    /// - Parameters:
    ///   - locationDelegate: The location delegate to receive location updates.
    ///   - accuracy: The accuracy of the location updates.
    func startLocating(locationDelegate: LocationDelegate, accuracy: LocationAccuracy) {
        if isLocationEngineStarted {
            return
        }
        print("Start locating with accuracy: \(accuracy)")
        isLocating = true
        locationUpdateDelegate = locationDelegate
        self.accuracy = accuracy

        // Set delegates to get location updates.
        locationEngine.addLocationDelegate(locationDelegate: locationUpdateDelegate!)
        locationEngine.addLocationDelegate(locationDelegate: self)
        locationEngine.addLocationStatusDelegate(locationStatusDelegate: self)

        // Without native permissions granted by user, the LocationEngine cannot be started.
        let status = locationEngine.start(locationAccuracy: .bestAvailable)
        print("Location engine status:==> \(status)")
        if status == .missingPermissions {
            authorizeNativeLocationServices()
        }
    }

    /// Does nothing when engine is already stopped.
    func stopLocating() {
        if !isLocationEngineStarted {
            return
        }
        print("Stop locating.")
        // Remove delegates and stop location engine.
        locationEngine.removeLocationDelegate(locationDelegate: locationUpdateDelegate!)
        locationEngine.removeLocationDelegate(locationDelegate: self)
        locationEngine.removeLocationStatusDelegate(locationStatusDelegate: self)
        locationEngine.stop()
        isLocating = false
    }

    /// Conforms to the LocationStatusDelegate protocol.
    /// - Parameter locationEngineStatus: The current status of the location engine.
    func onStatusChanged(locationEngineStatus: LocationEngineStatus) {
        print("Location engine status changed: \(locationEngineStatus)")
        self.locationEngineStatus = locationEngineStatus
    }

    /// Conforms to the LocationStatusDelegate protocol.
    /// - Parameter features: The location features that are not available.
    func onFeaturesNotAvailable(features: [LocationFeature]) {
        for feature in features {
            print("Location feature not available: '%s'", String(describing: feature))
        }
    }

    /// Conforms to the LocationDelegate protocol.
    /// - Parameter location: The new location.
    func onLocationUpdated(_ location: heresdk.Location) {
        print("Location updated: \(location.coordinates)")

        let lastCoordinates = lastKnownLocation?.coordinates
        let currentCoordinates = location.coordinates

        let lastLatitude = lastCoordinates?.latitude ?? 0.0
        let currentLatitude = currentCoordinates.latitude
        let lastLongitude = lastCoordinates?.longitude ?? 0.0
        let currentLongitude = currentCoordinates.longitude

        let latitudeDifference = abs(lastLatitude - currentLatitude)
        let longitudeDifference = abs(lastLongitude - currentLongitude)

        // Skip update if the location didn't change significantly.
        if latitudeDifference < 0.0001 && longitudeDifference < 0.0001 { return }

        lastKnownLocation = location

        locationUpdatedHandler?(location)
    }
}
