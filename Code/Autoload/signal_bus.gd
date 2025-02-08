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