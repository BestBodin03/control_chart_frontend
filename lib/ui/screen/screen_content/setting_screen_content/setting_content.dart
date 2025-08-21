import 'package:control_chart/ui/core/design_system/app_color.dart';
import 'package:flutter/material.dart';

// ----------------------------------------------------
// Models & Seed Data
// ----------------------------------------------------

class Profile {
  final String id;
  final String name;
  final String summary;
  final DateTime createdAt;
  bool active;

  Profile({
    required this.id,
    required this.name,
    required this.summary,
    required this.createdAt,
    required this.active,
  });
}

enum StatusFilter { all, active, inactive }
enum SortBy { name, date }
enum _TabKey { profiles, importData }

final List<Profile> _seedProfiles = List.generate(12, (i) {
  return Profile(
    id: 'p-${i + 1}',
    name: 'โปรไฟล์ที่ ${i + 1}',
    summary:
        'คำอธิบายสั้นๆ เกี่ยวกับการตั้งค่าของโปรไฟล์นี้ เพื่อช่วยให้สแกนได้เร็วขึ้นและแยกความต่างระหว่างการ์ด',
    active: i % 3 != 0,
    createdAt: DateTime.now().subtract(Duration(days: i)),
  );
});

// ----------------------------------------------------
// Root Widget (No Scaffold)
// ----------------------------------------------------

class SettingContent extends StatefulWidget {
  const SettingContent({super.key});

  @override
  State<SettingContent> createState() => _SettingContentState();
}

class _SettingContentState extends State<SettingContent> {
  _TabKey _tab = _TabKey.profiles;

  // Profiles state
  List<Profile> _items = List.of(_seedProfiles);
  String _query = '';
  StatusFilter _status = StatusFilter.all;
  SortBy _sortBy = SortBy.name;

  // Import state
  String? _fileName;
  String _dropdown1 = '';
  String _dropdown2 = '';

  void _addProfile() {
    final nextIndex = _items.length + 1;
    setState(() {
      _items.insert(
        0,
        Profile(
          id: 'p-$nextIndex',
          name: 'โปรไฟล์ที่ $nextIndex',
          summary:
              'โปรไฟล์ที่สร้างใหม่เพื่อสาธิตการเพิ่มรายการแบบรวดเร็ว',
          createdAt: DateTime.now(),
          active: true,
        ),
      );
    });
  }

  List<Profile> get _filteredProfiles {
    final q = _query.trim().toLowerCase();
    List<Profile> out = _items.where((p) {
      final matchQuery = q.isEmpty || p.name.toLowerCase().contains(q);
      final matchStatus = switch (_status) {
        StatusFilter.all => true,
        StatusFilter.active => p.active,
        StatusFilter.inactive => !p.active,
      };
      return matchQuery && matchStatus;
    }).toList();

    out.sort((a, b) {
      if (_sortBy == SortBy.name) {
        return a.name.compareTo(b.name);
      } else {
        return b.createdAt.compareTo(a.createdAt);
      }
    });
    return out;
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFF1F5F9), Color(0xFFF8FAFC)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          children: [
            // Top bar (no Scaffold)
            _TopBar(
              tab: _tab,
              onSelect: (t) => setState(() => _tab = t),
            ),

            // Main body
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(32,32,32,32),
                child: switch (_tab) {
                  _TabKey.profiles => _ProfilesPage(
                      items: _filteredProfiles,
                      onToggleActive: (id, v) {
                        setState(() {
                          final idx = _items.indexWhere((e) => e.id == id);
                          if (idx != -1) _items[idx].active = v;
                        });
                      },
                      // left side button
                      onAddProfile: _addProfile,
                      // right side controls
                      query: _query,
                      onQueryChanged: (v) => setState(() => _query = v),
                      status: _status,
                      onStatusChanged: (v) => setState(() => _status = v),
                      sortBy: _sortBy,
                      onSortChanged: (v) => setState(() => _sortBy = v),
                    ),
                  _TabKey.importData => _ImportPage(
                      fileName: _fileName,
                      onPickFile: () {
                        // ตัวอย่าง: จำลองการเลือกไฟล์
                        setState(() => _fileName = 'sample-data.csv (ตัวอย่าง)');
                      },
                      dropdown1: _dropdown1,
                      onDropdown1: (v) => setState(() => _dropdown1 = v),
                      dropdown2: _dropdown2,
                      onDropdown2: (v) => setState(() => _dropdown2 = v),
                    ),
                },
              ),
            ),

            // Footer
            Padding(
              padding: const EdgeInsets.only(left: 16, right: 16, bottom: 28),
              child: Text(
                'เคล็ดลับ: หน้านี้สาธิตองค์ประกอบสำคัญที่แนะนำ เช่น การค้นหา/กรอง, Empty State ที่อธิบายชัด, สีสถานะของสวิตช์',
                style: Theme.of(context)
                    .textTheme
                    .labelSmall
                    ?.copyWith(color: const Color(0xFF64748B)),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ----------------------------------------------------
// Top Bar with 2 Tabs (No Scaffold)
// ----------------------------------------------------

class _TopBar extends StatelessWidget {
  const _TopBar({required this.tab, required this.onSelect});

  final _TabKey tab;
  final ValueChanged<_TabKey> onSelect;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(color: AppColors.colorBgGrey, boxShadow: [
        BoxShadow(
          color: Color(0x14000000),
          blurRadius: 8,
          offset: Offset(0, 2),
        )
      ]),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16,0,32,16),
            child: Row(
              children: [
                _Pill(
                  label: 'โปรไฟล์ตั้งค่า',
                  leading: Icons.dashboard_customize,
                  selected: tab == _TabKey.profiles,
                  onTap: () => onSelect(_TabKey.profiles),
                ),
                const SizedBox(width: 8),
                _Pill(
                  label: 'นำเข้าข้อมูล',
                  leading: Icons.data_saver_on_rounded,
                  selected: tab == _TabKey.importData,
                  onTap: () => onSelect(_TabKey.importData),
                ),
              ],
            ),
        ),
      );
  }
}

// ----------------------------------------------------
// Profiles Page
// ----------------------------------------------------

class _ProfilesPage extends StatelessWidget {
  const _ProfilesPage({
    required this.items,
    required this.onToggleActive,
    required this.onAddProfile,
    required this.query,
    required this.onQueryChanged,
    required this.status,
    required this.onStatusChanged,
    required this.sortBy,
    required this.onSortChanged,
  });

  final List<Profile> items;
  final void Function(String id, bool v) onToggleActive;

  // Left button
  final VoidCallback onAddProfile;

  // Right controls
  final String query;
  final ValueChanged<String> onQueryChanged;
  final StatusFilter status;
  final ValueChanged<StatusFilter> onStatusChanged;
  final SortBy sortBy;
  final ValueChanged<SortBy> onSortChanged;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (ctx, c) {
      int cols = 1;
      if (c.maxWidth >= 1280) {
        cols = 4;
      } else if (c.maxWidth >= 1024) {
        cols = 3;
      } else if (c.maxWidth >= 768) {
        cols = 2;
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Toolbar: left button + right controls
          Row(
            children: [
              _Pill(
                label: 'เพิ่มโปรไฟล์',
                leading: Icons.add,
                selected: true,
                onTap: onAddProfile,
                solid: true,
              ),
              const Spacer(),
              // Right controls: search, status, sort
              _SearchBox(
                value: query,
                hintText: 'ค้นหาโปรไฟล์...',
                onChanged: onQueryChanged,
              ),
              const SizedBox(width: 8),
              _SelectBox<StatusFilter>(
                value: status,
                items: const {
                  StatusFilter.all: 'สถานะ: ทั้งหมด',
                  StatusFilter.active: 'เฉพาะที่เปิดอยู่',
                  StatusFilter.inactive: 'เฉพาะที่ปิดอยู่',
                },
                onChanged: (v) {
                  if (v != null) onStatusChanged(v);
                },
              ),
              const SizedBox(width: 8),
              _SelectBox<SortBy>(
                value: sortBy,
                items: const {
                  SortBy.name: 'เรียงตามชื่อ',
                  SortBy.date: 'เรียงตามวันที่สร้าง',
                },
                onChanged: (v) {
                  if (v != null) onSortChanged(v);
                },
              ),
            ],
          ),
          const SizedBox(height: 16),

          if (items.isEmpty)
            const _EmptyState(
              title: 'ไม่พบโปรไฟล์ที่ตรงกับเงื่อนไข',
              description: 'ลองล้างตัวกรองหรือเปลี่ยนคำค้นหา แล้วลองใหม่อีกครั้ง',
            )
          else
            Expanded(
              child: GridView.builder(
                padding: EdgeInsets.zero,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: cols,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.1,
                ),
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final p = items[index];
                  return _ProfileCard(
                    profile: p,
                    onToggle: (v) => onToggleActive(p.id, v),
                  );
                },
              ),
            ),
        ],
      );
    });
  }
}

class _ProfileCard extends StatelessWidget {
  const _ProfileCard({required this.profile, required this.onToggle});

  final Profile profile;
  final ValueChanged<bool> onToggle;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: AppColors.colorBg,
          // border: Border.all(color: AppColors.colorBrand),
          boxShadow: const [
            BoxShadow(
              color: AppColors.colorBrandTp,
              blurRadius: 10,
              offset: Offset(0, 4),
            )
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              Row(
                children: [
                   Column(
                      children: [
                        Expanded(
                          child: 
                            Row(
                              children: [
                                // Name on the left
                                
                                  Text(
                                    profile.name,
                                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                                          fontWeight: FontWeight.w700,
                                          color: const Color(0xFF0F172A),
                                        ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                
                            
                                const SizedBox(width: 8),
                            
                                // Icon group as a blue pill, also on the left
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: DecoratedBox(
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF1D4ED8),           // blue pill background
                                      border: Border.all(color: const Color(0xFF1D4ED8)),
                                      boxShadow: const [
                                        BoxShadow(
                                          color: Color(0x14000000),
                                          blurRadius: 6,
                                          offset: Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: Row(
                                      children: [
                                        _IconButton(
                                          icon: Icons.edit_outlined,
                                          tooltip: 'แก้ไข',
                                          onTap: () {},
                                          iconColor: Colors.white,               // white inside blue pill
                                          backgroundColor: Colors.transparent,   // keep the pill as the only bg
                                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                        ),
                                        _IconButton(
                                          icon: Icons.info_outline,
                                          tooltip: 'ข้อมูล',
                                          onTap: () {},
                                          iconColor: Colors.white,
                                          backgroundColor: Colors.transparent,
                                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                        ),
                                        _IconButton(
                                          icon: Icons.cancel,
                                          tooltip: 'ลบ',
                                          onTap: () {},
                                          iconColor: AppColors.colorAlert1,
                                          backgroundColor: Colors.transparent,
                                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                        ),

                        const SizedBox(height: 6),
                        _Badge(
                          text: profile.active ? 'เปิดใช้งาน' : 'ปิดอยู่',
                          color: profile.active
                              ? const Color(0xFFD1FAE5)
                              : const Color(0xFFFEE2E2),
                          textColor: profile.active
                              ? const Color(0xFF047857)
                              : const Color(0xFFB91C1C),
                          ringColor: profile.active
                              ? const Color(0xFFA7F3D0)
                              : const Color(0xFFFECACA),
                        ),
                      ],
                    ),
                  
                  const SizedBox(width: 8),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                profile.summary,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: const Color(0xFF475569),
                      height: 1.45,
                    ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(width: 32),
              Row(
                children: [
                  Text(
                    'สร้างเมื่อ ${_fmtDate(profile.createdAt)}',
                    style: Theme.of(context)
                        .textTheme
                        .labelSmall
                        ?.copyWith(color: const Color(0xFF64748B)),
                  ),
                  const Spacer(),

                  Switch(
                    value: profile.active,
                    activeColor: Colors.white,
                    activeTrackColor: const Color(0xFF2563EB),
                    inactiveThumbColor: Colors.white,
                    inactiveTrackColor: const Color(0xFFE2E8F0),
                    onChanged: onToggle,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ----------------------------------------------------
// Import Page
// ----------------------------------------------------

class _ImportPage extends StatelessWidget {
  const _ImportPage({
    required this.fileName,
    required this.onPickFile,
    required this.dropdown1,
    required this.onDropdown1,
    required this.dropdown2,
    required this.onDropdown2,
  });

  final String? fileName;
  final VoidCallback onPickFile;
  final String dropdown1;
  final ValueChanged<String> onDropdown1;
  final String dropdown2;
  final ValueChanged<String> onDropdown2;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, c) {
      final isNarrow = c.maxWidth < 960;
      final leftW = isNarrow ? c.maxWidth : c.maxWidth * 0.28;
      final rightW = isNarrow ? c.maxWidth : c.maxWidth * 0.68;

      return SingleChildScrollView(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Left sidebar
            SizedBox(
              width: leftW,
              child: _CardBox(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _RowIconTitle(
                      icon: Icons.file_upload_outlined,
                      title: 'ขั้นตอนนำเข้าข้อมูล',
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'เลือกไฟล์สำหรับนำเข้า',
                      style: Theme.of(context)
                          .textTheme
                          .labelSmall
                          ?.copyWith(fontWeight: FontWeight.w600, color: const Color(0xFF475569)),
                    ),
                    const SizedBox(height: 8),
                    _OutlineButton(
                      label: fileName ?? 'เลือกไฟล์…',
                      onTap: onPickFile,
                      icon: Icons.attach_file,
                    ),
                    const SizedBox(height: 14),
                    _LabeledDropdown(
                      label: 'Dropdown 1',
                      value: dropdown1.isEmpty ? null : dropdown1,
                      items: const ['ประเภท A', 'ประเภท B', 'ประเภท C'],
                      onChanged: (v) => onDropdown1(v ?? ''),
                    ),
                    const SizedBox(height: 14),
                    _LabeledDropdown(
                      label: 'Dropdown 2',
                      value: dropdown2.isEmpty ? null : dropdown2,
                      items: const ['แมปคอลัมน์ 1', 'แมปคอลัมน์ 2', 'แมปคอลัมน์ 3'],
                      onChanged: (v) => onDropdown2(v ?? ''),
                    ),
                    const SizedBox(height: 16),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: _Pill(
                        label: 'โหลดข้อมูล',
                        solid: true,
                        selected: true,
                        onTap: () {},
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'เคล็ดลับ: เมื่อเลือกไฟล์แล้ว พรีวิวจะแสดงทางด้านขวา',
                      style: Theme.of(context)
                          .textTheme
                          .labelSmall
                          ?.copyWith(color: const Color(0xFF64748B)),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 16),

            // Right preview area
            SizedBox(
              width: rightW,
              child: _CardBox(
                padding: const EdgeInsets.all(16),
                child: fileName == null
                    ? const _EmptyState(
                        title: 'ยังไม่มีไฟล์สำหรับพรีวิว',
                        description:
                            'อัปโหลดไฟล์ด้านซ้าย จากนั้นระบบจะแสดงตัวอย่างข้อมูลเพื่อยืนยันการแมป',
                        extra: 'รองรับ CSV, XLSX',
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                            children: [
                              Text(
                                'พรีวิวข้อมูล: $fileName',
                                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                                      fontWeight: FontWeight.w600,
                                      color: const Color(0xFF0F172A),
                                    ),
                              ),
                              const Spacer(),
                              _Badge(
                                text: 'พร้อมนำเข้า',
                                color: const Color(0xFFDBEAFE),
                                textColor: const Color(0xFF1D4ED8),
                                ringColor: const Color(0xFFBFDBFE),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                border: Border.all(color: const Color(0xFFE2E8F0)),
                                color: Colors.white,
                              ),
                              child: _PreviewTable(rows: 6, cols: 5),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              _Pill(
                                label: 'ตรวจสอบ',
                                onTap: () {},
                                selected: true,
                              ),
                              const SizedBox(width: 8),
                              _Pill(
                                label: 'ยืนยันนำเข้า',
                                onTap: () {},
                                solid: true,
                                selected: true,
                              ),
                            ],
                          ),
                        ],
                      ),
              ),
            ),
          ],
        ),
      );
    });
  }
}

// ----------------------------------------------------
// Small Building Blocks (no Container)
// ----------------------------------------------------

class _Pill extends StatelessWidget {
  const _Pill({
    required this.label,
    required this.onTap,
    this.selected = false,
    this.solid = false,
    this.leading,
  });

  final String label;
  final VoidCallback onTap;
  final bool selected;
  final bool solid;
  final IconData? leading;

  @override
  Widget build(BuildContext context) {
    final bg = solid
        ? (selected ? const Color(0xFF2563EB) : const Color(0xFFEFF6FF))
        : const Color(0xFFEFF6FF);
    final fg = solid
        ? Colors.white
        : (selected ? const Color(0xFF1D4ED8) : const Color(0xFF1D4ED8));
    final ring = solid ? Colors.transparent : const Color(0xFFBFDBFE);

    return GestureDetector(
      onTap: onTap,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: ring),
          boxShadow: solid
              ? const [
                  BoxShadow(
                    color: Color(0x14000000),
                    blurRadius: 6,
                    offset: Offset(0, 2),
                  )
                ]
              : null,
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          child: Row(
            children: [
              if (leading != null) ...[
                Icon(leading, size: 16, color: fg),
                const SizedBox(width: 6),
              ],
              Text(
                label,
                style: Theme.of(context)
                    .textTheme
                    .labelMedium
                    ?.copyWith(fontWeight: FontWeight.w600, color: fg),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({
    required this.text,
    required this.color,
    required this.textColor,
    required this.ringColor,
  });

  final String text;
  final Color color;
  final Color textColor;
  final Color ringColor;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: ringColor),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        child: Text(
          text,
          style: Theme.of(context)
              .textTheme
              .labelSmall
              ?.copyWith(fontWeight: FontWeight.w600, color: textColor),
        ),
      ),
    );
  }
}

class _IconButton extends StatelessWidget {
  const _IconButton({
    required this.icon,
    required this.tooltip,
    required this.onTap,
    this.size = 18.0,
    this.iconColor = const Color(0xFF334155), // slate-700ish
    this.backgroundColor = Colors.transparent,
    this.padding = const EdgeInsets.all(6),
    this.borderRadius = 10,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;

  final double size;
  final Color iconColor;
  final Color backgroundColor;
  final EdgeInsets padding;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(borderRadius),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(borderRadius),
            ),
            child: Padding(
              padding: padding,
              child: Icon(icon, size: size, color: iconColor),
            ),
          ),
        ),
      ),
    );
  }
}


class _SearchBox extends StatelessWidget {
  const _SearchBox({required this.value, required this.onChanged, required this.hintText});

  final String value;
  final ValueChanged<String> onChanged;
  final String hintText;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 220,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Row(
              children: [
                const Icon(Icons.search, size: 16, color: Color(0xFF64748B)),
                const SizedBox(width: 6),
                Expanded(
                  child: TextField(
                    controller: TextEditingController(text: value)
                      ..selection = TextSelection.collapsed(offset: value.length),
                    onChanged: onChanged,
                    decoration: InputDecoration(
                      hintText: hintText,
                      border: InputBorder.none,
                      isCollapsed: true,
                    ),
                    style: Theme.of(context).textTheme.labelMedium,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SelectBox<T> extends StatelessWidget {
  const _SelectBox({
    required this.value,
    required this.items,
    required this.onChanged,
  });

  final T value;
  final Map<T, String> items;
  final ValueChanged<T?> onChanged;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 190,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: DropdownButton<T>(
              isExpanded: true,
              value: value,
              underline: const SizedBox.shrink(),
              icon: const Icon(Icons.expand_more),
              items: items.entries
                  .map(
                    (e) => DropdownMenuItem<T>(
                      value: e.key,
                      child: Text(
                        e.value,
                        style: Theme.of(context).textTheme.labelMedium,
                      ),
                    ),
                  )
                  .toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({
    required this.title,
    required this.description,
    this.extra,
  });

  final String title;
  final String description;
  final String? extra;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: SizedBox(
        width: 560,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(.8),
              border: Border.all(color: const Color(0xFFCBD5E1), style: BorderStyle.solid),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.auto_awesome, size: 36, color: Colors.grey.shade500),
                  const SizedBox(height: 10),
                  Text(
                    title,
                    style: Theme.of(context)
                        .textTheme
                        .titleSmall
                        ?.copyWith(fontWeight: FontWeight.w700, color: const Color(0xFF0F172A)),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    description,
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.copyWith(color: const Color(0xFF475569)),
                    textAlign: TextAlign.center,
                  ),
                  if (extra != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      extra!,
                      style: Theme.of(context)
                          .textTheme
                          .labelSmall
                          ?.copyWith(color: const Color(0xFF94A3B8)),
                    ),
                  ]
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CardBox extends StatelessWidget {
  const _CardBox({required this.child, this.padding});

  final Widget child;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: const Color(0xFFE2E8F0)),
          boxShadow: const [
            BoxShadow(
              color: Color(0x0F000000),
              blurRadius: 10,
              offset: Offset(0, 4),
            )
          ],
        ),
        child: Padding(
          padding: padding ?? const EdgeInsets.all(12),
          child: child,
        ),
      ),
    );
  }
}

class _RowIconTitle extends StatelessWidget {
  const _RowIconTitle({required this.icon, required this.title});

  final IconData icon;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: const Color(0xFF0F172A)),
        const SizedBox(width: 8),
        Text(
          title,
          style: Theme.of(context)
              .textTheme
              .labelLarge
              ?.copyWith(fontWeight: FontWeight.w700, color: const Color(0xFF0F172A)),
        ),
      ],
    );
  }
}

class _OutlineButton extends StatelessWidget {
  const _OutlineButton({required this.label, required this.onTap, this.icon});

  final String label;
  final VoidCallback onTap;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              children: [
                if (icon != null) ...[
                  Icon(icon, size: 16, color: const Color(0xFF334155)),
                  const SizedBox(width: 8),
                ],
                Expanded(
                  child: Text(
                    label,
                    style: Theme.of(context)
                        .textTheme
                        .labelMedium
                        ?.copyWith(color: const Color(0xFF334155)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _LabeledDropdown extends StatelessWidget {
  const _LabeledDropdown({
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  final String label;
  final String? value;
  final List<String> items;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context)
              .textTheme
              .labelSmall
              ?.copyWith(fontWeight: FontWeight.w600, color: const Color(0xFF475569)),
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: DropdownButton<String>(
                isExpanded: true,
                value: value,
                hint: const Text('— เลือกค่า —'),
                underline: const SizedBox.shrink(),
                icon: const Icon(Icons.expand_more),
                items: items
                    .map(
                      (e) => DropdownMenuItem<String>(
                        value: e,
                        child: Text(
                          e,
                          style: Theme.of(context).textTheme.labelMedium,
                        ),
                      ),
                    )
                    .toList(),
                onChanged: onChanged,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _PreviewTable extends StatelessWidget {
  const _PreviewTable({required this.rows, required this.cols});

  final int rows;
  final int cols;

  @override
  Widget build(BuildContext context) {
    // header
    final header = TableRow(
      decoration: const BoxDecoration(color: Color(0xFFF1F5F9)),
      children: List.generate(
        cols,
        (i) => Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          child: Text(
            'คอลัมน์ ${i + 1}',
            style: Theme.of(context)
                .textTheme
                .labelSmall
                ?.copyWith(fontWeight: FontWeight.w600, color: const Color(0xFF475569)),
          ),
        ),
      ),
    );

    final bodyRows = List.generate(rows, (r) {
      return TableRow(
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(
            top: BorderSide(color: const Color(0xFFF1F5F9), width: r == 0 ? 1 : .6),
          ),
        ),
        children: List.generate(
          cols,
          (c) => Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            child: Text(
              'ตัวอย่างข้อมูล ${r + 1}-${c + 1}',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(color: const Color(0xFF334155)),
            ),
          ),
        ),
      );
    });

    return Table(
      columnWidths: const {},
      border: const TableBorder.symmetric(inside: BorderSide.none, outside: BorderSide.none),
      children: [header, ...bodyRows],
    );
  }
}

// ----------------------------------------------------
// Helpers
// ----------------------------------------------------

String _fmtDate(DateTime d) {
  final dd = d.day.toString().padLeft(2, '0');
  final mm = d.month.toString().padLeft(2, '0');
  final yy = d.year.toString();
  return '$dd/$mm/$yy';
}
