extends Node


# Manager Loader
signal LoadManager(manager_name:String)
signal ManagerLoaded(manager_name:String)


# Scene Manager
signal LoadScene(scene_name:String, loading_screen:bool)
signal SceneLoadComplete(scene:Node)


# Data Manager
signal PrisonerHeadshotsLoaded()
signal LoadPrisonerHeadshots(prisoner_array:Array[PrisonerData])


# Level
signal LevelReady(level:Node)
signal SpawnPrisoners()
signal AllPrisonersSpawned()


# Menus
signal ToggleMenu(id:String, display:bool)
signal ToggleLoadingScreen(display:bool, message:String, progress:float)


# Input Manager
signal MouseEnterPrisoner(prisoner:Prisoner)
signal MouseExitPrisoner()
signal MouseEnteredInteractible(interactible:Interactible)
signal MouseExitedInteractible()
signal MouseRightPressed()


# Prisoner
signal PrisonerMoveTo(prisoner:Prisoner, target:Vector2)
signal PrisonerReachedTarget(prisoner:Prisoner)
signal SelectPrisoner(prisoner:Prisoner)
signal PrisonerInteract(interaction:String, interactible:Interactible)


# UI
signal PopupResult(id:String, result:bool)
signal DisplayPopup(type:PopupManager.Type, id:String, severity:PopupManager.Severity, title:String, text:String, timer:int)
signal DisplayContextPopup(interactible:Interactible)
signal ContextPopupToggled(id:String, displayed:bool)
signal ContextPopupResult(interactible:Interactible, key_selection:String)
signal ContextMenuBtnPressed(id:String)
signal CloseContextMenu()


# Interactibles
signal InteractibleStateUpdate(data:InteractibleData, state:Interactible.State)


# Armour
signal ArmourBroken(data:ArmourData)


# Map selection menu
signal RoomIconBtnPressed(room_data:RoomData)
signal SpaceshipMoveFinished(room_data:RoomData)
signal MapStuffPlacementComplete()
signal CancelRoomIconBtnPressed(room_data:RoomData)
signal ResetRoomIconBtnOnRow(row:int)
signal DisableRoomIconBtnSameRow(roomd_data:RoomData)


# Save Load Manager
signal SaveForHashId(hash_id:int)
signal SaveComplete(hash_id:int)
signal LoadFromHashId(hash_id:int)
signal LoadComplete(hash_id:int)
signal DisplaySaveIcon()
signal CreateNewSave(id:String)
signal Save()


# Main Menu
signal SelectHashIdForLoad(hash_id:int)
signal ToggleLoadPanel(display:bool)


# Select Prisoners Menu
signal ToggleActivePrisonersPanel()
signal BtnSelectPrisonerPressed(prisoner_data:PrisonerData)
signal ActivatePrisonerData(prisoner_data:PrisonerData)
signal ActivatePrisonerDataFromId(id:String)
signal UpdateActivePrisonersPanel(prisoners:Array[PrisonerData])


# Game Manager
signal SelectShipAndName(ship_name:String, ship_id:int)
signal AbandonCurrentRun()