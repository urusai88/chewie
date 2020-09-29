import 'dart:io';
import 'dart:ui';

import 'package:chewie/src/chewie_player.dart';
import 'package:chewie/src/cupertino_controls.dart';
import 'package:chewie/src/material_controls.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';

class PlayerWithControls extends StatelessWidget {
  PlayerWithControls({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final ChewieController chewieController = ChewieController.of(context);

    return _buildPlayerWithControls(chewieController, context);
  }

  Widget _buildPlayerWithControls(
      ChewieController chewieController, BuildContext context) {
    return ChangeNotifierProvider.value(
      value: chewieController.videoPlayerController,
      child: Consumer<VideoPlayerController>(
        builder: (context, model, _) {
          return LayoutBuilder(
            builder: (context, outerConstraints) {
              BoxConstraints targetConstraints, outerBoxConstraints;

              if (model.value.size == null) {
                targetConstraints = BoxConstraints(
                  maxWidth: outerConstraints.maxWidth,
                  maxHeight: outerConstraints.maxWidth / (16 / 9),
                );
                outerBoxConstraints = outerConstraints;
              } else {
                double factor = 1.0;

                if (model.value.aspectRatio > 1) {
                  factor = model.value.size.width / outerConstraints.maxWidth;
                } else if (model.value.aspectRatio < 1) {
                  factor = model.value.size.height / outerConstraints.maxHeight;
                } else {
                  factor = model.value.size.width / outerConstraints.maxWidth;
                }

                targetConstraints =
                    BoxConstraints.tight(model.value.size / factor);
                outerBoxConstraints = BoxConstraints.tightFor(
                  width: outerConstraints.maxWidth,
                  height: targetConstraints.maxHeight,
                );
              }

              /// https://github.com/flutter/flutter/issues/51250
              final factor = Platform.isAndroid ? 1.035 : 1.0;

              return Center(
                child: SizedBox(
                  width: outerBoxConstraints.maxWidth,
                  height: outerBoxConstraints.maxHeight,
                  child: Stack(
                    children: [
                      chewieController.placeholder ?? Container(),
                      Center(
                        /// https://github.com/flutter/flutter/issues/51250
                        child: SizedBox(
                          height: targetConstraints.maxHeight / factor,
                          width: targetConstraints.maxWidth,
                          child: VideoPlayer(model),
                        ),
                      ),
                      chewieController.overlay ?? Container(),
                      _buildControls(context, chewieController),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildControls(
    BuildContext context,
    ChewieController chewieController,
  ) {
    return chewieController.showControls
        ? chewieController.customControls != null
            ? chewieController.customControls
            : Theme.of(context).platform == TargetPlatform.android
                ? MaterialControls()
                : CupertinoControls(
                    backgroundColor: Color.fromRGBO(41, 41, 41, 0.7),
                    iconColor: Color.fromARGB(255, 200, 200, 200),
                  )
        : Container();
  }

  double _calculateAspectRatio(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final width = size.width;
    final height = size.height;

    return width > height ? width / height : height / width;
  }
}
