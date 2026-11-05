# camouflage_skin_carbon

The Carbon skin for [Camouflage](https://github.com/srctool/camouflage-dart): IBM Carbon's dialect from the
`widgets` layer only. Square corners, opaque layered surfaces (no shadows but for overlays), hover and active
fills, an inset focus border, bottom-border text fields and a bold blue interactive color.

```dart
CamouflageProvider(skin: carbonSkin, theme: carbonLight, child: const MyApp())
```

`carbonTheme(family: ...)` builds the White, G10, G90 and G100 themes; the font is the app's (`fontFamily`).
