import 'package:flutter/material.dart';

enum FormScreenState {
  view,
  create,
  edit,
}

class AppFormFieldStateConfig {
  final bool enabledOnCreate;
  final bool enabledOnEdit;
  final bool enabledOnView;

  const AppFormFieldStateConfig({
    this.enabledOnCreate = true,
    this.enabledOnEdit = true,
    this.enabledOnView = false,
  });

  bool isEnabled(FormScreenState state) {
    switch (state) {
      case FormScreenState.view:
        return enabledOnView;
      case FormScreenState.create:
        return enabledOnCreate;
      case FormScreenState.edit:
        return enabledOnEdit;
    }
  }
}

typedef AppFormFieldBuilder = Widget Function(
  BuildContext context,
  bool enabled,
);

class AppFormFieldConfig {
  final String id;
  final int flex;
  final AppFormFieldStateConfig stateConfig;
  final AppFormFieldBuilder builder;

  const AppFormFieldConfig({
    required this.id,
    required this.builder,
    this.stateConfig = const AppFormFieldStateConfig(),
    this.flex = 1,
  });
}

class AppFormActionsConfig {
  final VoidCallback? onCreate;
  final VoidCallback? onEdit;
  final VoidCallback? onView;
  final VoidCallback? onCancel;
  final VoidCallback? onViewEdit;
  final String createLabel;
  final String editLabel;
  final String viewLabel;
  final String cancelLabel;
  final String viewEditLabel;

  const AppFormActionsConfig({
    this.onCreate,
    this.onEdit,
    this.onView,
    this.onCancel,
    this.onViewEdit,
    this.createLabel = 'Salvar',
    this.editLabel = 'Salvar alterações',
    this.viewLabel = 'Fechar',
    this.cancelLabel = 'Fechar',
    this.viewEditLabel = 'Editar',
  });

  String labelForState(FormScreenState state) {
    switch (state) {
      case FormScreenState.view:
        return viewLabel;
      case FormScreenState.create:
        return createLabel;
      case FormScreenState.edit:
        return editLabel;
    }
  }

  VoidCallback? actionForState(FormScreenState state) {
    switch (state) {
      case FormScreenState.view:
        return onView;
      case FormScreenState.create:
        return onCreate;
      case FormScreenState.edit:
        return onEdit;
    }
  }
}

class AppForm extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final FormScreenState state;
  final List<AppFormFieldConfig> fields;
  final AppFormActionsConfig actions;
  final int desktopColumns;
  final double horizontalGap;
  final double verticalGap;

  const AppForm({
    super.key,
    required this.formKey,
    required this.state,
    required this.fields,
    required this.actions,
    this.desktopColumns = 2,
    this.horizontalGap = 16,
    this.verticalGap = 16,
  });

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              final width = constraints.maxWidth;
              final isMobile = width < 600;
              final columns = isMobile ? 1 : desktopColumns;
              final baseWidth = isMobile
                  ? constraints.maxWidth
                  : (constraints.maxWidth - (columns - 1) * horizontalGap) /
                      columns;

              return Wrap(
                spacing: horizontalGap,
                runSpacing: verticalGap,
                children: fields.map((field) {
                  final enabled = field.stateConfig.isEnabled(state);
                  final fieldWidth =
                      isMobile ? double.infinity : baseWidth * field.flex;

                  return SizedBox(
                    width: fieldWidth,
                    child: field.builder(context, enabled),
                  );
                }).toList(),
              );
            },
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              if (state == FormScreenState.view) ...[
                FilledButton(
                  onPressed: actions.onView ?? actions.onCancel,
                  child: Text(actions.viewLabel),
                ),
                const SizedBox(width: 8),
                if (actions.onViewEdit != null) ...[
                  FilledButton(
                    onPressed: actions.onViewEdit,
                    child: Text(actions.viewEditLabel),
                  ),
                ],
              ] else ...[
                FilledButton(
                  onPressed: actions.onCancel,
                  child: Text(actions.cancelLabel),
                ),
                const SizedBox(width: 8),
                FilledButton(
                  onPressed: actions.actionForState(state),
                  child: Text(actions.labelForState(state)),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
