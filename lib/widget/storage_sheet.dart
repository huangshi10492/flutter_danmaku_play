import 'package:fldanplay/model/storage.dart';
import 'package:fldanplay/model/stream_media.dart';
import 'package:fldanplay/service/stream_media_explorer.dart';
import 'package:fldanplay/utils/theme.dart';
import 'package:file_picker/file_picker.dart';
import 'package:fldanplay/utils/toast.dart';
import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:get_it/get_it.dart';
import 'package:fldanplay/service/storage.dart';
import 'package:go_router/go_router.dart';

enum _FieldType { text, toggle, select }

class _FieldConfig {
  final String key;
  final String label;
  final _FieldType type;
  final bool required;
  final bool obscureText;
  final TextInputType inputType;
  final String? Function(String)? validator;
  final Map<String, String>? options;
  final String? description;

  const _FieldConfig(
    this.key,
    this.label, {
    this.type = _FieldType.text,
    this.required = false,
    this.obscureText = false,
    this.inputType = TextInputType.text,
    this.validator,
    this.options,
    this.description,
  });
}

class SelectStorageTypeSheet extends StatelessWidget {
  const SelectStorageTypeSheet({super.key});

  void select(BuildContext context, StorageType storageType) {
    context.pop();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      enableDrag: false,
      builder: (context) {
        return AnimatedPadding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          duration: Duration.zero,
          child: EditStorageSheet(storageType: storageType),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: SafeArea(
        minimum: const EdgeInsets.all(8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('选择媒体库类型', style: context.theme.typography.lg),
            const SizedBox(height: 8),
            FItemGroup(
              style: settingsItemGroupStyle,
              children: [
                FItem(
                  title: const Text('WebDAV'),
                  prefix: const Icon(FIcons.hardDrive),
                  onPress: () => select(context, StorageType.webdav),
                ),
                // FItem(
                //   title: const Text('FTP'),
                //   prefix: const Icon(FIcons.serverCog),
                //   onPress: () => select(context, StorageType.ftp),
                // ),
                // FItem(
                //   title: const Text('SMB'),
                //   prefix: const Icon(FIcons.server),
                //   onPress: () => select(context, StorageType.smb),
                // ),
                FItem(
                  title: const Text('本地'),
                  prefix: const Icon(FIcons.smartphone),
                  onPress: () => select(context, StorageType.local),
                ),
                FItem(
                  title: const Text('Jellyfin'),
                  prefix: const Icon(FIcons.tv),
                  onPress: () => select(context, StorageType.jellyfin),
                ),
                FItem(
                  title: const Text('Emby'),
                  prefix: const Icon(FIcons.tv),
                  onPress: () => select(context, StorageType.emby),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StorageFormData {
  final Map<String, TextEditingController> controllers = {};
  final Map<String, bool> toggleValues = {};
  final Map<String, String> selectValues = {};

  void initialize(List<_FieldConfig> configs) {
    dispose();
    for (final field in configs) {
      switch (field.type) {
        case _FieldType.text:
          controllers[field.key] = TextEditingController();
          break;
        case _FieldType.toggle:
          toggleValues[field.key] = false;
          break;
        case _FieldType.select:
          selectValues[field.key] = field.options?.values.first ?? '';
          break;
      }
    }
  }

  void loadFromStorage(Storage storage, List<_FieldConfig> configs) {
    for (final field in configs) {
      switch (field.type) {
        case _FieldType.text:
          final controller = controllers[field.key];
          if (controller != null) {
            switch (field.key) {
              case 'url':
                controller.text = storage.url;
                break;
              case 'port':
                controller.text = storage.port?.toString() ?? '';
                break;
              case 'account':
                controller.text = storage.account ?? '';
                break;
              case 'password':
                controller.text = storage.password ?? '';
                break;
            }
          }
          break;
        case _FieldType.toggle:
          switch (field.key) {
            case 'isAnonymous':
              toggleValues[field.key] = storage.isAnonymous ?? false;
              break;
          }
          break;
        case _FieldType.select:
          switch (field.key) {
            case 'ftpMode':
            case 'smbVersion':
              selectValues[field.key] = field.options!.values.first;
              break;
          }
          break;
      }
    }
  }

  void saveToStorage(Storage storage, List<_FieldConfig> configs) {
    for (final field in configs) {
      switch (field.type) {
        case _FieldType.text:
          final controller = controllers[field.key];
          if (controller != null) {
            final value = controller.text.trim();
            switch (field.key) {
              case 'url':
                storage.url = value;
                break;
              case 'port':
                storage.port = value.isEmpty ? null : int.tryParse(value);
                break;
              case 'account':
                storage.account = value.isEmpty ? null : value;
                break;
              case 'password':
                storage.password = value.isEmpty ? null : value;
                break;
            }
          }
          break;
        case _FieldType.toggle:
          final value = toggleValues[field.key] ?? false;
          switch (field.key) {
            case 'isAnonymous':
              storage.isAnonymous = value;
              break;
          }
          break;
        case _FieldType.select:
          switch (field.key) {
            case 'ftpMode':
              selectValues[field.key] =
                  // _storage.ftpMode ??
                  field.options!.values.first;
              break;
            case 'smbVersion':
              selectValues[field.key] =
                  // _storage.smbVersion ??
                  field.options!.values.first;
              break;
          }
          break;
      }
    }
  }

  void dispose() {
    for (final controller in controllers.values) {
      controller.dispose();
    }
    controllers.clear();
    toggleValues.clear();
    selectValues.clear();
  }
}

List<_FieldConfig> _getConfigs(StorageType type) {
  String? validateUrl(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null;
    }
    final uri = Uri.tryParse(value.trim());
    if (uri == null || !uri.hasScheme) {
      return '请输入有效的URL';
    }
    return null;
  }

  String? validatePort(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null;
    }
    final port = int.tryParse(value.trim());
    if (port == null || port < 1 || port > 65535) {
      return '请输入有效的端口号(1-65535)';
    }
    return null;
  }

  switch (type) {
    case StorageType.webdav:
      return [
        _FieldConfig('url', 'WebDAV地址', required: true, validator: validateUrl),
        _FieldConfig('account', '用户名'),
        _FieldConfig('password', '密码', obscureText: true),
        _FieldConfig(
          'isAnonymous',
          '匿名访问',
          type: _FieldType.toggle,
          description: '启用后将不需要用户名和密码',
        ),
      ];
    case StorageType.ftp:
      return [
        _FieldConfig('url', 'FTP服务器', required: true),
        _FieldConfig(
          'port',
          '端口',
          inputType: TextInputType.number,
          validator: validatePort,
        ),
        _FieldConfig('account', '用户名', required: true),
        _FieldConfig('password', '密码', required: true, obscureText: true),
        _FieldConfig(
          'ftpMode',
          'FTP模式',
          type: _FieldType.select,
          options: {'主动模式': 'active', '被动模式': 'passive'},
          description: '选择FTP连接模式',
        ),
      ];
    case StorageType.smb:
      return [
        _FieldConfig('url', 'SMB地址', required: true),
        _FieldConfig('account', '用户名', required: true),
        _FieldConfig('password', '密码', required: true, obscureText: true),
        _FieldConfig(
          'smbVersion',
          'SMB版本',
          type: _FieldType.select,
          options: {'SMB1': '1', 'SMB2': '2', 'SMB3': '3'},
          description: '选择SMB协议版本',
        ),
      ];
    case StorageType.local:
      return [_FieldConfig('url', '本地路径', required: true)];
    case StorageType.jellyfin:
      return [
        _FieldConfig(
          'url',
          'Jellyfin服务器地址',
          required: true,
          validator: validateUrl,
          description: '例如: http://192.168.1.100:8096',
        ),
        _FieldConfig('account', '用户名', required: true),
        _FieldConfig('password', '密码', required: true, obscureText: true),
      ];
    case StorageType.emby:
      return [
        _FieldConfig(
          'url',
          'Emby服务器地址',
          required: true,
          validator: validateUrl,
          description: '例如: http://192.168.1.100:8096',
        ),
        _FieldConfig('account', '用户名', required: true),
        _FieldConfig('password', '密码', required: true, obscureText: true),
      ];
  }
}

class EditStorageSheet extends StatefulWidget {
  final String? storageKey;
  final StorageType storageType;

  const EditStorageSheet({
    super.key,
    this.storageKey,
    required this.storageType,
  });

  @override
  State<EditStorageSheet> createState() => _EditStorageSheetState();
}

class _EditStorageSheetState extends State<EditStorageSheet> {
  final _storageService = GetIt.I.get<StorageService>();
  final _formKey = GlobalKey<FormState>();

  late final _StorageFormData _formData;
  late final List<_FieldConfig> _fieldConfigs;
  late final TextEditingController _nameController;
  late final TextEditingController _uniqueKeyController;

  var _storage = Storage.create();
  bool _isLoading = false;

  List<CollectionItem> _mediaServerLibraries = [];
  String? _selectedLibraryId;
  bool _isMediaServerLoggedIn = false;
  String get _title {
    switch (widget.storageType) {
      case StorageType.webdav:
        return 'WebDAV媒体库';
      case StorageType.ftp:
        return 'FTP媒体库';
      case StorageType.smb:
        return 'SMB媒体库';
      case StorageType.local:
        return '本地媒体库';
      case StorageType.jellyfin:
        return 'Jellyfin媒体库';
      case StorageType.emby:
        return 'Emby媒体库';
    }
  }

  @override
  void initState() {
    super.initState();
    _fieldConfigs = _getConfigs(widget.storageType);
    _formData = _StorageFormData();
    _formData.initialize(_fieldConfigs);
    _loadStorage();
  }

  Future<void> _loadStorage() async {
    if (widget.storageKey != null) {
      final result = _storageService.get(widget.storageKey!);
      if (result != null) {
        _storage = result;
      }
    }
    setState(() {
      _nameController = TextEditingController(text: _storage.name);
      _uniqueKeyController = TextEditingController(text: _storage.uniqueKey);
      _formData.loadFromStorage(_storage, _fieldConfigs);
    });
  }

  @override
  void dispose() {
    _formData.dispose();
    super.dispose();
  }

  Future<bool> _saveStorage(BuildContext context) async {
    if (!_formKey.currentState!.validate()) {
      return false;
    }
    setState(() => _isLoading = true);
    try {
      _storage.name = _nameController.text.trim();
      _storage.uniqueKey = _uniqueKeyController.text.trim();
      _storage.storageType = widget.storageType;
      _formData.saveToStorage(_storage, _fieldConfigs);
      if (widget.storageType == StorageType.jellyfin ||
          widget.storageType == StorageType.emby) {
        if (_selectedLibraryId == null) {
          if (context.mounted) {
            showToast(context, level: 2, title: '请选择媒体库');
          }
          return false;
        }
        _storage.mediaLibraryId = _selectedLibraryId;
      }
      await _storageService.update(_storage);
      if (context.mounted) {
        showToast(context, title: '媒体库保存成功');
        for (final controller in _formData.controllers.values) {
          controller.clear();
        }
      }
      return true;
    } catch (e) {
      if (context.mounted) {
        showToast(
          context,
          level: 3,
          title: '媒体库保存失败',
          description: e.toString(),
        );
      }
      return false;
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _loginToMediaServer() async {
    if (widget.storageType != StorageType.jellyfin &&
        widget.storageType != StorageType.emby) {
      return;
    }
    final url = _formData.controllers['url']?.text.trim();
    final username = _formData.controllers['account']?.text.trim();
    final password = _formData.controllers['password']?.text.trim();
    if (url == null ||
        url.isEmpty ||
        username == null ||
        username.isEmpty ||
        password == null ||
        password.isEmpty) {
      if (mounted) {
        showToast(context, level: 2, title: '请填写完整的服务器地址、用户名和密码');
      }
      return;
    }
    setState(() => _isLoading = true);
    try {
      StreamMediaExplorerProvider apiUtils;
      if (widget.storageType == StorageType.jellyfin) {
        apiUtils = JellyfinStreamMediaExplorerProvider(
          url,
          UserInfo(userId: '', token: ''),
        );
      } else {
        apiUtils = EmbyStreamMediaExplorerProvider(
          url,
          UserInfo(userId: '', token: ''),
        );
      }
      final dio = apiUtils.getDio(url);
      final userInfo = await apiUtils.login(dio, username, password);
      if (widget.storageType == StorageType.jellyfin) {
        apiUtils = JellyfinStreamMediaExplorerProvider(url, userInfo);
      } else {
        apiUtils = EmbyStreamMediaExplorerProvider(url, userInfo);
      }
      final libraries = await apiUtils.getUserViews();
      setState(() {
        _storage.token = userInfo.token;
        _storage.userId = userInfo.userId;
        _mediaServerLibraries = libraries;
        _isMediaServerLoggedIn = true;
      });
      if (mounted) {
        showToast(context, title: '登录成功！请选择媒体库');
      }
    } catch (e) {
      if (mounted) {
        showToast(context, level: 3, title: '登录失败', description: e.toString());
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Widget _buildFieldWidget(_FieldConfig field) {
    switch (field.type) {
      case _FieldType.text:
        final controller = _formData.controllers[field.key]!;
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          child:
              field.obscureText
                  ? FTextFormField.password(
                    label: Text(field.label),
                    controller: controller,
                    keyboardType: field.inputType,
                    validator: (value) {
                      if (field.required &&
                          (value == null || value.trim().isEmpty)) {
                        return '${field.label}不能为空';
                      }
                      if (field.validator != null) {
                        return field.validator!(value!);
                      }
                      return null;
                    },
                  )
                  : FTextFormField(
                    label: Text(field.label),
                    controller: controller,
                    keyboardType: field.inputType,
                    validator: (value) {
                      if (field.required &&
                          (value == null || value.trim().isEmpty)) {
                        return '${field.label}不能为空';
                      }
                      if (field.validator != null) {
                        return field.validator!(value!);
                      }
                      return null;
                    },
                  ),
        );
      case _FieldType.toggle:
        return FItem(
          title: Text(
            field.label,
            style: context.theme.typography.base.copyWith(
              color: context.theme.colors.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
          suffix: Switch(
            value: _formData.toggleValues[field.key] ?? false,
            onChanged: (value) {
              setState(() {
                _formData.toggleValues[field.key] = value;
              });
            },
          ),
          onPress: () {
            setState(() {
              _formData.toggleValues[field.key] =
                  !(_formData.toggleValues[field.key] ?? false);
            });
          },
        );
      case _FieldType.select:
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          child: FSelectMenuTile.fromMap(
            field.options!,
            title: Text(field.label),
            initialValue: _formData.selectValues[field.key],
            details: Text(
              field.options!.entries
                  .firstWhere(
                    (e) => e.value == _formData.selectValues[field.key],
                  )
                  .key,
            ),
            onChange: (value) {
              setState(() {
                _formData.selectValues[field.key] = value.first;
              });
            },
          ),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        child: SafeArea(
          minimum: EdgeInsets.only(bottom: 8),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    FButton(
                      style: FButtonStyle.ghost(),
                      onPress: () => Navigator.of(context).pop(),
                      child: const Text('取消'),
                    ),
                    Expanded(
                      child: Text(
                        _title,
                        textAlign: TextAlign.center,
                        style: context.theme.typography.lg.copyWith(
                          color: context.theme.colors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    FButton(
                      onPress:
                          _isLoading
                              ? null
                              : () async {
                                final result = await _saveStorage(context);
                                if (context.mounted) {
                                  if (result) {
                                    Navigator.of(context).pop(result);
                                  }
                                }
                              },
                      child:
                          _isLoading
                              ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                              : const Text('保存'),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                child: FTextFormField(
                  label: Text('名称'),
                  controller: _nameController,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return '名称不能为空';
                    }
                    return null;
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                child: FTextFormField(
                  label: Text('Key'),
                  controller: _uniqueKeyController,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Key不能为空';
                    }
                    if (_storageService.exists(value) &&
                        value != _storage.uniqueKey) {
                      return 'Key已存在';
                    }
                    return null;
                  },
                ),
              ),
              ..._fieldConfigs.map((field) {
                return _buildFieldWidget(field);
              }),
              if (widget.storageType == StorageType.local) ...[
                Padding(
                  padding: const EdgeInsets.only(
                    top: 6,
                    bottom: 6,
                    left: 12,
                    right: 12,
                  ),
                  child: FButton(
                    onPress: () async {
                      final path = await FilePicker.platform.getDirectoryPath();
                      if (path != null) {
                        setState(() {
                          _formData.controllers['url']!.text = path;
                        });
                      }
                    },
                    child: Text('选择文件夹'),
                  ),
                ),
              ],
              if (widget.storageType == StorageType.jellyfin ||
                  widget.storageType == StorageType.emby) ...[
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  child: FButton(
                    style:
                        _isMediaServerLoggedIn
                            ? FButtonStyle.secondary()
                            : FButtonStyle.primary(),
                    onPress: _isLoading ? null : _loginToMediaServer,
                    child: Text(_isMediaServerLoggedIn ? '已登录' : '登录并获取媒体库'),
                  ),
                ),
                if (_isMediaServerLoggedIn && _mediaServerLibraries.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    child: FSelectMenuTile.fromMap(
                      Map.fromEntries(
                        _mediaServerLibraries.map(
                          (lib) => MapEntry(lib.name, lib.id),
                        ),
                      ),
                      title: const Text('选择媒体库'),
                      initialValue: _selectedLibraryId,
                      details: Text(
                        _selectedLibraryId != null
                            ? _mediaServerLibraries
                                .firstWhere(
                                  (lib) => lib.id == _selectedLibraryId,
                                )
                                .name
                            : '请选择媒体库',
                      ),
                      onChange: (value) {
                        setState(() {
                          _selectedLibraryId = value.first;
                        });
                      },
                    ),
                  ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
