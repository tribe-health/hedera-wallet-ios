//
//  Copyright 2019 Hedera Hashgraph LLC
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

import UIKit

protocol AddressTableViewCellDelegate : class {
    func addressTableViewCellDidTapActionButton(_ cell:AddressTableViewCell)
    func addressTableViewCellDidTapCopyButton(_ cell:AddressTableViewCell)
    func addressTableViewCellDidChange(_ cell:AddressTableViewCell, name:String, address:String, host:String)
}

class AddressTableViewCell: UITableViewCell, UITextFieldDelegate {

    @IBOutlet weak var captionLabel : UILabel!
    @IBOutlet weak var keyLabel : UITextField!
    @IBOutlet weak var nameLabel : UITextField!
    @IBOutlet weak var hostTextField : UITextField!

    @IBOutlet weak var copyButton : UIButton!
    var actionButton : UIButton!
    
    var allowEditing = false
    
    weak var delegate: AddressTableViewCellDelegate?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.clipsToBounds = true
        HGCStyle.regularCaptionLabel(self.captionLabel)
        self.copyButton.isHidden = true
        self.copyButton.addTarget(self, action: #selector(self.onCopyButtonTap), for: .touchUpInside)
        
        self.actionButton = UIButton.init()
        self.actionButton.addTarget(self, action: #selector(self.onActionButtonTap), for: .touchUpInside)
        self.actionButton.setTitle(NSLocalizedString("CHANGE", comment: ""), for: .normal)
        self.actionButton.setTitleColor(Color.selectedTintColor(), for: .normal)
        self.actionButton.titleLabel?.font = Font.regularFontMedium()
        self.actionButton.sizeToFit()
        self.actionButton.frame.size.width = self.actionButton.frame.size.width+10
        self.nameLabel.rightView = self.actionButton
        self.hostTextField.superview?.backgroundColor = Color.pageBackgroundColor()
        self.hostTextField.superview?.isHidden = true
        self.hostTextField.delegate = self
        self.nameLabel.placeholder = NSLocalizedString("Placeholder_Name_TextField", comment: "")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.backgroundColor = Color.pageBackgroundColor()
        self.contentView.backgroundColor = Color.pageBackgroundColor()
    }
    
    @objc func onActionButtonTap() {
        self.delegate?.addressTableViewCellDidTapActionButton(self)
    }
    
    @objc func onCopyButtonTap() {
        self.delegate?.addressTableViewCellDidTapCopyButton(self)
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        return self.allowEditing
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let newStr = textField.text?.replace(string: string, inRange: range)
        if self.nameLabel == textField {
            self.delegate?.addressTableViewCellDidChange(self, name: newStr!, address: self.keyLabel.text!, host: hostTextField.text!)
            
        } else if self.keyLabel == textField {
            self.delegate?.addressTableViewCellDidChange(self, name: self.nameLabel.text!, address: newStr!, host: hostTextField.text!)
            
        } else if self.hostTextField == textField {
            self.delegate?.addressTableViewCellDidChange(self, name: self.nameLabel.text!, address: self.keyLabel.text!, host: newStr!)
        }
        
        return true
    }
}
