## 0.5.1
- Fix web support by using conditional import.

## 0.5.0
- Update `CombineIsolate` to use new Flutters `BackgroundIsolateBinaryMessenger` 
  to work with `MethodChannel`s.
- Internal refactoring.

## 0.4.0
- Add a few execute methods:
  - `executeWith3Args`, `executeWith4Args` and `executeWith5Args`. 
    They work like existing `executeWithArg` and `executeWith3Args`.
  - `executeWithApply`. This method works like the `Function.apply` method.
- Improve errors catching and add `UnsupportedIsolateArgumentError` that can be thrown by:
  - `IsolateMessenger.send` method.
  - any execute methods.
- Update readme.

## 0.3.0
- Add the `CombineWorker.newInstance` factory. It can be used to create a new instance
  of the `CombineWorker`.
- Add the `initializer` parameter for the `CombineWorker.initialize` method. 
  It will be executed in each worker isolate during their creation.

## 0.2.0+1
- Update readme
  - Add logo image.
  - Add link to the article.
  - Fix typos.

## 0.2.0
- Introduce `CombineWorker` which is a pool of [CombineIsolate]s that
  efficiently executes tasks in them.
- Improve `Combine`'s documentation.
- Change `Combine.spawn` method's return type. Now it returns 
  `CombineInfo` which holds `CombineIsolate` and `IsolateMessenger`.
- Return `IsolateMessenger` from `CombineIsolate`.
- Add `CombineIsolate` to the `IsolateContext` class.
- Update README.

## 0.1.2
- Export isolate factories.
  
## 0.1.1
- Fix isolate messenger in web and add more tests for it.
- Add short usage example to the README.

## 0.1.0

- Add tests.
- Internal refactoring.

## 0.0.1

- Initial release.
