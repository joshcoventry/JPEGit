//
//  DragView.swift
//  JPEGit
//
//  Created by Joshua Coventry on 07/05/2018.
//  Copyright © 2018 Joshua Coventry. All rights reserved.
//

import Cocoa

class DragView: NSViewController, NSWindowDelegate{
    
    lazy var window: NSWindow! = self.view.window

    func shell(launchPath: String, arguments: [String]) -> String {
        
        let process = Process()
        process.launchPath = launchPath
        process.arguments = arguments
        
        let pipe = Pipe()
        process.standardOutput = pipe
        process.launch()
        
        let output_from_command = String(data: pipe.fileHandleForReading.readDataToEndOfFile(), encoding: String.Encoding.utf8)!
        
        // remove the trailing new-line char
        if output_from_command.count > 0 {
            let lastIndex = output_from_command.index(before: output_from_command.endIndex)
            return String(output_from_command[output_from_command.startIndex ..< lastIndex])
        }
        return output_from_command
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
    }
    
    override func viewWillAppear() {
        super.viewWillAppear()
        window.isMovableByWindowBackground = true
        window!.standardWindowButton(.miniaturizeButton)!.isHidden = true
        window!.standardWindowButton(.zoomButton)!.isHidden = true
    }
    
    override var representedObject: Any? {
        didSet {
            // Update the view, if already loaded.
        }
    }
    
    @IBOutlet weak var dragView: NSView!
    
    @IBAction func browseFiles(_ sender: NSButton) {
        guard let window = view.window else { return }
        
        // Create an empty array and add three elements to it.
        var allowedFiles = [String]()
        allowedFiles.append("jpg")
        allowedFiles.append("gif")
        allowedFiles.append("png")
        allowedFiles.append("bmp")
        allowedFiles.append("psd")
        allowedFiles.append("tiff")
        allowedFiles.append("tif")
        allowedFiles.append("jpeg")
        allowedFiles.append("tga")
        allowedFiles.append("sgi")

        let panel = NSOpenPanel()
        panel.canChooseFiles = true
        panel.allowedFileTypes = allowedFiles
        panel.canChooseDirectories = false
        panel.allowsMultipleSelection = false
        panel.prompt = "Choose"
        
        panel.beginSheetModal(for: window) { (result) in
            if result.rawValue == NSApplication.ModalResponse.OK.rawValue {
                //let selectedFolder = panel.urls[0]
                
                let originalPath = panel.urls[0]
                var droppedFilePath = originalPath.absoluteString
                droppedFilePath = droppedFilePath.replacingOccurrences(of: "file://", with: "")
                
                print(droppedFilePath)
                
                //let droppedFileName = NSURL(fileURLWithPath: droppedFilePath!).lastPathComponent
                let droppedFileNameNoExt = NSURL(fileURLWithPath: droppedFilePath).deletingPathExtension?.lastPathComponent
                let destinationPath = NSURL(fileURLWithPath: droppedFilePath).deletingLastPathComponent
                let outputFile = (destinationPath?.absoluteString.replacingOccurrences(of: "file://", with: ""))! + (droppedFileNameNoExt)! + ".jpg"
                //print(outputFile)
                self.shell(launchPath:"/usr/bin/sips", arguments:["-s","format","jpeg",droppedFilePath,"--out",outputFile])

            }
        }
    }
    
    
}
