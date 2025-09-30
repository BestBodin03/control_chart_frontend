int? furnaceIntFromUi(String ui) => (ui == '0' || ui.isEmpty) ? null : int.tryParse(ui);
String uiFromFurnaceInt(int? v)  => v == null ? '0' : '$v';

String? materialFromUi(String ui) => (ui == 'All Material No.' || ui.isEmpty) ? null : ui;
String uiFromMaterial(String? v)   => v ?? 'All Material No.';
