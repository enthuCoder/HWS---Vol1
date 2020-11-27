//
//  HappyDaysWelcomeViewController.swift
//  HWS - Vol1
//
//  Created by Dilgir Siddiqui on 11/26/20.
//

import UIKit
import Photos
import Speech
import AVFoundation

class HappyDaysWelcomeViewController: UIViewController {

    
    @IBOutlet weak var helpLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    

    @IBAction func requestPermission(_ sender: UIButton) {
        requestPhotosPermissions()
    }
    
    func requestPhotosPermissions() {
        PHPhotoLibrary.requestAuthorization { [unowned self] authStatus in
            DispatchQueue.main.async {
                if authStatus == .authorized {
                    self.requestRecordPermission()
                } else {
                    self.helpLabel.text = "Photos permission was declined. Please enable it in Settings then tap Continue again."
                }
            }
        }
    }
    
    func requestRecordPermission() {
        AVAudioSession.sharedInstance().requestRecordPermission() { [unowned self] allowed in
            DispatchQueue.main.async {
                if allowed {
                    self.requestTranscribePermission()
                } else {
                    self.helpLabel.text = "Recording permission was declined. Please enable it in Settings then tap Continue again."
                }
            }
            
        }
    }
    
    func requestTranscribePermission() {
        SFSpeechRecognizer.requestAuthorization { [unowned self] authStatus in
            DispatchQueue.main.async {
                if authStatus == .authorized {
                    self.authorizationComplete()
                } else {
                    self.helpLabel.text = "Transcription permission was declined. Please enable it in Settings then tap Continue again."
                }
            }
        }
    }
    
    func authorizationComplete() {
        // All the permissions are granted. Dismiss the the Welcome screen
        dismiss(animated: true, completion: nil)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
