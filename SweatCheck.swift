import Foundation
import CoreMotion
import Cocoa

class MacOSAccelerometerChecker {
    private let motionManager = CMMotionManager()
    private let queue = OperationQueue()

    init() {
        motionManager.accelerometerUpdateInterval = 0.1
    }

    func startMonitoring(completion: @escaping (Bool) -> Void) {
        guard motionManager.isAccelerometerAvailable else {
            print("Accelerometer is not available on this Mac or no external device is connected.")
            completion(false)
            return
        }

        motionManager.startAccelerometerUpdates(to: queue) { data, error in
            if let error = error {
                print("Error receiving accelerometer data: \(error.localizedDescription)")
                completion(false)
                return
            }

            if let acceleration = data?.acceleration {
                print("Acceleration Data - x: \(acceleration.x), y: \(acceleration.y), z: \(acceleration.z)")
                if acceleration.y <= -1.0 {
                    print("Y acceleration reached -1 or lower.")
                    completion(true)
                    self.motionManager.stopAccelerometerUpdates()
                }
            }
        }
    }
}

func main() {
    let checker = MacOSAccelerometerChecker()

    let semaphore = DispatchSemaphore(value: 0)
    checker.startMonitoring { didReachThreshold in
        print("Did reach y acceleration of -1: \(didReachThreshold)")
        semaphore.signal()
    }

    semaphore.wait()
}

main()
