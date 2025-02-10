extends Node


# Manager Loader
signal LoadManager(manager_name:String)
signal ManagerLoaded(manager_name:String)


# Scene Manager
signal LoadScene(scene_name:String)
signal SceneLoadComplete(scene:Node)


# Level
signal LevelReady(level:Node)
signal SpawnPrisoners()
signal AllPrisonersSpawned()


# Menus
signal ToggleMenu(id:String, display:bool)
signal ToggleLoadingScreen(display:bool)


# Input Manager
signal MouseEnterPrisoner(prisoner:Prisoner)
signal MouseExitPrisoner()
signal PrisonerMoveTo(prisoner:Prisoner, target:TextureRect)
signal SelectPrisoner(prisoner:Prisoner)


# UI
signal PopupResult(id:String, result:bool)
signal DisplayPopup(type:PopupManager.Type, id:String, severity:PopupManager.Severity, title:String, text:String, timer:int)
signal DisplayContextPopup(id:String, options:Dictionary, pos:Vector2)
signal ContextPopupToggled(id:String, displayed:bool)
signal ContextPopupResult(key_selection:String)
signal ContextMenuBtnPressed(id:String)
signal CloseContextMenu()