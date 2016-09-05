//
//  ViewController.swift
//  test
//
//  Created by Zane Campbell on 2016-09-04.
//  Copyright © 2016 Zane Campbell. All rights reserved.
//

import UIKit

class ViewController: UIViewController, OEEventsObserverDelegate {

	var audio: AVAudioPlayer!
	var openEarsEventsObserver: OEEventsObserver!
	var lmPath: String?
	var dicPath: String?
	
	@IBAction func playAudio(sender: AnyObject) {
		audio.play()
	}
	
	@IBAction func start(sender: AnyObject) {
		start()
	}
	
	@IBAction func suspend(sender: AnyObject) {
		suspend()
	}
	
	@IBAction func stop(sender: AnyObject) {
		stop()
	}
	
	@IBAction func resume(sender: AnyObject) {
		resume()
	}
	
	@IBAction func fixSound(sender: AnyObject) {
		onlyThingThatWorksButCausesADelayAndOtherIssues()
	}
	
	@IBAction func fixOpenEars(sender: AnyObject) {
		thenYouHaveToCallThisMethodToFixOpenEarsAfter()
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		self.openEarsEventsObserver = OEEventsObserver()
		self.openEarsEventsObserver.delegate = self
		
		loadAudio()
		loadOpenEars()
	}
	
	func loadAudio() {
		let url = NSBundle.mainBundle().URLForResource("TestAudio", withExtension: "mp3")!
		do {
			audio = try AVAudioPlayer(contentsOfURL: url)
			audio.prepareToPlay()
		} catch let error as NSError {
			print(error.description)
		}
	}
	
	func loadOpenEars() {
		let lmGenerator = OELanguageModelGenerator()
		let words = ["WORD", "STATEMENT", "OTHER WORD", "A PHRASE"]
		let name = "LanguageModelGeneratorLookupList"
		let err = lmGenerator.generateLanguageModelFromArray(words, withFilesNamed: name, forAcousticModelAtPath: OEAcousticModel.pathToModel("AcousticModelEnglish"))
		
		if err == nil {
			lmPath = lmGenerator.pathToSuccessfullyGeneratedLanguageModelWithRequestedName(name)
			dicPath = lmGenerator.pathToSuccessfullyGeneratedDictionaryWithRequestedName(name)
		}
		else {
			print("Error: \(err.localizedDescription)")
		}
	}
	
	func start() {
		do {
			try OEPocketsphinxController.sharedInstance().setActive(true)
		}
		catch _ {
		}
		// Tried VoiceChat mode but does not fix anything.
//		OEPocketsphinxController.sharedInstance().audioMode = "VoiceChat"
		
		// Tried turning off mixing but does not fix anything.
//		OEPocketsphinxController.sharedInstance().disableMixing = false
		
		// Tried turning off session resets while stopped but does not fix anything.
//		OEPocketsphinxController.sharedInstance().disableSessionResetsWhileStopped = true
		
		// Tried disableing preferred buffer size but does not fix anything.
//		OEPocketsphinxController.sharedInstance().disablePreferredBufferSize = true

		// Tried disableing preferred channel number but does not fix anythin.
//		OEPocketsphinxController.sharedInstance().disablePreferredChannelNumber = true
		
		// OMG THIS WORKS. IT IS FIXED.
		OEPocketsphinxController.sharedInstance().disablePreferredSampleRate = true
		
		OEPocketsphinxController.sharedInstance().startListeningWithLanguageModelAtPath(lmPath!, dictionaryAtPath: dicPath!, acousticModelAtPath: OEAcousticModel.pathToModel("AcousticModelEnglish"), languageModelIsJSGF: false)
	}
	
	func suspend() {
		if !OEPocketsphinxController.sharedInstance().isSuspended {
			OEPocketsphinxController.sharedInstance().suspendRecognition()
		}
	}
	
	func resume() {
		if OEPocketsphinxController.sharedInstance().isSuspended {
			OEPocketsphinxController.sharedInstance().resumeRecognition()
		}
	}
	
	func stop() {
		if OEPocketsphinxController.sharedInstance().isListening {
			OEPocketsphinxController.sharedInstance().stopListening()
		}
	}
	
	func onlyThingThatWorksButCausesADelayAndOtherIssues() {
		do {
			try AVAudioSession.sharedInstance().setCategory("AVAudioSessionCategorySoloAmbient")
		} catch {
			
		}
	}
	
	func thenYouHaveToCallThisMethodToFixOpenEarsAfter() {
		do {
			try AVAudioSession.sharedInstance().setCategory("AVAudioSessionCategoryPlayAndRecord")
		} catch {
			
		}
	}
	
	func pocketsphinxDidReceiveHypothesis(hypothesis: String, recognitionScore: String, utteranceID: String) {
		print("The received hypothesis is \(hypothesis) with a score of \(recognitionScore) and an ID of \(utteranceID)")
	}
	
	func pocketsphinxDidStartListening() {
		print("Pocketsphinx is now listening.")
	}
	
	func pocketsphinxDidDetectSpeech() {
		print("Pocketsphinx has detected speech.")
	}
	
	func pocketsphinxDidDetectFinishedSpeech() {
		print("Pocketsphinx has detected a period of silence, concluding an utterance.")
	}
	
	func pocketsphinxDidStopListening() {
		print("Pocketsphinx has stopped listening.")
	}
	
	func pocketsphinxDidSuspendRecognition() {
		print("Pocketsphinx has suspended recognition.")
	}
	
	func pocketsphinxDidResumeRecognition() {
		print("Pocketsphinx has resumed recognition.")
	}
	
	func pocketsphinxDidChangeLanguageModelToFile(newLanguageModelPathAsString: String, andDictionary newDictionaryPathAsString: String) {
		print("Pocketsphinx is now using the following language model: \n\(newLanguageModelPathAsString) and the following dictionary: \(newDictionaryPathAsString)")
	}
	
	func pocketSphinxContinuousSetupDidFailWithReason(reasonForFailure: String) {
		print("Listening setup wasn't successful and returned the failure reason: \(reasonForFailure)")
	}
	
	func pocketSphinxContinuousTeardownDidFailWithReason(reasonForFailure: String) {
		print("Listening teardown wasn't successful and returned the failure reason: \(reasonForFailure)")
	}
	
	func testRecognitionCompleted() {
		print("A test file that was submitted for recognition is now complete.")
	}
}