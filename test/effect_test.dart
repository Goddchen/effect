import 'package:effect/src/effect.dart';
import 'package:effect/src/either.dart';
import 'package:test/test.dart';

void main() {
  group(
    Effect,
    () {
      group(
        'fail',
        () {
          test(
            'returns error when run',
            () async {
              final expectedException = Exception('Test');
              final effect = Effect<void, bool, Object>.fail(expectedException);

              final result = await effect.run();

              expect(
                result,
                equals(Either<bool, Object>.error(expectedException)),
              );
            },
          );
        },
      );

      group(
        'map',
        () {
          test(
            'maps correctly',
            () async {
              final effect = Effect<void, bool, Object>.succeed(true);
              final mappedEffect = effect.map((value) => value.toString());

              final result = await mappedEffect.run();

              result.match(
                (success) => expect(success, equals('true')),
                (error) => fail('Should not call onError'),
              );
            },
          );
        },
      );

      test(
        'propagates error correctly',
        () async {
          final expectedException = Exception('Test');
          final effect = Effect<void, bool, Object>.fail(expectedException);
          final mappedEffect = effect.map((value) => value.toString());

          final result = await mappedEffect.run();

          result.match(
            (success) => fail('Should not call onSuccess'),
            (error) => expect(error, equals(expectedException)),
          );
        },
      );

      group(
        'run',
        () {
          test(
            'runs and returns value',
            () async {
              final effect = Effect<void, bool, Object>.succeed(true);

              final result = await effect.run();

              expect(result, equals(const Either<bool, Object>.success(true)));
            },
          );
        },
      );

      group(
        'succeed',
        () {
          test(
            'returns value when run',
            () async {
              const expectedValue = true;
              final effect = Effect<void, bool, Object>.succeed(expectedValue);

              final result = await effect.run();

              expect(
                result,
                equals(const Either<bool, Object>.success(expectedValue)),
              );
            },
          );
        },
      );

      group(
        'tryCatch',
        () {
          test(
            'returns value when successful',
            () async {
              const expectedValue = true;
              final effect = Effect<void, bool, Object>.tryCatch(
                (_) => expectedValue,
              );

              final result = await effect.run();

              expect(
                result,
                equals(const Either<bool, Object>.success(expectedValue)),
              );
            },
          );

          test(
            'returns error on throw',
            () async {
              final expectedException = Exception('Test');
              final effect = Effect<void, bool, Object>.tryCatch(
                (_) => throw expectedException,
              );

              final result = await effect.run();

              expect(
                result,
                equals(Either<bool, Object>.error(expectedException)),
              );
            },
          );

          test(
            'preserves context when run',
            () async {
              const expectedRequirement = 'Test';
              String? foundRequirement;

              await Effect<String, bool, Object>.tryCatch(
                (context) {
                  foundRequirement = context.requirements;
                  return true;
                },
                expectedRequirement,
              ).run();

              expect(
                foundRequirement,
                equals(expectedRequirement),
              );
            },
          );
        },
      );
    },
  );
}
