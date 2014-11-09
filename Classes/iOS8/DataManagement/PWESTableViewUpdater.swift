//
//  PWESTableViewUpdater.swift
//  iStayHealthy
//
//  Created by Peter_Schmidt on 09/11/2014.
//
//

import UIKit

@objc
protocol PWESTableViewUpdater {
    optional func didChangeResultsForCell(cell: UITableViewCell, indexPath: NSIndexPath)
    optional func didChangeFetchResultsControllerForSection(section: UInt64)
}
