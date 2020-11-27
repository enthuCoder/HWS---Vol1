//
//  MemoriesViewController.swift
//  HWS - Vol1
//
//  Created by Dilgir Siddiqui on 11/26/20.
//

import UIKit
import Photos
import Speech
import AVFoundation

class MemoriesViewController: UICollectionViewController {

    @IBOutlet weak var searchField: UISearchBar!
    
    var memories = [URL]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addTapped))
        
        // Do any additional setup after loading the view.
        checkPermissions()
        
        // Load Photos in the model
        loadMemories()
    }
    
    func checkPermissions() {
        // Check the status of all the three permissions
        let photosAuthStatus = PHPhotoLibrary.authorizationStatus() == .authorized
        let recordingAuthStatus = AVAudioSession.sharedInstance().recordPermission == .granted
        let transcribeAuthStatus = SFSpeechRecognizer.authorizationStatus() == .authorized
        
        if (photosAuthStatus && recordingAuthStatus && transcribeAuthStatus) == false {
            // Permissions are not complete. Show Welcome screen
            if let viewController = storyboard?.instantiateViewController(withIdentifier: "FirstRun") {
                navigationController?.present(viewController, animated: true, completion: nil)
            }
        }
    }
                
    @objc func addTapped(_ sender: UIBarButtonItem) {
        let vc = UIImagePickerController()
        vc.modalPresentationStyle = .formSheet
        vc.delegate = self
        navigationController?.present(vc, animated: true, completion: nil)
    }

}

extension MemoriesViewController: UIImagePickerControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        // Dismiss the UIImagePickerControler
        dismiss(animated: true, completion: nil)
        
        // Save the image and thumbnail on to disk
        if let image = info[.originalImage] as? UIImage {
            saveNewMemory(image: image)
            
            // Load the saved thumnail image into memories array
            loadMemories()
        }
        
    }
}

// Save the images on the disk and load images from the location where it is saved
extension MemoriesViewController {

    // Helper function to get Document's directory in the user domain
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths.first!
    }

    // Save new memories to the disk
    func saveNewMemory(image: UIImage) {
        // Create a unique name for the photo
        let memoryName = "memory-\(Date().timeIntervalSince1970)"
        let imageName = memoryName + ".jpg"
        let thumbnailName = memoryName + ".thumb"
        
        // Create URLs where JPEG can be written
        let imagePath = getDocumentsDirectory().appendingPathComponent(imageName)
        
        // Convert the UIImage into a JPEG object
        do {
            if let jpegData = image.jpegData(compressionQuality: 0.8) {
                try jpegData.write(to: imagePath, options: [.atomicWrite])
            }
            
            // Create the thumbnail image now
            if let thumbnail = resize(image: image, to: 200) {
                
                // Create URLs where JPEG can be written
                let thumbnailImagePath = getDocumentsDirectory().appendingPathComponent(thumbnailName)
                // Convert the UIImage into a JPEG object
                if let thumbnailJPEGData = thumbnail.jpegData(compressionQuality: 0.8) {
                    try thumbnailJPEGData.write(to: thumbnailImagePath, options: [.atomicWrite])
                }
            }
        } catch {
            fatalError("Failed to save the image to Disk")
        }
    }

    // Scaled down the Image picked from UIPickerController to be used as a Thumbnail image
    func resize(image: UIImage, to scaledDownWidth: CGFloat) -> UIImage? {
        let scaleDownFactor = scaledDownWidth / image.size.width
        
        let scaledDownHeight = image.size.height * scaleDownFactor
        
        // Create a new image context where we can draw the scaled down image
        UIGraphicsBeginImageContextWithOptions(CGSize(width: scaledDownWidth, height: scaledDownHeight), false, 0)
        
        // Draw the original image into the context
        image.draw(in: CGRect(x: 0, y: 0, width: scaledDownWidth, height: scaledDownHeight))
        
        // Take the new image out of the current graphics context
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        
        // End the current image context
        UIGraphicsEndImageContext()
        
        return newImage
    }
    
    // Load memories array with image's paths and reload section 1 of the CollectionView
    func loadMemories() {
        // Remove any existing memories to avoid duplication
        memories.removeAll()
        
        // Get hold of the files found in Document's directory
        guard  let files = try? FileManager.default.contentsOfDirectory(at: getDocumentsDirectory(), includingPropertiesForKeys: nil, options: []) else {
            fatalError("Couldn't read Document's directory due to no availability of permissions")
        }
        
        // Iterate over all the found files, file .thumb extension files and extract their root path URLs
        for file in files {
            let fileName = file.lastPathComponent
            if fileName.hasSuffix(".thumb") {
                // Get the root name of the photo
                let rootName = fileName.replacingOccurrences(of: ".thumb", with: "")
                let photoPath = getDocumentsDirectory().appendingPathComponent(rootName)
                memories.append(photoPath)
            }
        }
        
        // Reload the collection view
        // Section 0 will only have search bar, and all the photos will be available in section 1
        // Reloading section 0 will cause user's search to stop, so we will not be reloading section 0 at all
        collectionView.reloadSections(IndexSet(integer: 1))
    }
}

// Helper Functions
extension MemoriesViewController {
    func imageURL(for memory: URL) -> URL {
        return memory.appendingPathExtension("jpg")
    }
    
    func thumbnailURL(for memory: URL) -> URL {
        return memory.appendingPathExtension("thumb")
    }
    
    func audioURL(for memory: URL) -> URL {
        return memory.appendingPathExtension("m4a")
    }

    func transcriptionURL(for memory: URL) -> URL {
        return memory.appendingPathExtension("txt")
    }
}

extension MemoriesViewController: UINavigationControllerDelegate {
    
}

extension MemoriesViewController {
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 2
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if section == 0 {
            // This section will just have header and 0 items (will only show search bar)
            return 0
        } else {
            return memories.count
        }
    }
    
    // Load the collection view with images
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Memory", for: indexPath) as! MemoryCell
        
        let memory = memories[indexPath.row]
        let imagePath = thumbnailURL(for: memory).path
        let thumbnailImage = UIImage(contentsOfFile: imagePath)
        cell.imageView.image = thumbnailImage
        
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        return collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "Header", for: indexPath)
    }
}

extension MemoriesViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        if section == 1 {
            return CGSize.zero
        } else {
            // Section 0 will have height of 50, section 1 will have 0 height
            return CGSize(width: 0, height: 50)
        }
    }
}
