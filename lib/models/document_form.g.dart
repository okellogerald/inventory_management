// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'document_form.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$_DocumentForm _$$_DocumentFormFromJson(Map<String, dynamic> json) =>
    _$_DocumentForm(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      description: json['description'] as String?,
      total: (json['total'] as num?)?.toDouble() ?? 0.0,
      timestamp: json['date'] as int,
    );

Map<String, dynamic> _$$_DocumentFormToJson(_$_DocumentForm instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'description': instance.description,
      'total': instance.total,
      'date': instance.timestamp,
    };
