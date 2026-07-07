import 'package:flutter/foundation.dart';

class _LicenseEntry extends LicenseEntry {
    const _LicenseEntry(List<String> packages, List<LicenseParagraph> paragraphs):
      _packages = packages,
      _paragraphs = paragraphs;
    
    final List<String> _packages;
    final List<LicenseParagraph> _paragraphs;

    @override
    Iterable<String> get packages => _packages;

    @override
    Iterable<LicenseParagraph> get paragraphs => _paragraphs;
}

Stream<LicenseEntry> licenses() async* {
{{ range . }}
    yield const _LicenseEntry(
        [
        '{{ .Name }}',
        ],
        [
            LicenseParagraph(
                '''{{ .LicenseText }}''',
                0,
            ),
        ],
    );
{{ end }}
}

void registerLicenses() {
  LicenseRegistry.addLicense(licenses);
}