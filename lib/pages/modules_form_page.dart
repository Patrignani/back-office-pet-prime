import 'package:flutter/material.dart';
import '../../widgets/app_form.dart';
import '../services/modules_slug_service.dart';
import '../auth/auth_scope.dart';
import '../models/modules_slug/module_slug_get_all.dart';
import '../core/formatters/money_input_formatter.dart';
import '../../core/utils/money_utils.dart';
import '../services/module_service.dart';
import 'package:go_router/go_router.dart';
import '../core/exceptions.dart';
import 'package:logger/logger.dart';

class ModulesFormPage extends StatefulWidget {
  final FormScreenState state;
  final String? moduleId;

  const ModulesFormPage({
    super.key,
    required this.state,
    this.moduleId,
  });

  @override
  State<ModulesFormPage> createState() => _ModulesFormPageState();
}

class _ModulesFormPageState extends State<ModulesFormPage> {
  final _idCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _valueCtrl = TextEditingController();
  final _slugService = ModuleSlugService();

  bool _loading = false;
  bool _loadingSlugs = false;
  String _token = '';
  bool _initialized = false;

  List<ModuleSlugGetAll> _slugOptions = [];
  ModuleSlugGetAll? _selectedSlug;
  bool _activated = true;
  final _service = ModuleService();

  InputDecoration _dec(String label) => InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
      );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    print(widget.state.name);

    if (!_initialized) {
      _token = AuthScope.of(context).token ?? '';
      _initialized = true;

      if (widget.state != FormScreenState.create && widget.moduleId != null) {
        _loadModule();
      } else {
        _loadSlugOptions();
      }
    }
  }

  Future<void> _loadModule() async {
    setState(() => _loading = true);

    try {
      await _loadSlugOptions();

      final values =
          await _service.getModulesId(token: _token, id: widget.moduleId!);

      _idCtrl.text = values.id;
      _nameCtrl.text = values.name;
      _valueCtrl.text = formatMoneyToInput(values.value);
      setState(() => _selectedSlug =
          _slugOptions.firstWhere((s) => s.id == values.slugId));
      _activated = values.activated;
    } on SessionExpiredException {
      if (!mounted) return;

      final auth = AuthScope.of(context);
      auth.logout();
      context.go('/login');
      return;
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  Future<void> _loadSlugOptions() async {
    setState(() => _loadingSlugs = true);
    try {
      final slugs = await _slugService.getModulesSlug(token: _token);
      if (mounted) {
        setState(() {
          _slugOptions = slugs;
        });
      }
    } on SessionExpiredException {
      if (!mounted) return;

      final auth = AuthScope.of(context);
      auth.logout();
      context.go('/login');
      return;
    } finally {
      if (mounted) {
        setState(() => _loadingSlugs = false);
      }
    }
  }

  @override
  void dispose() {
    _idCtrl.dispose();
    _nameCtrl.dispose();
    _valueCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading || _loadingSlugs) {
      return const Center(child: CircularProgressIndicator());
    }

    final theme = Theme.of(context).copyWith(
      inputDecorationTheme: const InputDecorationTheme(),
    );

    return Theme(
      data: theme,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: AppForm(
              formKey: _formKey,
              state: widget.state,
              desktopColumns: 3,
              fields: [
                AppFormFieldConfig(
                  id: 'id',
                  stateConfig: const AppFormFieldStateConfig(
                    enabledOnCreate: false,
                    enabledOnEdit: false,
                    enabledOnView: false,
                  ),
                  flex: 1,
                  builder: (context, enabled) {
                    return TextFormField(
                      controller: _idCtrl,
                      enabled: enabled,
                      readOnly: !enabled,
                      decoration: _dec('ID'),
                    );
                  },
                ),
                AppFormFieldConfig(
                  id: 'name',
                  stateConfig: const AppFormFieldStateConfig(
                    enabledOnCreate: true,
                    enabledOnEdit: true,
                    enabledOnView: false,
                  ),
                  flex: 1,
                  builder: (context, enabled) {
                    return TextFormField(
                      controller: _nameCtrl,
                      readOnly: !enabled,
                      enabled: enabled,
                      decoration: _dec('Nome'),
                      validator: (v) =>
                          v == null || v.isEmpty ? 'Campo obrigatório' : null,
                    );
                  },
                ),
                AppFormFieldConfig(
                  id: 'value',
                  stateConfig: const AppFormFieldStateConfig(
                    enabledOnCreate: true,
                    enabledOnEdit: true,
                    enabledOnView: false,
                  ),
                  flex: 1,
                  builder: (context, enabled) {
                    return TextFormField(
                      controller: _valueCtrl,
                      readOnly: !enabled,
                      enabled: enabled,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        MoneyInputFormatter(),
                      ],
                      decoration: _dec('Valor (R\$)'),
                      validator: (v) {
                        if (v == null || v.isEmpty || v == '0,00') {
                          return 'Informe o valor';
                        }
                        return null;
                      },
                    );
                  },
                ),
                AppFormFieldConfig(
                  id: 'slug',
                  flex: 1,
                  stateConfig: const AppFormFieldStateConfig(
                    enabledOnCreate: true,
                    enabledOnEdit: false,
                    enabledOnView: false,
                  ),
                  builder: (context, enabled) {
                    return DropdownButtonFormField<ModuleSlugGetAll>(
                      isExpanded: true,
                      initialValue: _selectedSlug,
                      items: _slugOptions
                          .map(
                            (item) => DropdownMenuItem<ModuleSlugGetAll>(
                              value: item,
                              child: Text(item.name),
                            ),
                          )
                          .toList(),
                      onChanged: enabled
                          ? (value) {
                              setState(() {
                                _selectedSlug = value;
                              });
                            }
                          : null,
                      decoration: _dec('Slug'),
                      validator: (v) => v == null ? 'Campo obrigatório' : null,
                    );
                  },
                ),
                AppFormFieldConfig(
                  id: 'activated',
                  flex: 1,
                  stateConfig: const AppFormFieldStateConfig(
                    enabledOnCreate: true,
                    enabledOnEdit: true,
                    enabledOnView: false,
                  ),
                  builder: (context, enabled) {
                    return Row(
                      children: [
                        Checkbox(
                          value: _activated,
                          onChanged: enabled
                              ? (value) {
                                  setState(() {
                                    _activated = value ?? false;
                                  });
                                }
                              : null,
                        ),
                        const SizedBox(width: 8),
                        const Text('Ativo'),
                      ],
                    );
                  },
                ),
              ],
              actions: AppFormActionsConfig(
                onCreate: () {
                  if (_formKey.currentState?.validate() != true) return;
                  final value = parseMoney(_valueCtrl.text.trim());
                  final name = _nameCtrl.text.trim();
                  final slugId = _selectedSlug?.id;
                  final activated = _activated;

                  try {
                    _service.saveNewModule(
                        token: _token,
                        name: name,
                        slugId: slugId!,
                        value: value,
                        activated: activated);
                  } on SessionExpiredException {
                    final auth = AuthScope.of(context);
                    auth.logout();
                    context.go('/login');
                    return;
                  }

                  context.go('/modules');
                },
                onEdit: () {
                  if (_formKey.currentState?.validate() != true) return;
                  final id = _idCtrl.text.trim();
                  final value = parseMoney(_valueCtrl.text.trim());
                  final name = _nameCtrl.text.trim();
                  final slugId = _selectedSlug?.id;
                  final activated = _activated;

                  try {
                    _service.updateNewModule(
                        token: _token,
                        id: id,
                        name: name,
                        slugId: slugId!,
                        value: value,
                        activated: activated);
                  } on SessionExpiredException {
                    final auth = AuthScope.of(context);
                    auth.logout();
                    context.go('/login');
                    return;
                  }

                  context.go('/modules/${id}/detail');
                },
                onCancel: () {
                  context.go('/modules');
                },
                onViewEdit: () {
                  context.go('/modules/${widget.moduleId!}/edit');
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
