import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:fldanplay/utils/log.dart';
import 'package:flutter/foundation.dart';
import 'package:forui/forui.dart';
import 'package:get_it/get_it.dart';
import 'package:material_ui/material_ui.dart';
import 'package:fldanplay/model/storage.dart';
import 'package:fldanplay/service/storage.dart';
import 'package:fldanplay/service/stream_media_explorer.dart';
import 'package:fldanplay/utils/android_saf.dart';
import 'package:fldanplay/utils/toast.dart';
import 'package:fldanplay/widget/sys_app_bar.dart';

enum _FieldType { text, toggle, select }

class _FieldConfig {
  final String key;
  final String label;
  final _FieldType type;
  final bool required;
  final bool obscureText;
  final TextInputType inputType;
  final String? Function(String?)? validator;
  final Map<String, String>? options;
  final Object? Function(Storage storage) read;
  final void Function(Storage storage, Object? value) write;

  const _FieldConfig._(
    this.key,
    this.label, {
    required this.type,
    required this.read,
    required this.write,
    this.required = false,
    this.obscureText = false,
    this.inputType = TextInputType.text,
    this.validator,
    this.options,
  });

  factory _FieldConfig.text(
    String key,
    String label, {
    required Object? Function(Storage) read,
    required void Function(Storage, String) write,
    bool required = false,
    bool obscureText = false,
    TextInputType inputType = TextInputType.text,
    String? Function(String?)? validator,
  }) => _FieldConfig._(
    key,
    label,
    type: .text,
    required: required,
    obscureText: obscureText,
    inputType: inputType,
    validator: validator,
    read: read,
    write: (storage, value) => write(storage, value as String? ?? ''),
  );

  factory _FieldConfig.toggle(
    String key,
    String label, {
    required bool Function(Storage) read,
    required void Function(Storage, bool) write,
  }) => _FieldConfig._(
    key,
    label,
    type: .toggle,
    read: read,
    write: (storage, value) => write(storage, value as bool? ?? false),
  );

  factory _FieldConfig.select(
    String key,
    String label, {
    required String Function(Storage) read,
    required void Function(Storage, String) write,
    required Map<String, String> options,
  }) => _FieldConfig._(
    key,
    label,
    type: .select,
    options: options,
    read: read,
    write: (storage, value) =>
        write(storage, value as String? ?? options.values.first),
  );
}

String? _required(String label, String? value) =>
    value?.trim().isEmpty ?? true ? '$label不能为空' : null;

String? _validateUrl(String? value) {
  if (value?.trim().isEmpty ?? true) return null;
  final uri = Uri.tryParse(value!.trim());
  return uri == null || !uri.hasScheme ? '请输入有效的URL' : null;
}

String? _validatePort(String? value) {
  if (value?.trim().isEmpty ?? true) return null;
  final port = int.tryParse(value!.trim());
  return port == null || port < 1 || port > 65535 ? '请输入有效的端口号(1-65535)' : null;
}

String? _validateHost(String? value, {required bool smb}) {
  if (value?.trim().isEmpty ?? true) return null;
  final host = value!.trim();
  final invalid = smb ? RegExp(r'[/\\@?#\s]') : RegExp(r'[/@?#\s]');
  if (invalid.hasMatch(host)) return '请输入主机名或IP地址';
  if (host.contains(':') &&
      InternetAddress.tryParse(host)?.type != InternetAddressType.IPv6) {
    return smb ? 'SMB不支持自定义端口' : '端口请填写在端口字段中';
  }
  return null;
}

String? _validateFtpHost(String? value) => _validateHost(value, smb: false);
String? _validateSmbHost(String? value) => _validateHost(value, smb: true);
String? _validateSmbShare(String? value) {
  if (value?.trim().isEmpty ?? true) return null;
  return RegExp(r'[/\\]').hasMatch(value!) ? '共享名不能包含路径分隔符' : null;
}

_FieldConfig _accountField() => _FieldConfig.text(
  'account',
  '用户名',
  read: (s) => s.account,
  write: (s, v) => s.account = v,
);
_FieldConfig _passwordField({required bool required}) => _FieldConfig.text(
  'password',
  '密码',
  required: required,
  obscureText: true,
  read: (s) => s.password,
  write: (s, v) => s.password = v,
);
_FieldConfig _mediaServerUrlField(String name) => _FieldConfig.text(
  'url',
  '$name服务器地址',
  required: true,
  validator: _validateUrl,
  read: (s) => s.url,
  write: (s, v) => s.url = v,
);
List<_FieldConfig> _getConfigs(StorageType type) => switch (type) {
  .webdav => [
    _FieldConfig.text(
      'url',
      'WebDAV地址',
      required: true,
      validator: _validateUrl,
      read: (s) => s.url,
      write: (s, v) => s.url = v,
    ),
    _accountField(),
    _passwordField(required: false),
    _FieldConfig.toggle(
      'isAnonymous',
      '匿名访问',
      read: (s) => s.isAnonymous ?? false,
      write: (s, v) => s.isAnonymous = v,
    ),
  ],
  .ftp => [
    _FieldConfig.text(
      'url',
      'FTP服务器',
      required: true,
      validator: _validateFtpHost,
      read: (s) => s.url,
      write: (s, v) => s.url = v,
    ),
    _FieldConfig.text(
      'port',
      '端口',
      inputType: TextInputType.number,
      validator: _validatePort,
      read: (s) => s.port?.toString(),
      write: (s, v) {
        final value = v.trim();
        s.port = value.isEmpty ? null : int.tryParse(value);
      },
    ),
    _FieldConfig.text(
      'account',
      '用户名',
      required: true,
      read: (s) => s.account,
      write: (s, v) => s.account = v,
    ),
    _passwordField(required: true),
    _FieldConfig.select(
      'ftpMode',
      'FTP模式',
      options: const {'主动模式': 'active', '被动模式': 'passive'},
      read: (s) => s.ftpMode ?? 'passive',
      write: (s, v) => s.ftpMode = v,
    ),
  ],
  .smb => [
    _FieldConfig.text(
      'url',
      'SMB主机',
      required: true,
      validator: _validateSmbHost,
      read: (s) => s.url,
      write: (s, v) => s.url = v,
    ),
    _FieldConfig.text(
      'share',
      '共享名',
      required: true,
      validator: _validateSmbShare,
      read: (s) => s.share,
      write: (s, v) => s.share = v,
    ),
    _accountField(),
    _passwordField(required: false),
  ],
  .local => [
    _FieldConfig.text(
      'url',
      '本地路径',
      required: true,
      read: (s) => s.url,
      write: (s, v) => s.url = v,
    ),
  ],
  .jellyfin || .emby => [
    _mediaServerUrlField(type == .jellyfin ? 'Jellyfin' : 'Emby'),
    _accountField(),
    _passwordField(required: true),
    _FieldConfig.toggle(
      'useRemoteHistory',
      '使用远程历史',
      read: (s) => s.useRemoteHistory ?? false,
      write: (s, v) => s.useRemoteHistory = v,
    ),
  ],
};

class _StorageFormData {
  final controllers = <String, TextEditingController>{};
  final values = <String, Object?>{};
  void init(List<_FieldConfig> fields, Storage storage) {
    dispose();
    for (final field in fields) {
      switch (field.type) {
        case .text:
          controllers[field.key] = TextEditingController(
            text: field.read(storage)?.toString() ?? '',
          );
        case .toggle || .select:
          values[field.key] = field.read(storage);
      }
    }
  }

  void save(Storage storage, List<_FieldConfig> fields) {
    for (final field in fields) {
      final value = switch (field.type) {
        .text => controllers[field.key]?.text.trim() ?? '',
        _ => values[field.key],
      };
      field.write(storage, value);
    }
  }

  String text(String key) => controllers[key]?.text.trim() ?? '';

  void dispose() {
    for (final controller in controllers.values) {
      controller.dispose();
    }
    controllers.clear();
    values.clear();
  }
}

class StorageEditPage extends StatefulWidget {
  final String? storageKey;
  final StorageType storageType;

  const StorageEditPage({
    super.key,
    this.storageKey,
    required this.storageType,
  });

  @override
  State<StorageEditPage> createState() => _StorageEditPageState();
}

class _StorageEditPageState extends State<StorageEditPage> {
  final _storageService = GetIt.I.get<StorageService>();
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _uniqueKeyController = TextEditingController();
  final _formData = _StorageFormData();
  late final List<_FieldConfig> _fields;
  var _storage = Storage.create();
  var _isLoading = false;

  @override
  void initState() {
    super.initState();
    _storage = switch (widget.storageKey) {
      final key? => _storageService.get(key) ?? _storage,
      _ => _storage,
    };
    _fields = _getConfigs(widget.storageType);
    _nameController.text = _storage.name;
    _uniqueKeyController.text = _storage.uniqueKey;
    _formData.init(_fields, _storage);
    if (widget.storageType == .ftp &&
        _formData.controllers['port']?.text.isEmpty == true) {
      _formData.controllers['port']!.text = '21';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _uniqueKeyController.dispose();
    _formData.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      if (widget.storageType == .jellyfin || widget.storageType == .emby) {
        await _loginToMediaServer();
      }
      _storage
        ..name = _nameController.text.trim()
        ..uniqueKey = _uniqueKeyController.text.trim()
        ..storageType = widget.storageType;
      _formData.save(_storage, _fields);
      await _storageService.update(_storage);
      showToast(title: '媒体库保存成功');
    } catch (e) {
      showToast(level: 3, title: '媒体库保存失败', description: e.toString());
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _loginToMediaServer() async {
    final url = _formData.text('url');
    final username = _formData.text('account');
    final password = _formData.text('password');
    if (url.isEmpty || username.isEmpty || password.isEmpty) {
      throw AppException('登录失败', '请填写完整的服务器地址、用户名和密码');
    }
    final tempStorage = _storage.copyWith(
      url: url,
      account: username,
      password: password,
      storageType: widget.storageType,
      token: '',
      userId: '',
    );
    final api = await createStreamMediaExplorerProvider(
      tempStorage,
      validateCredentials: false,
    );
    if (api == null) throw AppException('登录失败', '不支持的媒体库类型');
    final dio = await api.getDio(url, validateCredentials: false);
    final user = await api.login(dio, username, password);
    _storage
      ..token = user.token
      ..userId = user.userId;
  }

  Widget _field(_FieldConfig field) => switch (field.type) {
    .text => _textField(field),
    .toggle => _toggleField(field),
    .select => _selectField(field),
  };

  Widget _textField(_FieldConfig field) {
    final controller = _formData.controllers[field.key]!;
    String? validate(String? value) => field.required
        ? _required(field.label, value) ?? field.validator?.call(value)
        : field.validator?.call(value);
    final common = (
      control: FTextFieldControl.managed(controller: controller),
      label: Text(field.label),
      keyboardType: field.inputType,
      validator: validate,
    );
    final child = field.obscureText
        ? FTextFormField.password(
            control: common.control,
            label: common.label,
            keyboardType: common.keyboardType,
            validator: common.validator,
          )
        : FTextFormField(
            control: common.control,
            label: common.label,
            keyboardType: common.keyboardType,
            validator: common.validator,
          );
    return _padding(child);
  }

  Widget _toggleField(_FieldConfig field) {
    final value = _formData.values[field.key] as bool? ?? false;
    void update(bool value) {
      setState(() => _formData.values[field.key] = value);
    }

    return FItem(
      title: Text(field.label, style: context.theme.typography.body.md),
      suffix: Switch(value: value, onChanged: update),
      onPress: () => update(!value),
    );
  }

  Widget _selectField(_FieldConfig field) {
    final options = field.options!;
    final value =
        _formData.values[field.key] as String? ?? options.values.first;
    final label = options.entries
        .firstWhere((entry) => entry.value == value)
        .key;
    return _padding(
      FSelectMenuTile.fromMap(
        options,
        selectControl: .lifted(
          value: {value},
          onChange: (value) {
            setState(() => _formData.values[field.key] = value.last);
          },
        ),
        title: Text(field.label),
        details: Text(label),
      ),
    );
  }

  Widget _padding(Widget child) =>
      Padding(padding: .symmetric(horizontal: 12, vertical: 6), child: child);

  Future<void> _pickFolder() async {
    final path = defaultTargetPlatform == .android
        ? await AndroidSaf.pickDirectory(
            AndroidSaf.isTreeUri(_storage.url) ? _storage.url : null,
          )
        : await FilePicker.getDirectoryPath();
    if (path == null) return;
    _formData.controllers['url']!.text = path;
  }

  String? _validateKey(String? value) {
    final key = value?.trim() ?? '';
    if (key.isEmpty) return 'Key不能为空';
    if (_storageService.exists(key) && key != _storage.uniqueKey) {
      return 'Key已存在';
    }
    return RegExp(r'^[a-zA-Z0-9]+$').hasMatch(key) ? null : 'Key只允许字母和数字';
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Scaffold(
        appBar: SysAppBar(title: widget.storageType.label),
        body: ListView(
          children: [
            _padding(
              FTextFormField(
                control: .managed(controller: _nameController),
                label: const Text('名称'),
                autofocus: true,
                validator: (value) => _required('名称', value),
              ),
            ),
            _padding(
              FTextFormField(
                control: .managed(controller: _uniqueKeyController),
                label: const Text('Key'),
                readOnly: _storage.uniqueKey.isNotEmpty,
                hint: '用于标识，不可重复，只允许字母和数字',
                validator: _validateKey,
              ),
            ),
            ..._fields.map(_field),
            if (widget.storageType == .local)
              _padding(
                FButton(
                  size: .lg,
                  onPress: _pickFolder,
                  child: const Text('选择文件夹'),
                ),
              ),
            _padding(
              FButton(
                size: .lg,
                prefix: _isLoading ? const FCircularProgress() : null,
                onPress: _isLoading ? null : _save,
                child: const Text('保存'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
