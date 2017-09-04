//
//  MV_NewMovver.swift
//  Pods
//
//  Created by Pablo Romeu on 4/9/17.
//
//

import UIKit

//: Playground - noun: a place where people can play

import UIKit


public protocol mv_rt{
	var mv_generic_view: mv_vc! { get set }
	var mv_generic_viewModel: mv_vm! { get set }
	var mv_generic_previousRouter: mv_rt? { get set }
}

public protocol mv_vm:class{
	init()
	var mv_generic_model: Any? { get set }
	var mv_generic_view: mv_vc! { get set }
	var mv_generic_router: mv_rt! { get set }
}

public protocol mv_vc{
	var mv_generic_viewModel: mv_vm! { get set }
}

public protocol mv_view: mv_vc{
	associatedtype VM
	func mv_viewModel()-> VM
}

public protocol mv_viewModel: mv_vm{
	associatedtype VC
	associatedtype RT
	associatedtype MODEL
	func mv_view()-> VC
	func mv_router()-> RT
	func mv_model()-> MODEL?
}

public protocol mv_router: mv_rt{
	associatedtype VC
	associatedtype RT
	associatedtype VM
	func mv_view() -> VC
	func mv_viewModel() -> VM
	func mv_previousRouter() -> RT?
}



public protocol mv_rt_imp: mv_rt{
	mutating func movver_VC_Bind<VC_INSTANTIABLE,VM_INSTANTIABLE>(model:Any?,  viewModel:inout VM_INSTANTIABLE, viewController:inout VC_INSTANTIABLE ,previousRouter:mv_rt?) where VC_INSTANTIABLE:mv_vc,VM_INSTANTIABLE:mv_vm
	mutating func movver_VC_Instantiate<VC_INSTANTIABLE,VM_INSTANTIABLE>(model:Any?, viewModel:inout VM_INSTANTIABLE, storyboard:UIStoryboard,identifier:String,previousRouter:mv_rt?) -> VC_INSTANTIABLE where VC_INSTANTIABLE:mv_vc,VM_INSTANTIABLE:mv_vm
}

public extension mv_rt_imp{
	mutating func movver_VC_Instantiate<VC_INSTANTIABLE,VM_INSTANTIABLE>(model:Any?, viewModel:inout VM_INSTANTIABLE, storyboard:UIStoryboard,identifier:String,previousRouter:mv_rt?) -> VC_INSTANTIABLE where VC_INSTANTIABLE:mv_vc,VM_INSTANTIABLE:mv_vm
	{
		// Instantiate View Controller
		var viewController = storyboard.instantiateViewController(withIdentifier: identifier) as! VC_INSTANTIABLE
		self.movver_VC_Bind(model: model, viewModel: &viewModel, viewController: &viewController, previousRouter: previousRouter)
		return viewController
	}
	mutating func movver_VC_Bind<VC_INSTANTIABLE,VM_INSTANTIABLE>(model:Any?, viewModel:inout VM_INSTANTIABLE, viewController:inout VC_INSTANTIABLE ,previousRouter:mv_rt?)  where VC_INSTANTIABLE:mv_vc,VM_INSTANTIABLE:mv_vm
	{
		// Save previous router
		
		self.mv_generic_previousRouter = previousRouter
		
		// Create VM and pass the model, the router and controller
		
		viewModel.mv_generic_model = model
		viewModel.mv_generic_view = viewController
		viewModel.mv_generic_router = self
		self.mv_generic_viewModel = viewModel
		viewController.mv_generic_viewModel = self.mv_generic_viewModel
		self.mv_generic_view = viewController
	}
}




// MARK: _Helper clases_

//--------------------------------------------------------
// MARK: Deep linking
//--------------------------------------------------------


/// This protocol implements two methods to route through the app to a specific screen
public protocol mv_DeepLinking_Protocol{
	
	/// Tells whether a specific router
	///
	/// - Parameter url: the url to route to
	/// - Returns: Whether the route is known
	func mv_canRouteTo(url: URL) -> Bool
	
	/// This method routes to the destination viewController
	///
	/// - Parameters:
	///   - url: the url to route to
	///   - animated: whether the route should be animated or not
	///   - model: if a model should be attached
	func mv_routeToDestination(url:URL, animated:Bool, model:Any?)
}


public extension mv_DeepLinking_Protocol{
	func movver_canRouteTo(url: URL) -> Bool{
		return false
	}
	func movver_routeToDestination(url:URL, animated:Bool, model:Any?){
		// No implementation
	}
}

/*

SAMPLE USAGE

class MyVC:UIViewController,mv_vc{
var mv_generic_viewModel: mv_vm!


}

class MyVM:mv_vm{
var mv_generic_model: Any?
var mv_generic_router: mv_rt!
var mv_generic_view: mv_vc!
}

class MyRT:mv_rt,mv_rt_imp{
var mv_generic_previousRouter: mv_rt?
var mv_generic_view: mv_vc!
var mv_generic_viewModel: mv_vm!
}


protocol MyGenericVC:class,mv_vc{
func reloadTableView()
}

protocol MyGenericVM:class,mv_vm{
func tableReloaded()
}


extension MyVC:mv_view{
func mv_viewModel() -> MyGenericVM {
return self.mv_generic_viewModel as! MyGenericVM
}
}

extension MyVM:mv_viewModel{
func mv_model() -> Any {
return self.mv_generic_model as Any
}
func mv_router() -> MyRT {
return self.mv_generic_router as! MyRT
}
func mv_view() -> MyVC {
return self.mv_generic_view as! MyVC
}
}


extension MyVC:MyGenericVC{
func reloadTableView() {
print("reload tv")
}
}

extension MyVM:MyGenericVM{
func tableReloaded() {
print("asked to realod")
}
}



var router = MyRT()
var vm = MyVM()
var vc = MyVC()
router.movver_VC_Bind(model: nil, viewModel: &vm, viewController: &vc, previousRouter: nil)
vc.mv_viewModel().tableReloaded()
*/