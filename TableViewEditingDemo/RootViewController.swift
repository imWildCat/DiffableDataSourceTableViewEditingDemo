//

import UIKit

private class CustomDataSource: UITableViewDiffableDataSource<Int, String> {
  var moveRow: ((Int, Int) -> Void)?

  override func tableView(_: UITableView, canEditRowAt _: IndexPath) -> Bool {
    true // Note: if we set this to `true`, the 'Delete' button will show.
    // It shouldn't be `true` to make reordering working.
    // If we don't use UITableViewDiffableDataSource, we can return false
  }

  override func tableView(_: UITableView, canMoveRowAt _: IndexPath) -> Bool {
    true
  }

  override func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
    super.tableView(tableView, moveRowAt: sourceIndexPath, to: destinationIndexPath)

    moveRow?(sourceIndexPath.row, destinationIndexPath.row)
  }
}

class RootViewController: UITableViewController {
  var dataRows = [
    "Foo",
    "Bar",
    "Baz",
  ] {
    didSet {
      loadData()
    }
  }

  private lazy var dataSource = CustomDataSource(tableView: tableView) { (tableView, indexPath, rowData) -> UITableViewCell? in
    let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
    cell.textLabel?.text = rowData

    cell.shouldIndentWhileEditing = false // Code to disable left indent does not work at all

    return cell
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view.
    
    title = "UITableViewDiffableDataSource"

    tableView.isEditing = true
    isEditing = true

    tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")

    tableView.dataSource = dataSource
    dataSource.moveRow = moveRow(fromIndex:toIndex:)
    loadData()

    navigationItem.rightBarButtonItem = UIBarButtonItem(title: "print", style: .plain, target: self, action: #selector(printDebug))
  }

  func loadData() {
    var snapshot = NSDiffableDataSourceSnapshot<Int, String>()

    snapshot.appendSections([0])

    snapshot.appendItems(dataRows)

    dataSource.apply(snapshot)
  }

  func moveRow(fromIndex: Int, toIndex: Int) {
    var copiedData = dataRows

    let temp = copiedData[fromIndex]
    copiedData.remove(at: fromIndex)
    copiedData.insert(temp, at: toIndex)

    dataRows = copiedData
  }

  @objc private func printDebug() {
    print("wip:", "tableView.isEditing =", tableView.isEditing)

    let cell = tableView.cellForRow(at: IndexPath(row: 0, section: 0))

    print("wip:", "cell:", cell?.isEditing)
  }

  override func tableView(_: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
    moveRow(fromIndex: sourceIndexPath.row, toIndex: destinationIndexPath.row)
  }

//  override func numberOfSections(in _: UITableView) -> Int {
//    1
//  }
//
//  override func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
//    dataRows.count
//  }
//
//  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//    let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
//    cell.textLabel?.text = dataRows[indexPath.row]
//    return cell
//  }
  
  // MARK - UITableViewDataSource

  override func tableView(_: UITableView,
                          editingStyleForRowAt _: IndexPath) -> UITableViewCell.EditingStyle
  {
    .none // Disable the delete button BUT there's unexpected left indent
  }
}
