//
//  QAudioViewController.swift
//  SurveyApp
//
//  Created by Christian Kellner on 08/12/2014.
//  Copyright (c) 2014 Christian Kellner. All rights reserved.
//

import UIKit
import AVFoundation

class QAudioViewController: QuestionViewController, AVAudioRecorderDelegate, AVAudioPlayerDelegate {
    
    @IBOutlet weak var recordButton: UIButton!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var recordTimeLabel: UILabel!
    @IBOutlet weak var volumeProgress: UIProgressView!
    @IBOutlet weak var rewindButton: UIButton!
    
    var recorder: AVAudioRecorder!
    var player: AVAudioPlayer!
    
    var meterClock: NSTimer?
    var timeClock: NSTimer?
    
    @IBAction func recordTouchUp(sender: AnyObject) {
    
        let isRecording = recorder.recording
        if isRecording {
            recorder.stop()
        } else {
            recorder.record()
            playButton.enabled = false
            rewindButton.enabled = false
            //recordButton.setTitle("Stop", forState: .Normal)
            recordButton.setTitleColor(UIColor.redColor(), forState: .Normal)
            
            self.meterClock = NSTimer.scheduledTimerWithTimeInterval(0.1,
                target:self,
                selector:"audioMeterUpdate:",
                userInfo:nil,
                repeats:true)
            
            self.timeClock = NSTimer.scheduledTimerWithTimeInterval(0.1,
                target:self,
                selector:"recordTimeUpdate:",
                userInfo:nil,
                repeats:true)
        }
    }
    
    @IBAction func playTouchUp(sender: AnyObject) {

        if player.playing {
            player.pause()
            playButton.setTitle("", forState: .Normal)
            timeClock?.invalidate()
            
        } else {
            
            player.prepareToPlay()
            player.volume = 1.0
            player.play()
            playButton.setTitle("", forState: .Normal)
            
            self.timeClock = NSTimer.scheduledTimerWithTimeInterval(0.1,
                target:self,
                selector:"playTimeUpdate:",
                userInfo:nil,
                repeats:true)
        }
    }
   
    
    @IBAction func rewindTouchUp(sender: AnyObject) {
        player.currentTime = 0.0
        displayPlaybackTime(player.duration)
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        recordButton.enabled = false
        playButton.enabled = false
        rewindButton.enabled = false
        
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
        
        let mediaUUID = NSUUID().UUIDString
        var soundFileURL = DataStore.sharedInstance.generateMediaURL(mediaUUID, suffix: "m4a")
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
    
    override func viewWillDisappear(animated: Bool) {
        if player != nil && player.playing {
            player.stop()
        }
        if recorder != nil && recorder.record() {
            recorder.stop()
        }

        //fixme: we should properly handle getting out of sight
        // and coming back in
        playButton.enabled = false
        rewindButton.enabled = false
        recordButton.enabled = false
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
        timeClock?.invalidate()
        volumeProgress.progress = 0.0
        recordButton.setTitleColor(UIColor.blackColor(), forState: .Normal)
        
        if flag {
            
            var error: NSError?
            self.player = AVAudioPlayer(contentsOfURL: recorder.url, error: &error)
            if let e = error {
                println(e.localizedDescription)
            } else {
                playButton.enabled = true
                rewindButton.enabled = true
                displayPlaybackTime(player.duration)
            }
        }
    }
    
    func audioPlayerDidFinishPlaying(player: AVAudioPlayer!, successfully flag: Bool) {
        //play icon: 
        playButton.setTitle("", forState: .Normal)
        timeClock?.invalidate()
    }
    
    func recordTimeUpdate(theTimer: NSTimer) {
        displayPlaybackTime(recorder.currentTime)
    }
    
    func playTimeUpdate(theTimer: NSTimer) {
        displayPlaybackTime(player.currentTime)
    }
    
    func displayPlaybackTime(theTime: NSTimeInterval) {
        let minutes = Int(floor(theTime / 60.0))
        let seconds = Int(remainder(theTime, 60.0))
        recordTimeLabel.text  = String(format: "%d:%02d", minutes, seconds)
    }
    
    
}