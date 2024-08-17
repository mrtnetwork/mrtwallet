import Cocoa
import FlutterMacOS

@main
class AppDelegate: FlutterAppDelegate {

    override func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
        super.applicationDidFinishLaunching(aNotification)
    }

    override func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
        super.applicationWillTerminate(aNotification)
    }

    override func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
        return true
    }
}
