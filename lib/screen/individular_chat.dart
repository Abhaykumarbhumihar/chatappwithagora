import 'dart:async';

import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_caht_module/agora_code/makevideocall.dart';
import 'package:flutter_caht_module/controllers/individual_chat_controller.dart';
import 'package:flutter_caht_module/utils/ScreenUtils.dart';
import 'package:flutter_caht_module/widgets/network_image.dart';
import 'package:get/get.dart';
import 'package:sticky_grouped_list/sticky_grouped_list.dart';
import '../model/Message.dart';
import '../utils/Utils.dart';
import 'package:intl/intl.dart';
import 'package:swipeable_null_safety/swipeable_null_safety.dart';
import 'package:any_link_preview/any_link_preview.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/foundation.dart' as foundation;

class IndividualChat extends StatefulWidget {
  IndividualChat({super.key});

  @override
  State<IndividualChat> createState() => _IndividualChatState();
}

class _IndividualChatState extends State<IndividualChat>
    with SingleTickerProviderStateMixin {
  FocusNode focusNode = FocusNode();
  late AnimationController _controlleranim;
  late Animation<Offset> _animation;
  var controller = Get.find<IndividualChatController>();
  final GroupedItemScrollController itemScrollController =
      GroupedItemScrollController();

  // Identify and scroll to the replied message
  int highlightedIndex =
      -1; // Initially set to -1 to indicate no highlighted message
  void scrollToRepliedMessage(int index) {
    setState(() {
      highlightedIndex = index;
    });

    final selectedMessage = controller.messageList[index];
    final groupKey = DateTime.fromMillisecondsSinceEpoch(
            int.parse(selectedMessage.timestamp!))
        .toLocal();
    final itemIndex = controller.messageList.sublist(0, index).where((message) {
      final messageDateTime =
          DateTime.fromMillisecondsSinceEpoch(int.parse(message.timestamp!))
              .toLocal();
      return messageDateTime.year == groupKey.year &&
          messageDateTime.month == groupKey.month &&
          messageDateTime.day == groupKey.day;
    }).length;

    controller.scrollController.scrollTo(
      index: index,
      duration: const Duration(seconds: 2),
      curve: Curves.bounceOut, // Curves.bounceOut
    );

    Timer(const Duration(seconds: 6), () {
      setState(() {
        highlightedIndex = -1;
      });
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    controller.isPageOpen = true;

    _controlleranim = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _animation = Tween<Offset>(
      begin: const Offset(0.0, 1.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controlleranim,
      curve: Curves.easeOut,
    ));

    _controlleranim.forward();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<IndividualChatController>(builder: (controller) {
      if (controller.imageSelect == false) {
        return Scaffold(
            appBar: PreferredSize(
              preferredSize: const Size.fromHeight(65),
              child: controller.isMessageSelect
                  ? deleteMessageAppbar(controller)
                  : normalAppBar(),
            ),
            body: Container(
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
              child: WillPopScope(
                child: Column(
                  children: [
                    Expanded(
                        child: controller.messageList.length > 0 &&
                                controller.messageList.length != null
                            ? StickyGroupedListView<Message, DateTime>(
                                elements: controller.messageList,
                                order: StickyGroupedListOrder.ASC,
                                floatingHeader: false,
                                initialScrollIndex:
                                    controller.messageList.isNotEmpty
                                        ? controller.messageList.length - 1
                                        : 0,
                                addRepaintBoundaries: true,
                                stickyHeaderBackgroundColor: Colors.transparent,
                                itemScrollController:
                                    controller.scrollController,
                                groupBy: (Message element) {
                                  // Group by date
                                  final dateTime =
                                      DateTime.fromMillisecondsSinceEpoch(
                                          int.parse(element.timestamp!));
                                  return DateTime(dateTime.year, dateTime.month,
                                      dateTime.day);
                                  //this is for grouping with hh:mm:ss
                                  // return DateTime.fromMillisecondsSinceEpoch(
                                  //     int.parse(element.timestamp!));
                                },
                                groupSeparatorBuilder: (Message element) {
                                  // Build your sticky header widget
                                  final dateTime =
                                      DateTime.fromMillisecondsSinceEpoch(
                                          int.parse(element.timestamp!));
                                  final dateString =
                                      DateFormat('dd/MM/yyyy').format(dateTime);

                                  return Chip(
                                    label: Text(
                                      dateString,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  );
                                },
                                indexedItemBuilder:
                                    (context, Message element, index) {
                                  // Build your list item widget
                                  if (index >= 0 &&
                                      index < controller.messageList.length) {
                                    return Swipeable(
                                      threshold: 100.0,
                                      onSwipeLeft: () {
                                        controller.isReply = true;
                                        controller.replymessageid =
                                            controller.messageList[index];
                                      },
                                      onSwipeRight: () {
                                        controller.isReply = true;
                                        controller.replymessageid =
                                            controller.messageList[index];
                                      },
                                      background: Container(
                                        decoration: BoxDecoration(
                                          color: Colors.grey[300],
                                          borderRadius: const BorderRadius.all(
                                              Radius.circular(8.0)),
                                        ),
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.only(
                                            top: 2, bottom: 2),
                                        child: InkWell(
                                          onTap: () {
                                            /*todo--first time long press krna pdega , phir normal press pe bhi item select ho jayega delete ke liye*/

                                            if (controller
                                                .deletemessageList.isNotEmpty) {
                                              controller.addToDeletemessageList(
                                                  controller.messageList[index]
                                                      .messageId!);
                                            } else {
                                              //scroll to reply message
                                              element.deleteMessageUser!
                                                  .contains(
                                                      controller.currentUserid);
                                              String idToFind = element
                                                  .replyMessageData!
                                                  .messageId!; // Example ID to find
                                              int itemIndex = controller
                                                  .messageList
                                                  .indexWhere((item) =>
                                                      item.messageId ==
                                                      idToFind);
                                              print(
                                                  'Item index with ID $idToFind is $itemIndex');
                                              scrollToRepliedMessage(itemIndex);
                                            }
                                            //    controller.deleteMessage();
                                          },
                                          onLongPress: () {
                                            print(Get.find<
                                                    IndividualChatController>()
                                                .isMessageSelect);
                                            controller.addToDeletemessageList(
                                                controller.messageList[index]
                                                    .messageId!);
                                          },
                                          child: controller.messageList[index]
                                                      .senderId ==
                                                  controller.currentUserid
                                              ?
                                              //curren user ka message show krwane k liye
                                              Container(
                                                  color: highlightedIndex ==
                                                          index
                                                      ? Colors.yellow.shade100
                                                      : null,
                                                  child: currentUserView(
                                                      controller,
                                                      context,
                                                      index),
                                                )
                                              :
                                              //other user ka message show krwane ke liye
                                              Container(
                                                  color: highlightedIndex ==
                                                          index
                                                      ? Colors.yellow.shade100
                                                      : null,
                                                  child: otherUserView(
                                                      controller,
                                                      context,
                                                      index),
                                                ),
                                        ),
                                      ),
                                    );
                                  } else {
                                    return SizedBox();
                                  }
                                },
                              )
                            : const SizedBox()),
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: Column(
                        children: [
                          controller.isReply
                              ? SlideTransition(
                                  position: _animation,
                                  child: Container(
                                    width: MediaQuery.of(context).size.width,
                                    decoration: const BoxDecoration(
                                      color: Colors.black12,
                                      borderRadius: BorderRadius.only(
                                        topLeft: Radius.circular(20.0),
                                        topRight: Radius.circular(20.0),
                                      ),
                                    ),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        border: Border.all(color: Colors.grey),
                                        borderRadius:
                                            BorderRadius.circular(8.0),
                                      ),
                                      padding: const EdgeInsets.all(10.0),
                                      margin: const EdgeInsets.all(20.0),
                                      width: 300,
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.end,
                                            children: [
                                              GestureDetector(
                                                onTap: () {
                                                  controller.isReply = false;
                                                  controller.replymessageid =
                                                      Message();
                                                },
                                                child: const Icon(Icons.close),
                                              ),
                                            ],
                                          ),
                                          Text(
                                            '${controller.replymessageid.senderId}',
                                            style: const TextStyle(
                                                fontWeight: FontWeight.bold),
                                          ),
                                          const SizedBox(height: 5),
                                          Text(
                                              '${controller.replymessageid.text}'),
                                        ],
                                      ),
                                    ),
                                  ),
                                )
                              : const SizedBox(),
                          Container(
                            height: 70,
                            decoration: BoxDecoration(
                              color: Colors.grey.shade200,
                              borderRadius: const BorderRadius.only(
                                bottomLeft: Radius.circular(20.0),
                                bottomRight: Radius.circular(20.0),
                              ),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [bootomin()],
                            ),
                          ),
                          controller.showEmoji
                              ? Container(
                                  width: MediaQuery.of(context).size.width,
                                  height: 300,
                                  color: Colors.deepOrange.shade50,
                                  child: EmojiPicker(
                                    onEmojiSelected: null,
                                    onBackspacePressed: () {
                                      // Do something when the user taps the backspace button (optional)
                                      // Set it to null to hide the Backspace-Button
                                    },
                                    textEditingController:
                                        controller.textController,
                                    // pass here the same [TextEditingController] that is connected to your input field, usually a [TextFormField]
                                    config: Config(
                                      columns: 7,
                                      emojiSizeMax: 32 *
                                          (foundation.defaultTargetPlatform ==
                                                  TargetPlatform.iOS
                                              ? 1.30
                                              : 1.0),
                                      // Issue: https://github.com/flutter/flutter/issues/28894
                                      verticalSpacing: 0,
                                      horizontalSpacing: 0,
                                      gridPadding: EdgeInsets.zero,
                                      initCategory: Category.RECENT,
                                      bgColor: Color(0xFFF2F2F2),
                                      indicatorColor: Colors.blue,
                                      iconColor: Colors.grey,
                                      iconColorSelected: Colors.blue,
                                      backspaceColor: Colors.blue,
                                      skinToneDialogBgColor: Colors.white,
                                      skinToneIndicatorColor: Colors.grey,
                                      enableSkinTones: true,
                                      recentTabBehavior:
                                          RecentTabBehavior.RECENT,
                                      recentsLimit: 28,
                                      noRecents: const Text(
                                        'No Recents',
                                        style: TextStyle(
                                            fontSize: 20,
                                            color: Colors.black26),
                                        textAlign: TextAlign.center,
                                      ),
                                      // Needs to be const Widget
                                      loadingIndicator: const SizedBox.shrink(),
                                      // Needs to be const Widget
                                      tabIndicatorAnimDuration:
                                          kTabScrollDuration,
                                      categoryIcons: const CategoryIcons(),
                                      buttonMode: ButtonMode.MATERIAL,
                                    ),
                                  ),
                                )
                              : SizedBox(),
                        ],
                      ),
                    ),
                  ],
                ),
                onWillPop: () {
                  if (controller.showEmoji == true) {
                    // setState(() {
                    //   showEmoji = false;
                    // });
                    controller.showEmoji = false;
                  } else {
                    Navigator.pop(context);
                  }
                  return Future.value(false);
                },
              ),
            ));
      } else {
        return shareImageVideo(controller, context);
      }
    });
  }

  void _hideKeyboard(BuildContext context) {
    FocusScope.of(context).requestFocus(FocusNode());
    // Alternatively, you can use:
    // FocusScope.of(context).unfocus();
  }

  Widget bottomSheet(BuildContext context) {
    //print("SDF SDF SDF ");
    return Container(
      height: 270,
      width: MediaQuery.of(context).size.width,
      child: Card(
        margin: const EdgeInsets.all(18),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  InkWell(
                    onTap: () async {
                      controller.chatType = "doc";
                      dismissModalBottomSheet(context);
                      var data = await Utils.pickDocument();
                      print(data);
                    },
                    child: bottomSheetIcons(
                        Icons.insert_drive_file, Colors.indigo, "Document"),
                  ),
                  const SizedBox(width: 40),
                  InkWell(
                      onTap: () async {
                        controller.chatType = "img";
                        dismissModalBottomSheet(context);
                        controller.image =
                            (await Utils.openCame(Get.context!))!;
                      },
                      child: bottomSheetIcons(
                          Icons.camera_alt, Colors.pink, "Camera")),
                  const SizedBox(width: 40),
                  InkWell(
                      onTap: () async {
                        controller.chatType = "img";
                        dismissModalBottomSheet(context);
                        controller.image =
                            (await Utils.openGallery(Get.context!))!;
                      },
                      child: bottomSheetIcons(
                          Icons.insert_photo, Colors.purple, "Gallery"))
                ],
              ),
              const SizedBox(
                height: 30,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  InkWell(
                      onTap: () async {
                        dismissModalBottomSheet(context);
                        await Utils.pickAudio();
                      },
                      child: bottomSheetIcons(
                          Icons.headset, Colors.orange, "Audio")),
                  const SizedBox(width: 40),
                  bottomSheetIcons(Icons.location_pin, Colors.teal, "Location"),
                  const SizedBox(width: 40),
                  InkWell(
                      onTap: () async {
                        dismissModalBottomSheet(context);
                        controller.chatType = "contact";
                        var contactdata = await Utils.pickContact();

                        print(
                            "CONTACT SEND HERE ${contactdata!.phones![0].value}");
                        controller.sendMessage(
                            controller.userModel,
                            contactdata.phones![0].value.toString() ?? "",
                            "contact",
                            contactname: "${contactdata.displayName!}",
                            contactnumber:
                                contactdata.phones![0].value.toString() ?? "");
                      },
                      child: bottomSheetIcons(
                          Icons.person, Colors.blue, "Contact"))
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget bottomSheetIcons(IconData icon, Color bgColor, String text) {
    return Column(
      children: [
        CircleAvatar(
          backgroundColor: bgColor,
          radius: 30,
          child: Icon(icon, size: 29, color: Colors.white),
        ),
        const SizedBox(
          height: 5,
        ),
        Text(text, style: const TextStyle(fontSize: 12))
      ],
    );
  }

  Widget emojiSelect() {
    return Flexible(
      child: SizedBox(
          width: 400,
          height: 100,
          child: EmojiPicker(
            onEmojiSelected: null,
            onBackspacePressed: () {
              // Do something when the user taps the backspace button (optional)
              // Set it to null to hide the Backspace-Button
            },
            textEditingController: controller.textController,
            // pass here the same [TextEditingController] that is connected to your input field, usually a [TextFormField]
            config: Config(
              columns: 7,
              emojiSizeMax: 32 *
                  (foundation.defaultTargetPlatform == TargetPlatform.iOS
                      ? 1.30
                      : 1.0),
              // Issue: https://github.com/flutter/flutter/issues/28894
              verticalSpacing: 0,
              horizontalSpacing: 0,
              gridPadding: EdgeInsets.zero,
              initCategory: Category.RECENT,
              bgColor: Color(0xFFF2F2F2),
              indicatorColor: Colors.blue,
              iconColor: Colors.grey,
              iconColorSelected: Colors.blue,
              backspaceColor: Colors.blue,
              skinToneDialogBgColor: Colors.white,
              skinToneIndicatorColor: Colors.grey,
              enableSkinTones: true,
              recentTabBehavior: RecentTabBehavior.RECENT,
              recentsLimit: 28,
              noRecents: const Text(
                'No Recents',
                style: TextStyle(fontSize: 20, color: Colors.black26),
                textAlign: TextAlign.center,
              ),
              // Needs to be const Widget
              loadingIndicator: const SizedBox.shrink(),
              // Needs to be const Widget
              tabIndicatorAnimDuration: kTabScrollDuration,
              categoryIcons: const CategoryIcons(),
              buttonMode: ButtonMode.MATERIAL,
            ),
          )),
    );
  }

  normalAppBar() {
    return AppBar(
      leadingWidth: 80,
      titleSpacing: 0,
      leading: InkWell(
        onTap: () {
          !ScreenUtils.isLargeScreen(context) ? Navigator.pop(context) : null;
        },
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ScreenUtils.isLargeScreen(context)
                ? SizedBox()
                : const Icon(Icons.arrow_back, size: 24),
            InkWell(
              onTap: () {},
              child: CircleAvatar(
                //widget.chatsModel.isGroup ? Icons.groups :
                backgroundColor: Colors.purple[400],
                backgroundImage:
                    NetworkImage(controller.userModel.profileImage!),
                radius: 25,
                //widget.chatsModel.isGroup ? Icons.groups :
                // child:
                //     const Icon(Icons.person, color: Colors.white, size: 38),
              ),
            )
          ],
        ),
      ),
      title: InkWell(
        onTap: null,
        child: Container(
          margin: const EdgeInsets.all(6),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                  "${controller.userModel?.fname} ${controller.userModel.lname}",
                  style: const TextStyle(
                      fontSize: 18.5, fontWeight: FontWeight.bold)),
              Text("${controller.lastSeen}",
                  style: const TextStyle(fontSize: 13)),
            ],
          ),
        ),
      ),
      actions: [
        IconButton(
            onPressed: () {
              DateTime time = DateTime.now();
              var channelid =
                  '${controller.userModel?.id}${time.millisecondsSinceEpoch}';
              //userId,name,imageUrl,channelId,context
              controller.makeCall(
                  '${controller.userModel?.id}',
                  '${controller.userModel?.fname} ',
                  '${controller.userModel?.profileImage}',
                  channelid,
                  context,
                  '${controller.userModel.lname}');
            },
            icon: const Icon(
              Icons.videocam,
              color: Colors.deepPurple,
            )),
        IconButton(
            onPressed: () {
              DateTime time = DateTime.now();
              var channelid =
                  '${controller.userModel?.id}${time.millisecondsSinceEpoch}';
              //userId,name,imageUrl,channelId,context
              controller.makeAudioCall(
                  '${controller.userModel?.id}',
                  '${controller.userModel?.fname} ',
                  '${controller.userModel?.profileImage}',
                  channelid,
                  context,
                  '${controller.userModel.lname}');
            },
            icon: const Icon(
              Icons.call,
              color: Colors.deepPurple,
            )),
        PopupMenuButton<String>(onSelected: (value) {
          print(value);
        }, itemBuilder: (BuildContext context) {
          return [
            const PopupMenuItem(
              value: "View Contact",
              child: Text("View Contact"),
            ),
            const PopupMenuItem(
              value: "Media, links, and docs",
              child: Text("Media, links, and docs"),
            ),
            const PopupMenuItem(
              value: "Search",
              child: Text("Search"),
            ),
            const PopupMenuItem(
              value: "Mute notification",
              child: Text("Mute notification"),
            ),
            const PopupMenuItem(
              value: "Wallpaper",
              child: Text("Wallpaper"),
            ),
            const PopupMenuItem(
              value: "More",
              child: Text("More"),
            ),
          ];
        })
      ],
    );
  }

  deleteMessageAppbar(IndividualChatController controller) {
    return AppBar(
      leading: ScreenUtils.isLargeScreen(context)
          ? SizedBox()
          : InkWell(
              onTap: () {}, child: const Icon(Icons.arrow_back, size: 24)),
      title: const Text("Delete Messages"),
      actions: <Widget>[
        IconButton(
          icon: const Icon(Icons.delete),
          onPressed: () {
            showDeleteDialog(context, controller);
          },
        ),
        IconButton(
          icon: const Icon(Icons.copy),
          onPressed: () {
            // showDeleteDialog(context, controller);
          },
        ),
        IconButton(
          icon: const Icon(Icons.close),
          onPressed: () {
            controller.deletemessageList.clear();
            controller.deletemessageList.clear();
            controller.isMessageSelect = false;
          },
        ),
      ],
    );
  }

/*todo----current loggedin use view*/
  currentUserView(IndividualChatController controller, context, index) {
    var data = controller.messageList[index];
    // print(data.mediaurl);
    //print("${controller.messageList[index].messageType} SDF SDF MessageType");
//    print(data.deleteMessageUser!.contains(controller.currentUserid));

    String textWithLink = controller.messageList[index].text ?? "";
    RegExp regExp = RegExp(
        r'(?:(?:https?|ftp):\/\/)?[\w/\-?=%.]+\.[\w/\-?=%.]+',
        caseSensitive: false);
    Iterable<RegExpMatch> matches = regExp.allMatches(textWithLink);

    List<String> extractedLinks = [];
    for (RegExpMatch match in matches) {
      extractedLinks.add(match.group(0)!);
    }

    List<TextSpan> textSpans = [];
    List<String> splitText = textWithLink.split(regExp);

    for (int i = 0; i < splitText.length; i++) {
      textSpans.add(TextSpan(
          text: splitText[i], style: const TextStyle(color: Colors.black)));
      if (i < extractedLinks.length) {
        textSpans.add(
          TextSpan(
            text: extractedLinks[i],
            style: const TextStyle(
              color: Colors.blue, // Change color as needed
              decoration: TextDecoration.underline,
            ),
            recognizer: TapGestureRecognizer()
              ..onTap = () {
                print("SDF SDF SDF ");
                _launchURL(extractedLinks[i]);
              },
          ),
        );
      }
    }

    return data.deleteMessageUser!.contains(controller.currentUserid)
        ? const SizedBox()
        : Align(
            alignment: Alignment.centerRight,
            child: GestureDetector(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth:
                      controller.messageList[index].messageType == "contact"
                          ? MediaQuery.of(context).size.width * 0.6
                          : (controller.messageList[index].messageType == "img"
                              ? MediaQuery.of(context).size.width * 0.6
                              : MediaQuery.of(context).size.width - 45),
                ),
                child: Container(
                  /*make this color transparent if message is not select for dete
                                                  * else give any color */
                  color: controller.deletemessageList
                          .contains(controller.messageList[index].messageId)
                      ? Colors.yellow
                      : Colors.transparent,
                  width: MediaQuery.of(context).size.width,
                  alignment: Alignment.centerRight,
                  child: Card(
                    elevation: 1,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                    color: Colors.purple.shade50,
                    margin:
                        const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                    child: Stack(children: [
                      Container(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            //image message ka view
                            Visibility(
                                visible:
                                    controller.messageList[index].messageType ==
                                            "img"
                                        ? true
                                        : false,
                                child: Padding(
                                  padding: const EdgeInsets.only(
                                      left: 4, right: 4, top: 4),
                                  child: NetworkImageWidget(
                                    imageHeight:
                                        MediaQuery.of(context).size.height *
                                                0.4 -
                                            MediaQuery.of(context).size.height *
                                                0.06,
                                    imageWidth:
                                        MediaQuery.of(context).size.width * 0.6,
                                    imageUrl: controller
                                            .messageList[index].mediaurl ??
                                        "",
                                    radiusAll: 8,
                                    imageFitType: BoxFit.fill,
                                    placeHolder: "assets/svg/ICEF_WHITE.svg",
                                  ),
                                )),

                            Visibility(
                              /*todo---jb message type contact hoga to normail message view nhi show hoga nhi hoga*/
                              visible:
                                  controller.messageList[index].messageType ==
                                          "contact"
                                      ? false
                                      : true,
                              child: Padding(
                                padding: EdgeInsets.only(
                                    left: controller.messageList[index]
                                                .messageType ==
                                            "img"
                                        ? 8
                                        : 10,
                                    right: controller.messageList[index]
                                                .messageType ==
                                            "img"
                                        ? 10
                                        : 60,
                                    top: 5,
                                    bottom: 20),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    controller.messageList[index].isReply ==
                                            true
                                        ? Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Container(
                                                  padding:
                                                      const EdgeInsets.all(8),
                                                  color: Colors.grey[300],
                                                  child: Column(
                                                    children: <Widget>[
                                                      Text(
                                                        controller
                                                                .messageList[
                                                                    index]
                                                                .replyMessageData!
                                                                .text! ??
                                                            "",
                                                        textAlign:
                                                            TextAlign.start,
                                                        style: const TextStyle(
                                                          fontSize: 16,
                                                        ),
                                                      )
                                                    ],
                                                  )),
                                              //todo-----ye reply test ka normal message ka view hai
                                              Text(
                                                controller.messageList[index]
                                                            .messageType
                                                            .toString() ==
                                                        "img"
                                                    ? "${controller.messageList[index].text!}"
                                                    : controller
                                                        .messageList[index]
                                                        .text!,
                                                textAlign: TextAlign.start,
                                                style: const TextStyle(
                                                  fontSize: 16,
                                                ),
                                              )
                                            ],
                                          )
                                        : Column(
                                            //todo-----ye normal message ka view hai, App link preview k sath
                                            children: <Widget>[
                                              if (extractedLinks.isNotEmpty)
                                                for (String link
                                                    in extractedLinks)
                                                  AnyLinkPreview(
                                                    link: link,
                                                    displayDirection: UIDirection
                                                        .uiDirectionHorizontal,
                                                    showMultimedia: false,
                                                    bodyMaxLines: 5,
                                                    bodyTextOverflow:
                                                        TextOverflow.ellipsis,
                                                    titleStyle: const TextStyle(
                                                      color: Colors.black,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 15,
                                                    ),
                                                    bodyStyle: const TextStyle(
                                                        color: Colors.grey,
                                                        fontSize: 12),
                                                    errorBody:
                                                        'Show my custom error body',
                                                    errorTitle:
                                                        'Show my custom error title',
                                                    errorWidget:
                                                        const SizedBox(),
                                                    errorImage:
                                                        "https://google.com/",
                                                    cache:
                                                        const Duration(days: 7),
                                                    backgroundColor:
                                                        Colors.grey[300],
                                                    borderRadius: 12,
                                                    removeElevation: false,
                                                    boxShadow: [
                                                      const BoxShadow(
                                                          blurRadius: 3,
                                                          color: Colors.grey)
                                                    ],
                                                    onTap: () {
                                                      _launchURL(link);
                                                    }, // This disables tap event
                                                  ).paddingOnly(bottom: 10),
                                              SelectionArea(
                                                child: RichText(
                                                  text: TextSpan(
                                                    style: const TextStyle(
                                                        color: Colors.black),
                                                    // Set the default text color
                                                    children: textSpans,
                                                  ),
                                                ),
                                              )
                                            ],
                                          ) /*todo---ye normal message hai bina kisi reply ka*/
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      //time and double tick
                      Positioned(
                        bottom: 4,
                        right: 10,
                        child: Row(
                          children: [
                            Text(
                                controller.formatMillisecondsSinceEpoch(
                                    millisecondsSinceEpochString: controller
                                        .messageList[index].timestamp!),
                                style: TextStyle(
                                    fontSize: 13, color: Colors.grey[600])),
                            const SizedBox(
                              width: 5,
                            ),
                            const Icon(Icons.done_all, size: 20)
                          ],
                        ),
                      ),

                      /*contact number  message */
                      Visibility(
                          visible: controller.messageList[index].messageType ==
                                  "contact"
                              ? true
                              : false,
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 12.0),
                            child: contactView(
                                controller.messageList[index].contactName,
                                controller.messageList[index].contactNumber),
                          ))
                    ]),
                  ),
                ),
              ),
            ),
          );
  }

  /*todo----other user view*/
  otherUserView(IndividualChatController controller, context, index) {
    var data = controller.messageList[index];
    print(controller.userModel.id);
    print(data.deleteMessageUser!.contains(controller.userModel.id));
    String textWithLink = controller.messageList[index].text ?? "";
    RegExp regExp = RegExp(
        r'(?:(?:https?|ftp):\/\/)?[\w/\-?=%.]+\.[\w/\-?=%.]+',
        caseSensitive: false);
    Iterable<RegExpMatch> matches = regExp.allMatches(textWithLink);

    List<String> extractedLinks = [];
    for (RegExpMatch match in matches) {
      extractedLinks.add(match.group(0)!);
    }

    List<TextSpan> textSpans = [];
    List<String> splitText = textWithLink.split(regExp);
    for (int i = 0; i < splitText.length; i++) {
      textSpans.add(TextSpan(
          text: splitText[i], style: const TextStyle(color: Colors.black)));
      if (i < extractedLinks.length) {
        textSpans.add(
          TextSpan(
            text: extractedLinks[i],
            style: const TextStyle(
              color: Colors.blue, // Change color as needed
              decoration: TextDecoration.underline,
            ),
            recognizer: TapGestureRecognizer()
              ..onTap = () {
                print("SDF SDF SDF ");
                _launchURL(extractedLinks[i]);
              },
          ),
        );
      }
    }

    return data.deleteMessageUser!.contains(controller.currentUserid)
        ? const SizedBox()
        : Align(
            alignment: Alignment.centerLeft,
            child: GestureDetector(
              onDoubleTap: () {
                controller.isReply = true;
                controller.replymessageid = controller.messageList[index];
              },
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth:
                      controller.messageList[index].messageType == "contact"
                          ? MediaQuery.of(context).size.width * 0.6
                          : (controller.messageList[index].messageType == "img"
                              ? MediaQuery.of(context).size.width * 0.6
                              : MediaQuery.of(context).size.width - 45),
                ),
                child: Container(
                  /*make this color transparent if message is not select for dete
                                                    * else give any color */
                  color: controller.deletemessageList
                          .contains(controller.messageList[index].messageId)
                      ? Colors.yellow
                      : Colors.transparent,
                  width: MediaQuery.of(context).size.width,
                  alignment: Alignment.centerLeft,
                  child: Card(
                    elevation: 1,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                    color: Colors.purple[100],
                    margin:
                        const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                    child: Stack(children: [
                      Container(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            //todo image message ka view
                            Visibility(
                                visible:
                                    controller.messageList[index].messageType ==
                                            "img"
                                        ? true
                                        : false,
                                child: Padding(
                                  padding: const EdgeInsets.only(
                                      left: 4, right: 4, top: 4),
                                  child: NetworkImageWidget(
                                    imageHeight:
                                        MediaQuery.of(context).size.height *
                                                0.4 -
                                            MediaQuery.of(context).size.height *
                                                0.06,
                                    imageWidth:
                                        MediaQuery.of(context).size.width * 0.6,
                                    imageUrl: controller
                                            .messageList[index].mediaurl ??
                                        "",
                                    radiusAll: 8,
                                    imageFitType: BoxFit.fill,
                                    placeHolder: "assets/svg/ICEF_WHITE.svg",
                                  ),
                                )),
                            Visibility(
                              /*todo---jb message type contact hoga to normail message view nhi show hoga nhi hoga*/
                              visible:
                                  controller.messageList[index].messageType ==
                                          "contact"
                                      ? false
                                      : true,
                              child: Padding(
                                padding: EdgeInsets.only(
                                    left: controller.messageList[index]
                                                .messageType ==
                                            "img"
                                        ? 8
                                        : 10,
                                    right: controller.messageList[index]
                                                .messageType ==
                                            "img"
                                        ? 10
                                        : 60,
                                    top: 5,
                                    bottom: 20),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    controller.messageList[index].isReply ==
                                            true
                                        ?

                                        //todo---reply message ka view
                                        Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Container(
                                                  padding:
                                                      const EdgeInsets.all(8),
                                                  color: Colors.grey[300],
                                                  child: Column(
                                                    children: <Widget>[
                                                      Text(
                                                        controller
                                                                .messageList[
                                                                    index]
                                                                .replyMessageData!
                                                                .text! ??
                                                            "",
                                                        textAlign:
                                                            TextAlign.start,
                                                        style: const TextStyle(
                                                          fontSize: 16,
                                                        ),
                                                      )
                                                    ],
                                                  )),
                                              Text(
                                                controller.messageList[index]
                                                            .messageType
                                                            .toString() ==
                                                        "img"
                                                    ? "${controller.messageList[index].text!}"
                                                    : controller
                                                        .messageList[index]
                                                        .text!,
                                                textAlign: TextAlign.start,
                                                style: const TextStyle(
                                                  fontSize: 16,
                                                ),
                                              )
                                            ],
                                          )
                                        : Column(
                                            children: <Widget>[
                                              if (extractedLinks.isNotEmpty)
                                                for (String link
                                                    in extractedLinks)
                                                  AnyLinkPreview(
                                                    link: link,
                                                    displayDirection: UIDirection
                                                        .uiDirectionVertical,
                                                    showMultimedia: false,
                                                    bodyMaxLines: 5,
                                                    bodyTextOverflow:
                                                        TextOverflow.ellipsis,
                                                    titleStyle: const TextStyle(
                                                      color: Colors.black,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 15,
                                                    ),
                                                    bodyStyle: const TextStyle(
                                                        color: Colors.grey,
                                                        fontSize: 12),
                                                    errorBody:
                                                        'Show my custom error body',
                                                    errorTitle:
                                                        'Show my custom error title',
                                                    errorWidget: Container(
                                                      color: Colors.grey[300],
                                                      child: const Text(''),
                                                    ),
                                                    errorImage:
                                                        "https://google.com/",
                                                    cache:
                                                        const Duration(days: 7),
                                                    backgroundColor:
                                                        Colors.grey[300],
                                                    borderRadius: 12,
                                                    removeElevation: false,
                                                    boxShadow: [
                                                      const BoxShadow(
                                                          blurRadius: 3,
                                                          color: Colors.grey)
                                                    ],
                                                    onTap: () {
                                                      _launchURL(link);
                                                    }, // This disables tap event
                                                  ),
                                              RichText(
                                                text: TextSpan(
                                                    children: textSpans),
                                              ),
                                              /*todo---ye normal message hai bina kisi reply ka*/
                                            ],
                                          )
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      //time and double tick
                      Positioned(
                        bottom: 4,
                        right: 10,
                        child: Row(
                          children: [
                            Text(
                                controller.formatMillisecondsSinceEpoch(
                                    millisecondsSinceEpochString: controller
                                        .messageList[index].timestamp!),
                                style: TextStyle(
                                    fontSize: 13, color: Colors.grey[600])),
                            const SizedBox(
                              width: 5,
                            ),
                          ],
                        ),
                      ),

                      /*contact number  message */
                      Visibility(
                          visible: controller.messageList[index].messageType ==
                                  "contact"
                              ? true
                              : false,
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 12.0),
                            child: contactView(
                                controller.messageList[index].contactName,
                                controller.messageList[index].contactNumber),
                          ))
                    ]),
                  ),
                ),
              ),
            ));
  }

  void dismissModalBottomSheet(BuildContext context) {
    Navigator.of(context).pop();
  }

  Widget shareImageVideo(IndividualChatController controller, context) {
    return Scaffold(
        body: Stack(
      alignment: Alignment.topLeft,
      children: <Widget>[
        // Full-size image
        controller.imageSelect
            ? Image.file(
                controller.image,
                fit: BoxFit.cover,
                height: MediaQuery.of(context).size.height,
              )
            : const Text('No image selected'),

        // Cancel button in the top-right corner
        Padding(
          padding: const EdgeInsets.only(left: 16.0, top: 34.0),
          child: IconButton(
            icon: const Icon(Icons.cancel, color: Colors.white, size: 34),
            onPressed: () {
              controller.imageSelect = false;
            },
          ),
        ),

        // Caption and send button row at the bottom
        Align(
          alignment: Alignment.bottomCenter,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(36.0),
                color: Colors.black.withOpacity(0.6),
              ),
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                    child: TextField(
                      controller: controller.captionController,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: 'Add caption...',
                          hintStyle: const TextStyle(color: Colors.white),
                          prefixIcon: IconButton(
                            icon: Icon(controller.showEmoji
                                ? Icons.keyboard
                                : Icons.emoji_emotions),
                            onPressed: () {
                              if (!controller.showEmoji) {
                                focusNode.unfocus();
                                focusNode.canRequestFocus = false;
                              }
                              controller.showEmoji = !controller.showEmoji;
                            },
                          )),
                    ),
                  ),
                  const SizedBox(width: 8.0),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8.0, right: 2),
                    child: CircleAvatar(
                      radius: 25,
                      backgroundColor: Colors.purple[400],
                      child: IconButton(
                          onPressed: () {
                            controller.imageSelect = false;
                            controller.sendImageMessage(
                              controller.userModel,
                              controller.captionController.text.toString(),
                              controller.image,
                            );
                          },
                          icon: const Icon(
                            Icons.send,
                            color: Colors.white,
                          )),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    ));
  }

  Widget contactView(name, number) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                const CircleAvatar(
                  backgroundImage: AssetImage("assets/svg/profile.png"),
                  radius: 15.0,
                ),
                const SizedBox(width: 4.0),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      "$name",
                      style: const TextStyle(
                          fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                    Text("$number", style: const TextStyle(fontSize: 10)),
                  ],
                )
              ],
            ),
            const Divider(
              color: Colors.indigo,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                InkWell(onTap: () {}, child: const Icon(Icons.message)),
                InkWell(onTap: () {}, child: const Icon(Icons.phone)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget bootomin() {
    if (ScreenUtils.isLargeScreen(context)) {
      return Row(
        children: [
          Expanded(
            flex: 2,
            child: Container(
                width: MediaQuery.of(context).size.width,
                child: Card(
                    margin: const EdgeInsets.only(left: 2, right: 2, bottom: 8),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25)),
                    child: TextFormField(
                      controller: controller.textController,
                      focusNode: focusNode,
                      textAlignVertical: TextAlignVertical.center,
                      keyboardType: TextInputType.multiline,
                      maxLines: 5,
                      minLines: 1,
                      onChanged: (value) {
                        if (value.length > 0) {
                          controller.sendChatButton = true;
                          controller.updateTypingStaus(true);
                          controller.isTyping = true;
                        } else {
                          controller.sendChatButton = false;
                          controller.isTyping = false;
                          controller.updateTypingStaus(false);
                        }
                      },
                      decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: "Type your message",
                          suffixIcon: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                  onPressed: () {
                                    showModalBottomSheet(
                                        backgroundColor: Colors.transparent,
                                        context: context,
                                        builder: (builder) =>
                                            bottomSheet(context));
                                  },
                                  icon: const Icon(Icons.attach_file)),
                              IconButton(
                                  onPressed: () {},
                                  icon: const Icon(Icons.camera))
                            ],
                          ),
                          contentPadding: const EdgeInsets.all(5),
                          prefixIcon: IconButton(
                            icon: Icon(controller.showEmoji
                                ? Icons.keyboard
                                : Icons.emoji_emotions),
                            onPressed: () {
                              if (!controller.showEmoji) {
                                focusNode.unfocus();
                                focusNode.canRequestFocus = false;
                              }
                              controller.showEmoji = !controller.showEmoji;
                              _hideKeyboard(context);
                            },
                          )),
                    ))),
          ),
          Expanded(
              child: Padding(
            padding: const EdgeInsets.only(bottom: 8.0, right: 2),
            child: CircleAvatar(
              radius: 25,
              backgroundColor: Colors.purple[400],
              child: IconButton(
                  onPressed: () {
                    if (controller.sendChatButton) {
                      controller.chatType = "text";
                      controller.sendMessage(
                          controller.userModel,
                          controller.textController.text.toString(),
                          controller.chatType);
                      controller.textController.clear();
                      controller.sendChatButton = false;
                    }
                  },
                  icon: Icon(
                    controller.sendChatButton ? Icons.send : Icons.mic,
                    color: Colors.white,
                  )),
            ),
          )),
        ],
      );
    } else {
      return Row(
        children: [
          Container(
              width: MediaQuery.of(context).size.width - 55,
              child: Card(
                  margin: const EdgeInsets.only(left: 2, right: 2, bottom: 8),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25)),
                  child: TextFormField(
                    controller: controller.textController,
                    focusNode: focusNode,
                    textAlignVertical: TextAlignVertical.center,
                    keyboardType: TextInputType.multiline,
                    maxLines: 5,
                    minLines: 1,
                    onChanged: (value) {
                      if (value.length > 0) {
                        controller.sendChatButton = true;
                        controller.updateTypingStaus(true);
                        controller.isTyping = true;
                      } else {
                        controller.sendChatButton = false;
                        controller.isTyping = false;
                        controller.updateTypingStaus(false);
                      }
                    },
                    decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: "Type your message",
                        suffixIcon: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                                onPressed: () {
                                  showModalBottomSheet(
                                      backgroundColor: Colors.transparent,
                                      context: context,
                                      builder: (builder) =>
                                          bottomSheet(context));
                                },
                                icon: const Icon(Icons.attach_file)),
                            IconButton(
                                onPressed: () {},
                                icon: const Icon(Icons.camera))
                          ],
                        ),
                        contentPadding: const EdgeInsets.all(5),
                        prefixIcon: IconButton(
                          icon: Icon(controller.showEmoji
                              ? Icons.keyboard
                              : Icons.emoji_emotions),
                          onPressed: () {
                            if (!controller.showEmoji) {
                              focusNode.unfocus();
                              focusNode.canRequestFocus = false;
                            }
                            controller.showEmoji = !controller.showEmoji;
                            _hideKeyboard(context);
                          },
                        )),
                  ))),
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0, right: 2),
            child: CircleAvatar(
              radius: 25,
              backgroundColor: Colors.purple[400],
              child: IconButton(
                  onPressed: () {
                    if (controller.sendChatButton) {
                      controller.chatType = "text";
                      controller.sendMessage(
                          controller.userModel,
                          controller.textController.text.toString(),
                          controller.chatType);
                      controller.textController.clear();
                      controller.sendChatButton = false;
                    }
                  },
                  icon: Icon(
                    controller.sendChatButton ? Icons.send : Icons.mic,
                    color: Colors.white,
                  )),
            ),
          ),
        ],
      );
    }
  }

  @override
  void dispose() {
    super.dispose();
    controller.isPageOpen = false;
    print("PAGE IS CLOSE");
  }

  void showDeleteDialog(
      BuildContext context, IndividualChatController controller) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          iconPadding: EdgeInsets.zero,
          title: const Text(
            'Delete message?',
            style: TextStyle(color: Colors.grey, fontSize: 16.0),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: <Widget>[
                  const SizedBox(height: 16.0),
                  GestureDetector(
                    onTap: () {
                      Navigator.of(context).pop();
                      controller.deleteMessage("forme");
                      // controller.updateDeleteMessageArray();
                    },
                    child: const Text(
                      'Delete for me',
                      style:
                          TextStyle(color: Colors.blueAccent, fontSize: 16.0),
                    ),
                  ),
                  const SizedBox(height: 25.0),
                  GestureDetector(
                    onTap: () {
                      Navigator.of(context).pop();
                      controller.deleteMessage("foreveryone");
                    },
                    child: const Text(
                      'Delete for everyone',
                      style:
                          TextStyle(color: Colors.blueAccent, fontSize: 16.0),
                    ),
                  ),
                  const SizedBox(height: 25.0),
                  GestureDetector(
                    onTap: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text(
                      'Cancel',
                      style:
                          TextStyle(color: Colors.blueAccent, fontSize: 16.0),
                    ),
                  )
                ],
              )
            ],
          ),
        );
      },
    );
  }

  Future<void> _launchURL(String url) async {
    if (!await launchUrl(Uri.parse(url))) {
      throw Exception('Could not launch $url');
    }
  }
}
