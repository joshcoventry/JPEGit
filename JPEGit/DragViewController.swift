//
//  DragViewController.swift
//  JPEGit
//
//  Created by Joshua Coventry on 07/05/2018.
//  Copyright © 2018 Joshua Coventry. All rights reserved.
//

import Cocoa

class DragViewController: NSView {

    public func shell(launchPath: String, arguments: [String]) -> String {
        
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

    
    let NSFilenamesPboardType = NSPasteboard.PasteboardType("NSFilenamesPboardType")
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        // Declare and register an array of accepted types
        registerForDraggedTypes([NSPasteboard.PasteboardType(kUTTypeFileURL as String),
                                 NSPasteboard.PasteboardType(kUTTypeItem as String)])
    }
    
    let fileTypes = ["jpg", "jpeg", "bmp", "png", "gif", "tif", "tiff", "psd"]
    var fileTypeIsOk = false
    var droppedFilePath: String?
    var droppedFileName: String?
    var imagePath: String?
    var path: String?
    
    override func draggingEntered(_ sender: NSDraggingInfo) -> NSDragOperation {
        if checkExtension(drag: sender) {
            fileTypeIsOk = true
            
//            let context = NSGraphicsContext.current!.cgContext
//            context.saveGState()
//            context.setFillColor(NSColor.red.cgColor)
//            context.fillEllipse(in: dirtyRect)
//            context.restoreGState()
            
            return .copy
        } else {
            fileTypeIsOk = false
            print("Wrong file format")
            return []
        }
    }
    
    override func draggingUpdated(_ sender: NSDraggingInfo) -> NSDragOperation {
        if fileTypeIsOk {
            return .copy
        } else {
            print("Wrong file format")
            return []
        }
    }
    
    override func performDragOperation(_ sender: NSDraggingInfo) -> Bool {
        if let board = sender.draggingPasteboard().propertyList(forType: NSFilenamesPboardType) as? NSArray,
            let imagePath = board[0] as? String {
            // THIS IS WERE YOU GET THE PATH FOR THE DROPPED FILE
            droppedFilePath = imagePath
            
            let droppedFileNameNoExt = NSURL(fileURLWithPath: droppedFilePath!).deletingPathExtension?.lastPathComponent
            let destinationPath = NSURL(fileURLWithPath: droppedFilePath!).deletingLastPathComponent
            let outputFile = (destinationPath?.absoluteString.replacingOccurrences(of: "file://", with: ""))! + (droppedFileNameNoExt)! + ".jpg"
            shell(launchPath:"/usr/bin/sips", arguments:["-s","format","jpeg",droppedFilePath!,"--out",outputFile])
            
            return true
        }
        return false
    }
    
    func checkExtension(drag: NSDraggingInfo) -> Bool {
        if let board = drag.draggingPasteboard().propertyList(forType: NSFilenamesPboardType) as? NSArray,
            let path = board[0] as? String {
            let url = NSURL(fileURLWithPath: path)
            if let fileExtension = url.pathExtension?.lowercased() {
                return fileTypes.contains(fileExtension)
            }
        }
        return false
    }
    
}
