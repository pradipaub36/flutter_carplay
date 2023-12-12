import 'dart:convert';
import 'dart:developer';

import 'package:flutter/services.dart';

import '../constants/private_constants.dart';
import '../flutter_carplay.dart';
import '../helpers/carplay_helper.dart';

/// [FlutterCarPlayController] is an root object in order to control and communication
/// system with the Apple CarPlay and native functions.
class FlutterCarPlayController {
  static final FlutterCarplayHelper _carplayHelper = FlutterCarplayHelper();
  static final MethodChannel _methodChannel =
      MethodChannel(_carplayHelper.makeFCPChannelId());
  static final EventChannel _eventChannel =
      EventChannel(_carplayHelper.makeFCPChannelId(event: '/event'));

  /// [CPTabBarTemplate], [CPGridTemplate], [CPListTemplate], [CPIInformationTemplate], [CPPointOfInterestTemplate] in a List
  static List<dynamic> templateHistory = [];

  /// [CPTabBarTemplate], [CPGridTemplate], [CPListTemplate], [CPIInformationTemplate], [CPPointOfInterestTemplate]
  static dynamic currentRootTemplate;

  /// [CPAlertTemplate], [CPActionSheetTemplate], [CPVoiceControlTemplate]
  static dynamic currentPresentTemplate;

  /// Specific objects that are waiting to receive callback.
  static List<dynamic> callbackObjects = [];

  MethodChannel get methodChannel {
    return _methodChannel;
  }

  EventChannel get eventChannel {
    return _eventChannel;
  }

  Future<bool> reactToNativeModule(FCPChannelTypes type, dynamic data) async {
    final value = await _methodChannel.invokeMethod(
      CPEnumUtils.stringFromEnum(type.toString()),
      data,
    );
    return value;
  }

  static void updateCPListItem(CPListItem updatedListItem) {
    _methodChannel.invokeMethod(
      'updateListItem',
      <String, dynamic>{...updatedListItem.toJson()},
    ).then((value) {
      if (value) {
        l1:
        for (final template in templateHistory) {
          switch (template) {
            case final CPTabBarTemplate tabBarTemplate:
              log('UpdateCPListItem tabbar template case called');
              for (final t in tabBarTemplate.templates) {
                for (final s in t.sections) {
                  for (final i in s.items) {
                    if (i.uniqueId == updatedListItem.uniqueId) {
                      currentRootTemplate!
                          .templates[currentRootTemplate!.templates.indexOf(t)]
                          .sections[t.sections.indexOf(s)]
                          .items[s.items.indexOf(i)] = updatedListItem;
                      break l1;
                    }
                  }
                }
              }
              break;
            case final CPListTemplate listTemplate:
              log('UpdateCPListItem list template case called');
              for (final s in listTemplate.sections) {
                for (final i in s.items) {
                  if (i.uniqueId == updatedListItem.uniqueId) {
                    template.sections[template.sections.indexOf(s)]
                        .items[s.items.indexOf(i)] = updatedListItem;
                    log(
                      jsonEncode(
                        template.sections[template.sections.indexOf(s)]
                            .items[s.items.indexOf(i)]
                            .toJson(),
                      ),
                    );
                    break l1;
                  }
                }
              }
              break;
            default:
              log('UpdateCPListItem default case called');
          }
        }
      }
    });
  }

  void addTemplateToHistory(dynamic template) {
    if (template.runtimeType == CPTabBarTemplate ||
        template.runtimeType == CPGridTemplate ||
        template.runtimeType == CPInformationTemplate ||
        template.runtimeType == CPMapTemplate ||
        template.runtimeType == CPPointOfInterestTemplate ||
        template.runtimeType == CPListTemplate) {
      templateHistory.add(template);
    } else {
      throw TypeError();
    }
  }

  void processFCPListItemSelectedChannel(String elementId) {
    final listItem = _carplayHelper.findCPListItem(
      templates: templateHistory,
      elementId: elementId,
    );
    if (listItem != null) {
      listItem.onPressed!(
        () => reactToNativeModule(
          FCPChannelTypes.onFCPListItemSelectedComplete,
          listItem.uniqueId,
        ),
        listItem,
      );
    }
  }

  void processFCPAlertActionPressed(String elementId) {
    final CPAlertAction selectedAlertAction = currentPresentTemplate!.actions
        .firstWhere((e) => e.uniqueId == elementId);
    selectedAlertAction.onPressed();
  }

  void processFCPAlertTemplateCompleted({bool completed = false}) {
    if (currentPresentTemplate?.onPresent != null) {
      currentPresentTemplate!.onPresent!(completed);
    }
  }

  void processFCPGridButtonPressed(String elementId) {
    CPGridButton? gridButton;
    l1:
    for (final t in templateHistory) {
      if (t.runtimeType.toString() == 'CPGridTemplate') {
        for (final b in t.buttons) {
          if (b.uniqueId == elementId) {
            gridButton = b;
            break l1;
          }
        }
      }
    }
    if (gridButton != null) gridButton.onPressed();
  }

  void processFCPBarButtonPressed(String elementId) {
    l1:
    for (final t in templateHistory) {
      if (t.runtimeType.toString() == 'CPListTemplate') {
        CPBarButton? barButton;
        barButton = t.backButton;
        if (barButton != null) barButton.onPressed();
        break l1;
      } else {
        l2:
        if (t.runtimeType.toString() == 'CPMapTemplate') {
          for (final CPBarButton button in t.trailingNavigationBarButtons) {
            if (button.uniqueId == elementId) {
              button.onPressed();
              break l2;
            }
          }
          for (final CPBarButton button in t.leadingNavigationBarButtons) {
            if (button.uniqueId == elementId) {
              button.onPressed();
              break l2;
            }
          }
        }
      }
    }
  }

  void processFCPMapButtonPressed(String elementId) {
    l1:
    for (final t in templateHistory) {
      if (t.runtimeType.toString() == 'CPMapTemplate') {
        for (final CPMapButton button in t.mapButtons) {
          if (button.uniqueId == elementId) {
            button.onPressed();
            break l1;
          }
        }
      }
      break l1;
    }
  }

  void processFCPTextButtonPressed(String elementId) {
    l1:
    for (final t in templateHistory) {
      if (t.runtimeType.toString() == 'CPPointOfInterestTemplate') {
        for (final CPPointOfInterest p in t.poi) {
          if (p.primaryButton != null &&
              p.primaryButton!.uniqueId == elementId) {
            p.primaryButton!.onPressed();
            break l1;
          }
          if (p.secondaryButton != null &&
              p.secondaryButton!.uniqueId == elementId) {
            p.secondaryButton!.onPressed();
            break l1;
          }
        }
      } else {
        if (t.runtimeType.toString() == 'CPInformationTemplate') {
          l2:
          for (final CPTextButton b in t.actions) {
            if (b.uniqueId == elementId) {
              b.onPressed();
              break l2;
            }
          }
        }
      }
    }
  }

  void processFCPSpeakerOnComplete(String elementId) {
    callbackObjects.removeWhere((e) {
      if (e.runtimeType == CPSpeaker) {
        // e.uniqueId == elementId;
        e.onCompleted();
        return true;
      }
      return false;
    });
  }
}
