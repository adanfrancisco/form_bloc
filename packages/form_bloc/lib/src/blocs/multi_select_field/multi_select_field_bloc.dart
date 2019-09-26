part of '../field/field_bloc.dart';

/// A `FieldBloc` used to select multiple items
/// from multiple items.
class MultiSelectFieldBloc<Value> extends FieldBlocBase<List<Value>, Value,
    MultiSelectFieldBlocState<Value>> {
  final List<Value> _items;

  MultiSelectFieldBloc({
    List<Value> initialValue = const [],
    bool isRequired = true,
    List<Validator<List<Value>>> validators,
    Suggestions<Value> suggestions,
    String toStringName,
    List<Value> items = const [],
  })  : assert(isRequired != null),
        assert(initialValue != null),
        assert(items != null),
        _items = items,
        super(
          initialValue,
          isRequired,
          Validators.requiredMultiSelectFieldBloc,
          validators,
          suggestions,
          toStringName,
        );

  @override
  MultiSelectFieldBlocState<Value> get initialState =>
      MultiSelectFieldBlocState(
        value: _initialValue,
        error: _getInitialStateError(),
        isInitial: true,
        isRequired: _isRequired,
        suggestions: _suggestions,
        isValidated: _isValidated,
        toStringName: _toStringName,
        items: FieldBlocBase._itemsWithoutDuplicates(_items),
      );

  /// Set [items] to the `items` of the current state.
  ///
  /// If you want to add or remove elements to `items`
  /// of the current state,
  /// use [addItem] or [removeItem].
  void updateItems(List<Value> items) => dispatch(UpdateFieldBlocItems(items));

  /// Add [item] to the current `items`
  /// of the current state.
  void addItem(Value item) => dispatch(AddFieldBlocItem(item));

  /// Remove [item] to the current `items`
  /// of the current state.
  void removeItem(Value item) => dispatch(RemoveFieldBlocItem(item));

  /// Set [value] to the `value` of the current state.
  ///
  /// If [value] is `null` it will be `[]`.
  ///
  /// {@macro form_bloc.field_bloc.itemsWithoutDuplicates}
  ///
  /// If you want to add or remove elements from `value`
  /// of the current state, use [select] or [deselect].
  ///
  /// {@macro form_bloc.field_bloc.update_value}
  @override
  void updateValue(List<Value> value) =>
      dispatch(UpdateFieldBlocValue(value ?? []));

  /// Set [value] to the `value` and set `isInitial` to `true`
  /// of the current state.
  ///
  /// If [value] is `null` it will be `[]`.
  ///
  /// {@macro form_bloc.field_bloc.itemsWithoutDuplicates}
  ///
  /// {@macro form_bloc.field_bloc.update_value}
  @override
  void updateInitialValue(List<Value> value) =>
      dispatch(UpdateFieldBlocInitialValue(value ?? []));

  /// Add [valueToSelect] to the `value` of the current state.
  ///
  /// {@macro form_bloc.field_bloc.itemsWithoutDuplicates}
  ///
  /// {@macro form_bloc.field_bloc.update_value}
  void select(Value valueToSelect) =>
      dispatch(SelectMultiSelectFieldBlocValue(valueToSelect));

  /// Remove [valueToDeselect] from the `value` of the current state.
  ///
  /// {@macro form_bloc.field_bloc.itemsWithoutDuplicates}
  ///
  /// {@macro form_bloc.field_bloc.update_value}
  void deselect(Value valueToDeselect) =>
      dispatch(DeselectMultiSelectFieldBlocValue(valueToDeselect));

  @override
  Stream<MultiSelectFieldBlocState<Value>> _mapCustomEventToState(
    FieldBlocEvent event,
  ) async* {
    if (event is UpdateFieldBlocItems<Value>) {
      yield currentState.copyWith(
        items: Optional.fromNullable(
          FieldBlocBase._itemsWithoutDuplicates(event.items),
        ),
      );
    } else if (event is AddFieldBlocItem<Value>) {
      List<Value> items = currentState.items ?? [];
      yield currentState.copyWith(
        items: Optional.fromNullable(
          FieldBlocBase._itemsWithoutDuplicates(
            List<Value>.from(items)..add(event.item),
          ),
        ),
      );
    } else if (event is RemoveFieldBlocItem<Value>) {
      List<Value> items = currentState.items;
      if (items != null && items.isNotEmpty) {
        yield currentState.copyWith(
          items: Optional.fromNullable(
            FieldBlocBase._itemsWithoutDuplicates(
              List<Value>.from(items)..remove(event.item),
            ),
          ),
        );
      }
    } else if (event is SelectMultiSelectFieldBlocValue<Value>) {
      if (currentState.formBlocState is! FormBlocSubmitting) {
        List<Value> value = currentState.value ?? [];
        yield currentState.copyWith(
          value: Optional.fromNullable(
            FieldBlocBase._itemsWithoutDuplicates(
              List<Value>.from(value)..add(event.valueToSelect),
            ),
          ),
          isInitial: false,
        );
      }
    } else if (event is DeselectMultiSelectFieldBlocValue<Value>) {
      if (currentState.formBlocState is! FormBlocSubmitting) {
        List<Value> value = currentState.value;
        if (value != null && value.isNotEmpty) {
          yield currentState.copyWith(
            value: Optional.fromNullable(
              FieldBlocBase._itemsWithoutDuplicates(
                List<Value>.from(value)..remove(event.valueToDeselect),
              ),
            ),
            isInitial: false,
          );
        }
      }
    }
  }
}