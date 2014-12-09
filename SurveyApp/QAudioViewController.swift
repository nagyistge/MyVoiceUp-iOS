//
//  QAudioViewController.swift
//  SurveyApp
//
//  Created by Christian Kellner on 08/12/2014.
//  Copyright (c) 2014 Christian Kellner. All rights reserved.
//

import UIKit
import AVFoundation

class QAudioViewController: QuestionViewController, AVAudioRecorderDelegate {
    
    @IBOutlet weak var recordButton: UIButton!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var recordTimeLabel: UILabel!
    @IBOutlet weak var volumeProgress: UIProgressView!
    
    var recorder: AVAudioRecorder!
    var player: AVAudioPlayer!
    
    var meterClock: NSTimer?
    
    @IBAction func recordTouchUp(sender: AnyObject) {
    
        let isRecording = recorder.recording
        if isRecording {
            recorder.stop()
            playButton.enabled = true
            recordButton.setTitle("Record", forState: .Normal)
            
            var error: NSError?
            self.player = AVAudioPlayer(contentsOfURL: recorder.url, error: &error)
            if let e = error {
                println(e.localizedDescription)
            }
        } else {
            recorder.record()
            recordButton.setTitle("Stop", forState: .Normal)
                        
            self.meterClock = NSTimer.scheduledTimerWithTimeInterval(0.1,
                target:self,
                selector:"audioMeterUpdate:",
                userInfo:nil,
                repeats:true)
        }
        
    }
    
    @IBAction func playTouchUo(sender: AnyObject) {
        player.prepareToPlay()
        player.play()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        recordButton.enabled = false
        playButton.enabled = false
        
        var recordSettings = [
            AVFormatIDKey: kAudioFormatAppleLossless,
            AVEncoderAudioQualityKey : AVAudioQuality.Max.rawValue,
            AVEncoderBitRateKey : 320000,
            AVNumberOfChannelsKey: 1,
            AVSampleRateKey : 44100.0
        ]
        
        var error: NSError?
        
        let session:AVAudioSession = AVAudioSession.sharedInstance()
        if !session.setCategory(AVAudioSessionCategoryPlayAndRecord, error:&error) {
            println("could not set session category")
            if let e = error {
                println(e.localizedDescription)
            }
        }
        if !session.setActive(true, error: &error) {
            println("could not make session active")
            if let e = error {
                println(e.localizedDescription)
            }
        }
        
        var soundFileURL = self.generateSoundFileURL()
        self.recorder = AVAudioRecorder(URL: soundFileURL, settings: recordSettings, error: &error)
        if let e = error {
            println(e.localizedDescription)
        } else {
            recorder.meteringEnabled = true
            recorder.prepareToRecord()
            recorder.delegate = self
            recordButton.enabled = true
        }
    }
    
    func audioMeterUpdate(theTimer: NSTimer) {
        
        recorder.updateMeters()
        
        var apc0 = recorder.averagePowerForChannel(0)
        var peak0 = recorder.peakPowerForChannel(0)
        
        let curRatio = 1.0 - apc0 / -160.0;
        volumeProgress.progress = curRatio
        println("Current readings: \(apc0), \(peak0), \(curRatio)")
        
        if (curRatio > 0.9) {
            volumeProgress.progressTintColor = UIColor.redColor()
        } else {
            volumeProgress.progressTintColor = UIColor.greenColor()
        }
    }
    
    func generateSoundFileURL() -> NSURL {
        var format = NSDateFormatter()
        format.dateFormat="yyyy-MM-dd-HH-mm-ss"
        var currentFileName = "recording-\(format.stringFromDate(NSDate())).m4a"
        
        var dirPaths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
        var docsDir = dirPaths[0] as String
        var soundFilePath = docsDir.stringByAppendingPathComponent(currentFileName)
        return NSURL.fileURLWithPath(soundFilePath)!
    }
    
    func audioRecorderDidFinishRecording(recorder: AVAudioRecorder!, successfully flag: Bool) {
        meterClock?.invalidate()
        volumeProgress.progress = 0.0
    }
    
}