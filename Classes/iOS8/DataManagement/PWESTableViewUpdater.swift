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
    @objc optional func didChangeResultsForCell(_ cell: UITableViewCell, indexPath: IndexPath)
    @objc optional func didChangeFetchResultsControllerForSection(_ section: UInt64)
}
