//
//  MessageComposer.swift
//  Carpool
//
//  Created by Zaller on 11/15/17.
//  Copyright © 2017 Codebase. All rights reserved.
//

import UIKit
import MessageUI
import CarpoolKit

let textMessageRecipients = ["912-224-7376", "912-233-7764"] // for pre-populating the recipients list

class MessageComposer: NSObject, MFMessageComposeViewControllerDelegate {
    
    // A wrapper function to indicate whether or not a text message can be sent from the user's device
    func canSendText() -> Bool {
        return MFMessageComposeViewController.canSendText()
    }
    
    // Configures and returns a MFMessageComposeViewController instance
    func configuredMessageComposeViewController() -> MFMessageComposeViewController {
        let messageComposeVC = MFMessageComposeViewController()
        messageComposeVC.messageComposeDelegate = self  //  Make sure to set this property to self, so that the controller can be dismissed!
        messageComposeVC.recipients = textMessageRecipients
        messageComposeVC.body =  "SimplyCarpool is the app I wanted to share with you. It organizes your carpool schedule!"
        return messageComposeVC
    }
    
    // MFMessageComposeViewControllerDelegate callback - dismisses the view controller when the user is finished with it
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        controller.dismiss(animated: true, completion: nil)
    }
}
