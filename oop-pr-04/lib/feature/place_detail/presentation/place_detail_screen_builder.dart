import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:surf_mad_teacher_training/core/domain/entities/result/result.dart';
import 'package:surf_mad_teacher_training/feature/app/di/app_scope.dart';
import 'package:surf_mad_teacher_training/feature/common/domain/entities/place_entity.dart';
import 'package:surf_mad_teacher_training/feature/common/presentation/widgets/errors/app_error_widget.dart';
import 'package:surf_mad_teacher_training/feature/place_detail/presentation/place_detail_model.dart';
import 'package:surf_mad_teacher_training/feature/place_detail/presentation/place_detail_screen.dart';
import 'package:surf_mad_teacher_training/feature/place_detail/presentation/place_detail_wm.dart';

@RoutePage()
class PlaceDetailScreenBuilder extends StatefulWidget {
  const PlaceDetailScreenBuilder({required this.place, super.key});

  final PlaceEntity place;

  @override
  State<PlaceDetailScreenBuilder> createState() => _PlaceDetailScreenBuilderState();
}

class _PlaceDetailScreenBuilderState extends State<PlaceDetailScreenBuilder> {
  late final appScope = context.read<IAppScope>();
  late final model = PlaceDetailModel(appScope.apiClient, appScope.placeResponseConverter);
  late var _result = model.load(widget.place.id);

  @override
  void didUpdateWidget(covariant PlaceDetailScreenBuilder oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.place.id != widget.place.id) _result = model.load(widget.place.id);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _result,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(appBar: AppBar(), body: const Center(child: CircularProgressIndicator()));
        }
        final result = snapshot.data;
        if (result case ResultOk(:final data)) {
          return Provider(
            create: (_) => PlaceDetailWM(context: context),
            dispose: (_, wm) => wm.dispose(),
            builder: (context, _) => PlaceDetailScreen(wm: context.read<PlaceDetailWM>(), place: data),
          );
        }
        return Scaffold(
          appBar: AppBar(),
          body: AppErrorWidget(
            switch (result) {
              ResultFailed(:final error) => error,
              _ => null,
            },
            onRetryPressed: () => setState(() => _result = model.load(widget.place.id)),
          ),
        );
      },
    );
  }
}
