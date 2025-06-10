// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'chat_bloc.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$ChatEvent {
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() subscriptionRequested,
    required TResult Function(String content) messageSent,
    required TResult Function(List<MessageEntity> messages) messagesReceived,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? subscriptionRequested,
    TResult? Function(String content)? messageSent,
    TResult? Function(List<MessageEntity> messages)? messagesReceived,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? subscriptionRequested,
    TResult Function(String content)? messageSent,
    TResult Function(List<MessageEntity> messages)? messagesReceived,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_SubscriptionRequested value)
        subscriptionRequested,
    required TResult Function(_MessageSent value) messageSent,
    required TResult Function(_MessagesReceived value) messagesReceived,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_SubscriptionRequested value)? subscriptionRequested,
    TResult? Function(_MessageSent value)? messageSent,
    TResult? Function(_MessagesReceived value)? messagesReceived,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_SubscriptionRequested value)? subscriptionRequested,
    TResult Function(_MessageSent value)? messageSent,
    TResult Function(_MessagesReceived value)? messagesReceived,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ChatEventCopyWith<$Res> {
  factory $ChatEventCopyWith(ChatEvent value, $Res Function(ChatEvent) then) =
      _$ChatEventCopyWithImpl<$Res, ChatEvent>;
}

/// @nodoc
class _$ChatEventCopyWithImpl<$Res, $Val extends ChatEvent>
    implements $ChatEventCopyWith<$Res> {
  _$ChatEventCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ChatEvent
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc
abstract class _$$SubscriptionRequestedImplCopyWith<$Res> {
  factory _$$SubscriptionRequestedImplCopyWith(
          _$SubscriptionRequestedImpl value,
          $Res Function(_$SubscriptionRequestedImpl) then) =
      __$$SubscriptionRequestedImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$SubscriptionRequestedImplCopyWithImpl<$Res>
    extends _$ChatEventCopyWithImpl<$Res, _$SubscriptionRequestedImpl>
    implements _$$SubscriptionRequestedImplCopyWith<$Res> {
  __$$SubscriptionRequestedImplCopyWithImpl(_$SubscriptionRequestedImpl _value,
      $Res Function(_$SubscriptionRequestedImpl) _then)
      : super(_value, _then);

  /// Create a copy of ChatEvent
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc

class _$SubscriptionRequestedImpl implements _SubscriptionRequested {
  const _$SubscriptionRequestedImpl();

  @override
  String toString() {
    return 'ChatEvent.subscriptionRequested()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SubscriptionRequestedImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() subscriptionRequested,
    required TResult Function(String content) messageSent,
    required TResult Function(List<MessageEntity> messages) messagesReceived,
  }) {
    return subscriptionRequested();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? subscriptionRequested,
    TResult? Function(String content)? messageSent,
    TResult? Function(List<MessageEntity> messages)? messagesReceived,
  }) {
    return subscriptionRequested?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? subscriptionRequested,
    TResult Function(String content)? messageSent,
    TResult Function(List<MessageEntity> messages)? messagesReceived,
    required TResult orElse(),
  }) {
    if (subscriptionRequested != null) {
      return subscriptionRequested();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_SubscriptionRequested value)
        subscriptionRequested,
    required TResult Function(_MessageSent value) messageSent,
    required TResult Function(_MessagesReceived value) messagesReceived,
  }) {
    return subscriptionRequested(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_SubscriptionRequested value)? subscriptionRequested,
    TResult? Function(_MessageSent value)? messageSent,
    TResult? Function(_MessagesReceived value)? messagesReceived,
  }) {
    return subscriptionRequested?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_SubscriptionRequested value)? subscriptionRequested,
    TResult Function(_MessageSent value)? messageSent,
    TResult Function(_MessagesReceived value)? messagesReceived,
    required TResult orElse(),
  }) {
    if (subscriptionRequested != null) {
      return subscriptionRequested(this);
    }
    return orElse();
  }
}

abstract class _SubscriptionRequested implements ChatEvent {
  const factory _SubscriptionRequested() = _$SubscriptionRequestedImpl;
}

/// @nodoc
abstract class _$$MessageSentImplCopyWith<$Res> {
  factory _$$MessageSentImplCopyWith(
          _$MessageSentImpl value, $Res Function(_$MessageSentImpl) then) =
      __$$MessageSentImplCopyWithImpl<$Res>;
  @useResult
  $Res call({String content});
}

/// @nodoc
class __$$MessageSentImplCopyWithImpl<$Res>
    extends _$ChatEventCopyWithImpl<$Res, _$MessageSentImpl>
    implements _$$MessageSentImplCopyWith<$Res> {
  __$$MessageSentImplCopyWithImpl(
      _$MessageSentImpl _value, $Res Function(_$MessageSentImpl) _then)
      : super(_value, _then);

  /// Create a copy of ChatEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? content = null,
  }) {
    return _then(_$MessageSentImpl(
      null == content
          ? _value.content
          : content // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

class _$MessageSentImpl implements _MessageSent {
  const _$MessageSentImpl(this.content);

  @override
  final String content;

  @override
  String toString() {
    return 'ChatEvent.messageSent(content: $content)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MessageSentImpl &&
            (identical(other.content, content) || other.content == content));
  }

  @override
  int get hashCode => Object.hash(runtimeType, content);

  /// Create a copy of ChatEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$MessageSentImplCopyWith<_$MessageSentImpl> get copyWith =>
      __$$MessageSentImplCopyWithImpl<_$MessageSentImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() subscriptionRequested,
    required TResult Function(String content) messageSent,
    required TResult Function(List<MessageEntity> messages) messagesReceived,
  }) {
    return messageSent(content);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? subscriptionRequested,
    TResult? Function(String content)? messageSent,
    TResult? Function(List<MessageEntity> messages)? messagesReceived,
  }) {
    return messageSent?.call(content);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? subscriptionRequested,
    TResult Function(String content)? messageSent,
    TResult Function(List<MessageEntity> messages)? messagesReceived,
    required TResult orElse(),
  }) {
    if (messageSent != null) {
      return messageSent(content);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_SubscriptionRequested value)
        subscriptionRequested,
    required TResult Function(_MessageSent value) messageSent,
    required TResult Function(_MessagesReceived value) messagesReceived,
  }) {
    return messageSent(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_SubscriptionRequested value)? subscriptionRequested,
    TResult? Function(_MessageSent value)? messageSent,
    TResult? Function(_MessagesReceived value)? messagesReceived,
  }) {
    return messageSent?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_SubscriptionRequested value)? subscriptionRequested,
    TResult Function(_MessageSent value)? messageSent,
    TResult Function(_MessagesReceived value)? messagesReceived,
    required TResult orElse(),
  }) {
    if (messageSent != null) {
      return messageSent(this);
    }
    return orElse();
  }
}

abstract class _MessageSent implements ChatEvent {
  const factory _MessageSent(final String content) = _$MessageSentImpl;

  String get content;

  /// Create a copy of ChatEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$MessageSentImplCopyWith<_$MessageSentImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$MessagesReceivedImplCopyWith<$Res> {
  factory _$$MessagesReceivedImplCopyWith(_$MessagesReceivedImpl value,
          $Res Function(_$MessagesReceivedImpl) then) =
      __$$MessagesReceivedImplCopyWithImpl<$Res>;
  @useResult
  $Res call({List<MessageEntity> messages});
}

/// @nodoc
class __$$MessagesReceivedImplCopyWithImpl<$Res>
    extends _$ChatEventCopyWithImpl<$Res, _$MessagesReceivedImpl>
    implements _$$MessagesReceivedImplCopyWith<$Res> {
  __$$MessagesReceivedImplCopyWithImpl(_$MessagesReceivedImpl _value,
      $Res Function(_$MessagesReceivedImpl) _then)
      : super(_value, _then);

  /// Create a copy of ChatEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? messages = null,
  }) {
    return _then(_$MessagesReceivedImpl(
      null == messages
          ? _value._messages
          : messages // ignore: cast_nullable_to_non_nullable
              as List<MessageEntity>,
    ));
  }
}

/// @nodoc

class _$MessagesReceivedImpl implements _MessagesReceived {
  const _$MessagesReceivedImpl(final List<MessageEntity> messages)
      : _messages = messages;

  final List<MessageEntity> _messages;
  @override
  List<MessageEntity> get messages {
    if (_messages is EqualUnmodifiableListView) return _messages;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_messages);
  }

  @override
  String toString() {
    return 'ChatEvent.messagesReceived(messages: $messages)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MessagesReceivedImpl &&
            const DeepCollectionEquality().equals(other._messages, _messages));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, const DeepCollectionEquality().hash(_messages));

  /// Create a copy of ChatEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$MessagesReceivedImplCopyWith<_$MessagesReceivedImpl> get copyWith =>
      __$$MessagesReceivedImplCopyWithImpl<_$MessagesReceivedImpl>(
          this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() subscriptionRequested,
    required TResult Function(String content) messageSent,
    required TResult Function(List<MessageEntity> messages) messagesReceived,
  }) {
    return messagesReceived(messages);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? subscriptionRequested,
    TResult? Function(String content)? messageSent,
    TResult? Function(List<MessageEntity> messages)? messagesReceived,
  }) {
    return messagesReceived?.call(messages);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? subscriptionRequested,
    TResult Function(String content)? messageSent,
    TResult Function(List<MessageEntity> messages)? messagesReceived,
    required TResult orElse(),
  }) {
    if (messagesReceived != null) {
      return messagesReceived(messages);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_SubscriptionRequested value)
        subscriptionRequested,
    required TResult Function(_MessageSent value) messageSent,
    required TResult Function(_MessagesReceived value) messagesReceived,
  }) {
    return messagesReceived(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_SubscriptionRequested value)? subscriptionRequested,
    TResult? Function(_MessageSent value)? messageSent,
    TResult? Function(_MessagesReceived value)? messagesReceived,
  }) {
    return messagesReceived?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_SubscriptionRequested value)? subscriptionRequested,
    TResult Function(_MessageSent value)? messageSent,
    TResult Function(_MessagesReceived value)? messagesReceived,
    required TResult orElse(),
  }) {
    if (messagesReceived != null) {
      return messagesReceived(this);
    }
    return orElse();
  }
}

abstract class _MessagesReceived implements ChatEvent {
  const factory _MessagesReceived(final List<MessageEntity> messages) =
      _$MessagesReceivedImpl;

  List<MessageEntity> get messages;

  /// Create a copy of ChatEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$MessagesReceivedImplCopyWith<_$MessagesReceivedImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
