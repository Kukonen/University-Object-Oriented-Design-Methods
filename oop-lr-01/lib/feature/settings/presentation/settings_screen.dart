import 'package:auto_route/auto_route.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:surf_mad_teacher_training/assets/images/app_svg_icons.dart';
import 'package:surf_mad_teacher_training/assets/strings/app_strings.dart';
import 'package:surf_mad_teacher_training/feature/app/di/app_scope.dart';
import 'package:surf_mad_teacher_training/feature/settings/presentation/settings_wm.dart';
import 'package:surf_mad_teacher_training/navigation/router.dart';
import 'package:surf_mad_teacher_training/uikit/images/svg_picture_widget.dart';
import 'package:surf_mad_teacher_training/uikit/themes/colors/app_color_theme.dart';
import 'package:surf_mad_teacher_training/uikit/themes/text/app_text_theme.dart';

part 'widgets/_theme_switch_widget.dart';
part 'widgets/_tutorial_list_tile_widget.dart';

/// {@template settings_screen.class}
/// Экран с настройками.
/// {@endtemplate}
class SettingsScreen extends StatelessWidget {
  final ISettingsWM wm;

  /// {@macro settings_screen.class}
  const SettingsScreen({required this.wm, super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(automaticallyImplyLeading: false, title: Text(AppStrings.settingsAppBarTitle), centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _ThemeSwitchWidget(isDarkThemeModeState: wm.isDarkThemeModeState, onChanged: wm.onThemeChanged),
            Divider(),
            _TutorialListTileWidget(onTutorialPressed: wm.onTutorialPressed),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.bookmark_outline),
              title: const Text('Сохранить пресет фильтра'),
              onTap: () => _savePreset(context),
            ),
            ListTile(
              leading: const Icon(Icons.tune),
              title: const Text('Выбрать сохранённый фильтр'),
              onTap: () => _choosePreset(context),
            ),
            ListTile(
              leading: const Icon(Icons.delete_outline),
              title: const Text('Очистить все фильтры'),
              onTap: () => _clearFilters(context),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _savePreset(BuildContext context) async {
    final storage = context.read<IAppScope>().filterStorage;
    var name = '';
    final result = await showDialog<String>(
      context: context,
      builder:
          (dialogContext) => AlertDialog(
            title: const Text('Название пресета'),
            content: TextField(autofocus: true, maxLength: 60, onChanged: (value) => name = value.trim()),
            actions: [
              TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Отмена')),
              FilledButton(
                onPressed: () {
                  if (name.isNotEmpty) Navigator.pop(dialogContext, name);
                },
                child: const Text('Сохранить'),
              ),
            ],
          ),
    );
    if (result == null || !context.mounted) return;
    await storage.savePreset(result);
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Пресет сохранён')));
    }
  }

  Future<void> _choosePreset(BuildContext context) async {
    final storage = context.read<IAppScope>().filterStorage;
    final presets = await storage.presets();
    if (!context.mounted) return;
    final id = await showDialog<int>(
      context: context,
      builder:
          (dialogContext) => SimpleDialog(
            title: const Text('Сохранённые фильтры'),
            children: [
              if (presets.isEmpty) const Padding(padding: EdgeInsets.all(20), child: Text('Пресетов пока нет')),
              for (final preset in presets)
                SimpleDialogOption(
                  onPressed: () => Navigator.pop(dialogContext, preset.id),
                  child: Text(preset.name),
                ),
            ],
          ),
    );
    if (id == null || !context.mounted) return;
    await storage.activatePreset(id);
    if (context.mounted) await _reloadPlaces(context);
  }

  Future<void> _clearFilters(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (dialogContext) => AlertDialog(
            title: const Text('Очистить все фильтры?'),
            actions: [
              TextButton(onPressed: () => Navigator.pop(dialogContext, false), child: const Text('Отмена')),
              FilledButton(onPressed: () => Navigator.pop(dialogContext, true), child: const Text('Очистить')),
            ],
          ),
    );
    if (confirmed != true || !context.mounted) return;
    await context.read<IAppScope>().filterStorage.clear();
    if (context.mounted) await _reloadPlaces(context);
  }

  Future<void> _reloadPlaces(BuildContext context) =>
      context.router.root.replaceAll([const BottomNavRoute()], updateExistingRoutes: false);
}
