import UIKit

final class MainTabBarController: UITabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTabBar()
    }
    
    private func setupTabBar() {
        let randomVC = UINavigationController(rootViewController: RandomJokeViewController())
        randomVC.tabBarItem = UITabBarItem(
            title: "Random",
            image: UIImage(systemName: "sparkles"),
            selectedImage: UIImage(systemName: "sparkles"))
        
        let listVC = UINavigationController(rootViewController: JokesListTableViewController())
            listVC.tabBarItem = UITabBarItem(
            title: "List",
            image: UIImage(systemName: "list.bullet"),
            selectedImage: UIImage(systemName: "list.bullet"))
        
        let categoriesVC = UINavigationController(rootViewController: CategoriesListTableViewController())
        categoriesVC.tabBarItem = UITabBarItem(
            title: "Categories",
            image: UIImage(systemName: "folder"),
            selectedImage: UIImage(systemName: "folder.fill"))
        
        viewControllers = [randomVC, listVC, categoriesVC]
    }
}
