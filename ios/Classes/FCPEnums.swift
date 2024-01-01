//
//  FCPEnums.swift
//  flutter_carplay
//
//  Created by Oğuzhan Atalay on 21.08.2021.
//

/// Enum defining different types of CarPlay connection states.
enum FCPConnectionTypes {
    /// Represents a connected state to CarPlay.
    static let connected = "CONNECTED"

    /// Represents a background state in CarPlay.
    static let background = "BACKGROUND"

    /// Represents a disconnected state from CarPlay.
    static let disconnected = "DISCONNECTED"
}

/// Enum defining different types of CarPlay channel events.
enum FCPChannelTypes {
    /// Event triggered when the CarPlay connection state changes.
    static let onCarplayConnectionChange = "onCarplayConnectionChange"

    /// Event for setting the root template in CarPlay.
    static let setRootTemplate = "setRootTemplate"

    /// Event to force an update to the root template in CarPlay.
    static let forceUpdateRootTemplate = "forceUpdateRootTemplate"

    /// Event to update a specific list item in CarPlay.
    static let updateListItem = "updateListItem"

    /// Event to update the content of a list template in CarPlay.
    static let updateListTemplate = "updateListTemplate"

    /// Event triggered when the search text is updated in CarPlay.
    static let onSearchTextUpdated = "onSearchTextUpdated"

    /// Event triggered when the search text update is complete in CarPlay.
    static let onSearchTextUpdatedComplete = "onSearchTextUpdatedComplete"

    /// Event triggered when a search result is selected in CarPlay.
    static let onSearchResultSelected = "onSearchResultSelected"

    /// Event triggered when a list item is selected in CarPlay.
    static let onListItemSelected = "onFCPListItemSelected"

    /// Event triggered when a list item selection is complete in CarPlay.
    static let onListItemSelectedComplete = "onFCPListItemSelectedComplete"

    /// Event triggered when an alert action is pressed in CarPlay.
    static let onAlertActionPressed = "onFCPAlertActionPressed"

    /// Event for setting an alert template in CarPlay.
    static let setAlert = "setAlert"

    /// Event triggered when the presentation state changes in CarPlay.
    static let onPresentStateChanged = "onPresentStateChanged"

    /// Event for popping a template in CarPlay.
    static let popTemplate = "popTemplate"

    /// Event for pushing a template in CarPlay.
    static let pushTemplate = "pushTemplate"

    /// Event for closing the current presentation in CarPlay.
    static let closePresent = "closePresent"

    /// Event triggered when a grid button is pressed in CarPlay.
    static let onGridButtonPressed = "onGridButtonPressed"

    /// Event for setting an action sheet template in CarPlay.
    static let setActionSheet = "setActionSheet"

    /// Event triggered when a bar button is pressed in CarPlay.
    static let onBarButtonPressed = "onBarButtonPressed"

    /// Event triggered when a map button is pressed in CarPlay.
    static let onMapButtonPressed = "onMapButtonPressed"

    /// Event triggered when a navigation bar button is pressed in CarPlay.
    static let onNavigationBarButtonPressed = "onNavigationBarButtonPressed"

    /// Event triggered when a text button is pressed in CarPlay.
    static let onTextButtonPressed = "onTextButtonPressed"

    /// Event for popping to the root template in CarPlay.
    static let popToRootTemplate = "popToRootTemplate"

    /// Event for setting a voice control template in CarPlay.
    static let setVoiceControl = "setVoiceControl"

    /// Event for activating a specific voice control state in CarPlay.
    static let activateVoiceControlState = "activateVoiceControlState"

    /// Event for starting the voice control in CarPlay.
    static let startVoiceControl = "startVoiceControl"

    /// Event for stopping the voice control in CarPlay.
    static let stopVoiceControl = "stopVoiceControl"

    /// Event for getting the active voice control state identifier in CarPlay.
    static let getActiveVoiceControlStateIdentifier = "getActiveVoiceControlStateIdentifier"

    /// Event triggered when the voice control transcript changes in CarPlay.
    static let onVoiceControlTranscriptChanged = "onVoiceControlTranscriptChanged"

    /// Event for speaking text in CarPlay.
    static let speak = "speak"

    /// Event triggered when speech is completed in CarPlay.
    static let onSpeechCompleted = "onSpeechCompleted"

    /// Event for playing audio in CarPlay.
    static let playAudio = "playAudio"

    /// Event for getting CarPlay configuration information.
    static let getConfig = "getConfig"
}

/// Enum defining different types of alert actions in CarPlay.
enum FCPAlertActionTypes {
    /// Represents an action sheet type of alert action.
    case ACTION_SHEET

    /// Represents a default type of alert action.
    case ALERT
}

/// Enum defining different types of list template in CarPlay.
enum FCPListTemplateTypes {
    /// Represents a part of a grid template in CarPlay.
    case PART_OF_GRID_TEMPLATE

    /// Represents a default type of list template in CarPlay.
    case DEFAULT
}
