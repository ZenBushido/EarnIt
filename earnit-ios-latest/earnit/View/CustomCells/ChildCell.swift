//
//  ChildCell.swift
//  earnit
//
//  Created by Lovelini Rawat on 8/14/17.
//  Copyright © 2017 Mobile-Di. All rights reserved.
//

import Foundation
import UIKit

class ChildCell : UITableViewCell {
    
    @IBOutlet var childName: UILabel!
    @IBOutlet var lblPercentValue: UILabel!
    @IBOutlet var childImageView: UIImageView!
    @IBOutlet var btnDeleteChildRow: UIButton!
    @IBOutlet var btnCellRowBG: UIButton!
    @IBOutlet weak var viewProg: UIView!
}
