import 'package:analyzer/dart/element/element.dart';
import 'package:build/build.dart';
import 'package:source_gen/source_gen.dart';

import 'annotation.dart';

class DriftTypeGenerator extends GeneratorForAnnotation<DriftType> {
  @override
  Future<String> generateForAnnotatedElement(
    Element element,
    ConstantReader annotation,
    BuildStep buildStep,
  ) async {
    final InterfaceElement interface = getInterface(element);

    final String dto =
        'Dto${interface.name.replaceAll(RegExp(r'[^A-Za-z0-9]+'), '')}';

    final String dtoData =
        dto.endsWith('s') ? dto.substring(0, dto.length - 1) : '${dto}Data';

    return '''
    class $dto extends Table {
      ${dtoFields(interface)}
    }

    extension ${interface.name}DtoExtension on ${interface.name} {
      static ${interface.name} fromDto($dtoData e) {
        return ${interface.name}(
            ${fromDto(interface)}
        );
      }

      $dtoData toDto() {
        return $dtoData(
            ${toDto(interface)}
        );
      }
    }
    ''';
  }

  String dtoFields(InterfaceElement element, {String prefix = ''}) {
    final ConstructorElement constr =
        element.constructors.firstWhere((it) => it.name.isEmpty);

    final buffer = StringBuffer();

    for (FieldElement e in element.fields) {
      if (!constr.parameters.any((p) => p.name == e.name)) {
        continue;
      }

      String name = e.name;

      if (prefix.isNotEmpty) {
        name = '$prefix${name.capitalizeFirst()}';
      }

      if (e.type.isDartCoreInt) {
        buffer.writeln('IntColumn get $name => integer()();');
      } else if (e.type.isDartCoreDouble) {
        buffer.writeln('RealColumn get $name => real()();');
      } else if (e.type.isDartCoreString) {
        buffer.writeln('TextColumn get $name => text()();');
      } else if (e.type.isDartCoreEnum) {
        buffer.writeln('IntColumn get $name => intEnum()();');
      } else if (e.type.isDartCoreBool) {
        buffer.writeln('BoolColumn get $name => boolean()();');
      } else if (e.type.toString() == 'DateTime') {
        buffer.writeln('DateTimeColumn get $name => dateTime()();');
      } else if (e.type.element is InterfaceElement) {
        buffer.writeln(
          dtoFields(e.type.element as InterfaceElement, prefix: name),
        );
      }
    }

    return buffer.toString();
  }

  String fromDto(InterfaceElement element, {String prefix = ''}) {
    final ConstructorElement constr =
        element.constructors.firstWhere((it) => it.name.isEmpty);

    final buffer = StringBuffer();

    for (ParameterElement param in constr.parameters) {
      if (param.isNamed) {
        buffer.write('${param.name}: ');
      }

      String name = param.name;
      if (prefix.isNotEmpty) {
        name = '$prefix${name.capitalizeFirst()}';
      }

      if (param.type.isDartCoreInt ||
          param.type.isDartCoreDouble ||
          param.type.isDartCoreEnum ||
          param.type.isDartCoreString ||
          param.type.isDartCoreBool ||
          param.type.toString() == 'DateTime') {
        buffer.writeln('e.$name,');
      } else if (param.type.element is InterfaceElement) {
        buffer.writeln('${param.type.element!.name}(');
        buffer.write(
          fromDto(param.type.element as InterfaceElement, prefix: name),
        );
        buffer.writeln('),');
      }
    }

    return buffer.toString();
  }

  String toDto(InterfaceElement element, {List<String> prefixes = const []}) {
    final ConstructorElement constr =
        element.constructors.firstWhere((it) => it.name.isEmpty);

    final buffer = StringBuffer();

    for (FieldElement e in element.fields) {
      if (!constr.parameters.any((p) => p.name == e.name)) {
        continue;
      }

      String name1 = e.name;
      String name2 = e.name;

      for (final String prefix in prefixes) {
        name1 = '$prefix${name1.capitalizeFirst()}';
        name2 = '$prefix.$name2';
      }
      if (e.type.isDartCoreInt ||
          e.type.isDartCoreDouble ||
          e.type.isDartCoreEnum ||
          e.type.isDartCoreString ||
          e.type.isDartCoreBool ||
          e.type.toString() == 'DateTime') {
        buffer.writeln('$name1: $name2,');
      } else if (e.type.element is InterfaceElement) {
        buffer.writeln(
          toDto(
            e.type.element as InterfaceElement,
            prefixes: prefixes.toList()..add(e.name),
          ),
        );
      }
    }

    return buffer.toString();
  }

  InterfaceElement getInterface(Element element) {
    if (element.kind != ElementKind.CLASS) {
      throw InvalidGenerationSourceError(
        'Only classes are allowed to be annotated with @$DriftType.',
        element: element,
      );
    }

    return element as InterfaceElement;
  }
}

extension StringExtension on String {
  String capitalizeFirst() {
    return '${this[0].toUpperCase()}${substring(1)}';
  }
}

Builder driftBuilder(BuilderOptions options) {
  return PartBuilder([DriftTypeGenerator()], '.drift.g.dart');
}
