class CsvExParser {
  final String _separator;

  final int _separatorChar;

  CsvExParser({
    String separator = ',',
  })  : _separator = separator.isEmpty
            ? throw ArgumentError('Must not be empty', 'separator')
            : separator,
        _separatorChar = separator.runes.length != 1
            ? throw ArgumentError.value(separator, 'separator',
                'The length of the separator must be one character')
            : separator.runes.first;

  void beginEvent(CsvExParserEvent event) {
    return;
  }

  R? endEvent<R>(CsvExParserEvent event, R? result, bool ok) {
    return result;
  }

  /// Eol =
  ///     '\n'
  ///   / '\r\n'
  ///   / '\r'
  ///   ;
  void fastParseEol(State<String> state) {
    final $1 = state.pos;
    var $0 = 0;
    if (state.pos < state.input.length) {
      final input = state.input;
      final c = input.codeUnitAt(state.pos);
      // ignore: unused_local_variable
      final pos2 = state.pos + 1;
      switch (c) {
        case 10:
          $0 = 1;
          break;
        case 13:
          final ok = pos2 < input.length && input.codeUnitAt(pos2) == 10;
          if (ok) {
            $0 = 2;
          } else {
            $0 = 1;
          }
          break;
      }
    }
    if ($0 > 0) {
      state.pos += $0;
      state.setOk(true);
    } else {
      state.pos = $1;
      state.fail(const ErrorExpectedTags(['\n', '\r\n', '\r']));
    }
  }

  /// Eol =
  ///     '\n'
  ///   / '\r\n'
  ///   / '\r'
  ///   ;
  AsyncResult<Object?> fastParseEol$Async(State<ChunkedParsingSink> state) {
    final $0 = AsyncResult<Object?>();
    var $2 = 0;
    void $1() {
      while (true) {
        switch ($2) {
          case 0:
            final $3 = state.input;
            if (state.pos >= $3.end && !$3.isClosed) {
              $3.sleep = true;
              $3.handle = $1;
              $2 = 0;
              return;
            }
            const $4 = '\n';
            final $5 = state.pos < $3.end &&
                $3.data.codeUnitAt(state.pos - $3.start) == 10;
            if ($5) {
              state.pos++;
              state.setOk(true);
            } else {
              state.fail(const ErrorExpectedTags([$4]));
            }
            final $15 = !state.ok && state.isRecoverable;
            if (!$15) {
              $2 = 1;
              break;
            }
            $2 = 2;
            break;
          case 1:
            $0.isComplete = true;
            state.input.handle = $0.onComplete;
            $2 = -1;
            return;
          case 2:
            final $7 = state.input;
            if (state.pos + 1 >= $7.end && !$7.isClosed) {
              $7.sleep = true;
              $7.handle = $1;
              $2 = 2;
              return;
            }
            const $8 = '\r\n';
            final $9 = state.pos + 1 < $7.end &&
                $7.data.codeUnitAt(state.pos - $7.start) == 13 &&
                $7.data.codeUnitAt(state.pos - $7.start + 1) == 10;
            if ($9) {
              state.pos += 2;
              state.setOk(true);
            } else {
              state.fail(const ErrorExpectedTags([$8]));
            }
            final $16 = !state.ok && state.isRecoverable;
            if (!$16) {
              $2 = 3;
              break;
            }
            $2 = 4;
            break;
          case 3:
            $2 = 1;
            break;
          case 4:
            final $11 = state.input;
            if (state.pos >= $11.end && !$11.isClosed) {
              $11.sleep = true;
              $11.handle = $1;
              $2 = 4;
              return;
            }
            const $12 = '\r';
            final $13 = state.pos < $11.end &&
                $11.data.codeUnitAt(state.pos - $11.start) == 13;
            if ($13) {
              state.pos++;
              state.setOk(true);
            } else {
              state.fail(const ErrorExpectedTags([$12]));
            }
            $2 = 3;
            break;
          default:
            throw StateError('Invalid state: ${$2}');
        }
      }
    }

    $1();
    return $0;
  }

  /// Spaces =
  ///   [ \t]*
  ///   ;
  void fastParseSpaces(State<String> state) {
    // [ \t]*
    for (var c = 0;
        state.pos < state.input.length &&
            (c = state.input.codeUnitAt(state.pos)) == c &&
            (c == 9 || c == 32);
        // ignore: curly_braces_in_flow_control_structures, empty_statements
        state.pos++);
    state.setOk(true);
  }

  /// Spaces =
  ///   [ \t]*
  ///   ;
  AsyncResult<Object?> fastParseSpaces$Async(State<ChunkedParsingSink> state) {
    final $0 = AsyncResult<Object?>();
    var $2 = 0;
    void $1() {
      while (true) {
        switch ($2) {
          case 0:
            final $5 = state.input;
            var $7 = false;
            while (state.pos < $5.end) {
              final $3 = $5.data.codeUnitAt(state.pos - $5.start);
              final $4 = $3 == 9 || $3 == 32;
              if (!$4) {
                $7 = true;
                break;
              }
              state.pos++;
            }
            if (!$7 && !$5.isClosed) {
              $5.sleep = true;
              $5.handle = $1;
              $2 = 0;
              return;
            }
            state.setOk(true);
            $0.isComplete = true;
            state.input.handle = $0.onComplete;
            $2 = -1;
            return;
          default:
            throw StateError('Invalid state: ${$2}');
        }
      }
    }

    $1();
    return $0;
  }

  /// @event
  /// Row =
  ///   @list1(Field, Separator ↑ v:Field)
  ///   ;
  List<String>? parseRow(State<String> state) {
    beginEvent(CsvExParserEvent.rowEvent);
    List<String>? $0;
    // @list1(Field, Separator ↑ v:Field)
    final $2 = <String>[];
    String? $3;
    // Field
    beginEvent(CsvExParserEvent.fieldEvent);
    // @event @inline Field = String / Text ;
    // String
    // String
    $3 = parseString(state);
    if (!state.ok && state.isRecoverable) {
      // Text
      // Text
      $3 = parseText(state);
    }
    $3 = endEvent<String>(CsvExParserEvent.fieldEvent, $3, state.ok);
    if (state.ok) {
      $2.add($3!);
      final $5 = state.ignoreErrors;
      state.ignoreErrors = true;
      while (true) {
        String? $4;
        // Separator ↑ v:Field
        final $13 = state.pos;
        var $11 = true;
        final $12 = state.ignoreErrors;
        // @inline Separator = @matchString() ;
        // @matchString()
        final $15 = _separator;
        if ($15.isEmpty) {
          state.setOk(true);
        } else {
          final ok = state.pos < state.input.length &&
              state.input.codeUnitAt(state.pos) == $15.codeUnitAt(0) &&
              state.input.startsWith($15, state.pos);
          if (ok) {
            state.pos += $15.length;
            state.setOk(true);
          } else {
            state.fail(ErrorExpectedTags([$15]));
          }
        }
        if (state.ok) {
          $11 = false;
          state.ignoreErrors = false;
          state.setOk(true);
          if (state.ok) {
            String? $10;
            beginEvent(CsvExParserEvent.fieldEvent);
            // @event @inline Field = String / Text ;
            // String
            // String
            $10 = parseString(state);
            if (!state.ok && state.isRecoverable) {
              // Text
              // Text
              $10 = parseText(state);
            }
            $10 = endEvent<String>(CsvExParserEvent.fieldEvent, $10, state.ok);
            if (state.ok) {
              $4 = $10;
            }
          }
        }
        if (!state.ok) {
          if (!$11) {
            state.isRecoverable = false;
          }
          state.backtrack($13);
        }
        state.ignoreErrors = $12;
        if (!state.ok) {
          break;
        }
        $2.add($4!);
      }
      state.ignoreErrors = $5;
    }
    state.setOk($2.isNotEmpty);
    if (state.ok) {
      $0 = $2;
    }
    $0 = endEvent<List<String>>(CsvExParserEvent.rowEvent, $0, state.ok);
    return $0;
  }

  /// @event
  /// Row =
  ///   @list1(Field, Separator ↑ v:Field)
  ///   ;
  AsyncResult<List<String>> parseRow$Async(State<ChunkedParsingSink> state) {
    final $0 = AsyncResult<List<String>>();
    beginEvent(CsvExParserEvent.rowEvent);
    List<String>? $2;
    var $3 = 0;
    late bool $6;
    late List<String> $7;
    String? $4;
    late AsyncResult<String> $8;
    late AsyncResult<String> $10;
    String? $5;
    late bool $13;
    late bool $14;
    late int $15;
    late String $20;
    String? $12;
    late AsyncResult<String> $22;
    late AsyncResult<String> $24;
    void $1() {
      while (true) {
        switch ($3) {
          case 0:
            $7 = [];
            beginEvent(CsvExParserEvent.fieldEvent);
            state.input.beginBuffering();
            $8 = parseString$Async(state);
            if (!$8.isComplete) {
              $8.onComplete = $1;
              $3 = 1;
              return;
            }
            $3 = 1;
            break;
          case 1:
            $4 = $8.value;
            state.input.endBuffering();
            final $26 = !state.ok && state.isRecoverable;
            if (!$26) {
              $3 = 2;
              break;
            }
            $10 = parseText$Async(state);
            if (!$10.isComplete) {
              $10.onComplete = $1;
              $3 = 3;
              return;
            }
            $3 = 3;
            break;
          case 2:
            $4 = endEvent<String>(CsvExParserEvent.fieldEvent, $4, state.ok);
            final $27 = state.ok;
            if (!$27) {
              $3 = 4;
              break;
            }
            $7.add($4!);
            $6 = state.ignoreErrors;
            state.ignoreErrors = true;
            $3 = 6;
            break;
          case 3:
            $4 = $10.value;
            $3 = 2;
            break;
          case 4:
            state.setOk($7.isNotEmpty);
            if (state.ok) {
              $2 = $7;
            }
            endEvent<List<String>>(CsvExParserEvent.rowEvent, $2, state.ok);
            $0.value = $2;
            $0.isComplete = true;
            state.input.handle = $0.onComplete;
            $3 = -1;
            return;
          case 5:
            state.ignoreErrors = $6;
            $3 = 4;
            break;
          case 6:
            $15 = state.pos;
            $14 = true;
            $13 = state.ignoreErrors;
            $20 = _separator;
            final $29 = $20.isEmpty;
            if (!$29) {
              $3 = 7;
              break;
            }
            state.setOk(true);
            $3 = 8;
            break;
          case 7:
            final $17 = state.input;
            if (state.pos + $20.length - 1 >= $17.end && !$17.isClosed) {
              $17.sleep = true;
              $17.handle = $1;
              $3 = 7;
              return;
            }
            final $16 = $17.data;
            final $19 = state.pos - $17.start;
            final $18 = $16.codeUnitAt($19) == $20.codeUnitAt(0) &&
                $16.startsWith($20, $19);
            if ($18) {
              state.pos += $20.length;
              state.setOk(true);
            } else {
              state.fail(ErrorExpectedTags([$20]));
            }
            $3 = 8;
            break;
          case 8:
            final $30 = state.ok;
            if (!$30) {
              $3 = 9;
              break;
            }
            $14 = false;
            state.ignoreErrors = false;
            state.setOk(true);
            state.input.cut(state.pos);
            final $31 = state.ok;
            if (!$31) {
              $3 = 10;
              break;
            }
            beginEvent(CsvExParserEvent.fieldEvent);
            state.input.beginBuffering();
            $22 = parseString$Async(state);
            if (!$22.isComplete) {
              $22.onComplete = $1;
              $3 = 11;
              return;
            }
            $3 = 11;
            break;
          case 9:
            if (!state.ok) {
              if (!$14) {
                state.isRecoverable = false;
              }
              state.backtrack($15);
            }
            state.ignoreErrors = $13;
            if (!state.ok) {
              $3 = 5;
              break;
            }
            $7.add($5!);
            $3 = 6;
            break;
          case 10:
            $3 = 9;
            break;
          case 11:
            $12 = $22.value;
            state.input.endBuffering();
            final $32 = !state.ok && state.isRecoverable;
            if (!$32) {
              $3 = 12;
              break;
            }
            $24 = parseText$Async(state);
            if (!$24.isComplete) {
              $24.onComplete = $1;
              $3 = 13;
              return;
            }
            $3 = 13;
            break;
          case 12:
            $12 = endEvent<String>(CsvExParserEvent.fieldEvent, $12, state.ok);
            if (state.ok) {
              $5 = $12;
            }
            $3 = 10;
            break;
          case 13:
            $12 = $24.value;
            $3 = 12;
            break;
          default:
            throw StateError('Invalid state: ${$3}');
        }
      }
    }

    $1();
    return $0;
  }

  /// Rows =
  ///   v:@list1(Row, RowEnding ↑ v:Row)
  ///   ;
  List<List<String>>? parseRows(State<String> state) {
    List<List<String>>? $0;
    // v:@list1(Row, RowEnding ↑ v:Row)
    final $2 = <List<String>>[];
    List<String>? $3;
    // Row
    // Row
    $3 = parseRow(state);
    if (state.ok) {
      $2.add($3!);
      final $5 = state.ignoreErrors;
      state.ignoreErrors = true;
      while (true) {
        List<String>? $4;
        // RowEnding ↑ v:Row
        final $11 = state.pos;
        var $9 = true;
        final $10 = state.ignoreErrors;
        // @inline RowEnding = Eol !@eof() ;
        // Eol !@eof()
        final $12 = state.pos;
        // Eol
        fastParseEol(state);
        if (state.ok) {
          final $13 = state.pos;
          if (state.pos >= state.input.length) {
            state.setOk(true);
          } else {
            state.fail(const ErrorExpectedEndOfInput());
          }
          if (state.ok) {
            final length = $13 - state.pos;
            state.fail(switch (length) {
              0 => const ErrorUnexpectedInput(0),
              -1 => const ErrorUnexpectedInput(-1),
              -2 => const ErrorUnexpectedInput(-2),
              _ => ErrorUnexpectedInput(length)
            });
            state.backtrack($13);
          } else {
            state.setOk(true);
          }
        }
        if (!state.ok) {
          state.backtrack($12);
        }
        if (state.ok) {
          $9 = false;
          state.ignoreErrors = false;
          state.setOk(true);
          if (state.ok) {
            List<String>? $8;
            // Row
            $8 = parseRow(state);
            if (state.ok) {
              $4 = $8;
            }
          }
        }
        if (!state.ok) {
          if (!$9) {
            state.isRecoverable = false;
          }
          state.backtrack($11);
        }
        state.ignoreErrors = $10;
        if (!state.ok) {
          break;
        }
        $2.add($4!);
      }
      state.ignoreErrors = $5;
    }
    state.setOk($2.isNotEmpty);
    if (state.ok) {
      $0 = $2;
    }
    return $0;
  }

  /// Rows =
  ///   v:@list1(Row, RowEnding ↑ v:Row)
  ///   ;
  AsyncResult<List<List<String>>> parseRows$Async(
      State<ChunkedParsingSink> state) {
    final $0 = AsyncResult<List<List<String>>>();
    List<List<String>>? $2;
    var $3 = 0;
    late bool $6;
    late List<List<String>> $7;
    List<String>? $4;
    late AsyncResult<List<String>> $8;
    List<String>? $5;
    late bool $11;
    late bool $12;
    late int $13;
    late int $14;
    late AsyncResult<Object?> $15;
    late int $17;
    List<String>? $10;
    late AsyncResult<List<String>> $20;
    void $1() {
      while (true) {
        switch ($3) {
          case 0:
            $7 = [];
            $8 = parseRow$Async(state);
            if (!$8.isComplete) {
              $8.onComplete = $1;
              $3 = 1;
              return;
            }
            $3 = 1;
            break;
          case 1:
            $4 = $8.value;
            final $22 = state.ok;
            if (!$22) {
              $3 = 2;
              break;
            }
            $7.add($4!);
            $6 = state.ignoreErrors;
            state.ignoreErrors = true;
            $3 = 4;
            break;
          case 2:
            state.setOk($7.isNotEmpty);
            if (state.ok) {
              $2 = $7;
            }
            $0.value = $2;
            $0.isComplete = true;
            state.input.handle = $0.onComplete;
            $3 = -1;
            return;
          case 3:
            state.ignoreErrors = $6;
            $3 = 2;
            break;
          case 4:
            $13 = state.pos;
            $12 = true;
            $11 = state.ignoreErrors;
            $14 = state.pos;
            $15 = fastParseEol$Async(state);
            if (!$15.isComplete) {
              $15.onComplete = $1;
              $3 = 5;
              return;
            }
            $3 = 5;
            break;
          case 5:
            final $24 = state.ok;
            if (!$24) {
              $3 = 6;
              break;
            }
            $17 = state.pos;
            state.input.beginBuffering();
            $3 = 7;
            break;
          case 6:
            if (!state.ok) {
              state.backtrack($14);
            }
            final $25 = state.ok;
            if (!$25) {
              $3 = 8;
              break;
            }
            $12 = false;
            state.ignoreErrors = false;
            state.setOk(true);
            state.input.cut(state.pos);
            final $26 = state.ok;
            if (!$26) {
              $3 = 9;
              break;
            }
            $20 = parseRow$Async(state);
            if (!$20.isComplete) {
              $20.onComplete = $1;
              $3 = 10;
              return;
            }
            $3 = 10;
            break;
          case 7:
            final $18 = state.input;
            if (state.pos >= $18.end && !$18.isClosed) {
              $18.sleep = true;
              $18.handle = $1;
              $3 = 7;
              return;
            }
            if (state.pos >= $18.end) {
              state.setOk(true);
            } else {
              state.fail(const ErrorExpectedEndOfInput());
            }
            state.input.endBuffering();
            if (state.ok) {
              final length = $17 - state.pos;
              state.fail(switch (length) {
                0 => const ErrorUnexpectedInput(0),
                -1 => const ErrorUnexpectedInput(-1),
                -2 => const ErrorUnexpectedInput(-2),
                _ => ErrorUnexpectedInput(length)
              });
              state.backtrack($17);
            } else {
              state.setOk(true);
            }
            $3 = 6;
            break;
          case 8:
            if (!state.ok) {
              if (!$12) {
                state.isRecoverable = false;
              }
              state.backtrack($13);
            }
            state.ignoreErrors = $11;
            if (!state.ok) {
              $3 = 3;
              break;
            }
            $7.add($5!);
            $3 = 4;
            break;
          case 9:
            $3 = 8;
            break;
          case 10:
            $10 = $20.value;
            if (state.ok) {
              $5 = $10;
            }
            $3 = 9;
            break;
          default:
            throw StateError('Invalid state: ${$3}');
        }
      }
    }

    $1();
    return $0;
  }

  /// @event
  /// Start =
  ///   v:Rows Eol? @eof()
  ///   ;
  List<List<String>>? parseStart(State<String> state) {
    beginEvent(CsvExParserEvent.startEvent);
    List<List<String>>? $0;
    // v:Rows Eol? @eof()
    final $2 = state.pos;
    List<List<String>>? $1;
    // Rows
    $1 = parseRows(state);
    if (state.ok) {
      final $3 = state.ignoreErrors;
      state.ignoreErrors = true;
      // Eol
      fastParseEol(state);
      state.ignoreErrors = $3;
      if (!state.ok) {
        state.setOk(true);
      }
      if (state.ok) {
        if (state.pos >= state.input.length) {
          state.setOk(true);
        } else {
          state.fail(const ErrorExpectedEndOfInput());
        }
        if (state.ok) {
          $0 = $1;
        }
      }
    }
    if (!state.ok) {
      state.backtrack($2);
    }
    $0 =
        endEvent<List<List<String>>>(CsvExParserEvent.startEvent, $0, state.ok);
    return $0;
  }

  /// @event
  /// Start =
  ///   v:Rows Eol? @eof()
  ///   ;
  AsyncResult<List<List<String>>> parseStart$Async(
      State<ChunkedParsingSink> state) {
    final $0 = AsyncResult<List<List<String>>>();
    beginEvent(CsvExParserEvent.startEvent);
    List<List<String>>? $2;
    var $3 = 0;
    late int $5;
    List<List<String>>? $4;
    late AsyncResult<List<List<String>>> $6;
    late bool $8;
    late AsyncResult<Object?> $9;
    void $1() {
      while (true) {
        switch ($3) {
          case 0:
            $5 = state.pos;
            $6 = parseRows$Async(state);
            if (!$6.isComplete) {
              $6.onComplete = $1;
              $3 = 1;
              return;
            }
            $3 = 1;
            break;
          case 1:
            $4 = $6.value;
            final $13 = state.ok;
            if (!$13) {
              $3 = 2;
              break;
            }
            $8 = state.ignoreErrors;
            state.ignoreErrors = true;
            $9 = fastParseEol$Async(state);
            if (!$9.isComplete) {
              $9.onComplete = $1;
              $3 = 3;
              return;
            }
            $3 = 3;
            break;
          case 2:
            if (!state.ok) {
              state.backtrack($5);
            }
            endEvent<List<List<String>>>(
                CsvExParserEvent.startEvent, $2, state.ok);
            $0.value = $2;
            $0.isComplete = true;
            state.input.handle = $0.onComplete;
            $3 = -1;
            return;
          case 3:
            state.ignoreErrors = $8;
            if (!state.ok) {
              state.setOk(true);
            }
            final $14 = state.ok;
            if (!$14) {
              $3 = 4;
              break;
            }
            $3 = 5;
            break;
          case 4:
            $3 = 2;
            break;
          case 5:
            final $11 = state.input;
            if (state.pos >= $11.end && !$11.isClosed) {
              $11.sleep = true;
              $11.handle = $1;
              $3 = 5;
              return;
            }
            if (state.pos >= $11.end) {
              state.setOk(true);
            } else {
              state.fail(const ErrorExpectedEndOfInput());
            }
            if (state.ok) {
              $2 = $4;
            }
            $3 = 4;
            break;
          default:
            throw StateError('Invalid state: ${$3}');
        }
      }
    }

    $1();
    return $0;
  }

  /// String
  /// String =
  ///   OpenQuote ↑ v:Chars CloseQuote {}
  ///   ;
  String? parseString(State<String> state) {
    String? $0;
    // OpenQuote ↑ v:Chars CloseQuote {}
    final $4 = state.pos;
    var $2 = true;
    final $3 = state.ignoreErrors;
    // @inline OpenQuote = Spaces '"' ;
    // Spaces '"'
    final $5 = state.pos;
    // Spaces
    fastParseSpaces(state);
    if (state.ok) {
      const $6 = '"';
      final $7 = state.pos < state.input.length &&
          state.input.codeUnitAt(state.pos) == 34;
      if ($7) {
        state.pos++;
        state.setOk(true);
      } else {
        state.fail(const ErrorExpectedTags([$6]));
      }
    }
    if (!state.ok) {
      state.backtrack($5);
    }
    if (state.ok) {
      $2 = false;
      state.ignoreErrors = false;
      state.setOk(true);
      if (state.ok) {
        List<String>? $1;
        // @inline Chars = ($[^"]+ / '""' <String>{})* ;
        // ($[^"]+ / '""' <String>{})*
        final $10 = <String>[];
        final $9 = state.ignoreErrors;
        state.ignoreErrors = true;
        while (true) {
          String? $11;
          // $[^"]+
          final $13 = state.pos;
          var $14 = false;
          for (var c = 0;
              state.pos < state.input.length &&
                  (c = state.input.runeAt(state.pos)) == c &&
                  (c != 34);
              state.pos += c > 0xffff ? 2 : 1,
              // ignore: curly_braces_in_flow_control_structures, empty_statements
              $14 = true);
          if ($14) {
            state.setOk($14);
          } else {
            state.pos < state.input.length
                ? state.fail(const ErrorUnexpectedCharacter())
                : state.fail(const ErrorUnexpectedEndOfInput());
          }
          if (state.ok) {
            $11 = state.input.substring($13, state.pos);
          }
          if (!state.ok && state.isRecoverable) {
            // '""' <String>{}
            const $16 = '""';
            final $17 = state.pos + 1 < state.input.length &&
                state.input.codeUnitAt(state.pos) == 34 &&
                state.input.codeUnitAt(state.pos + 1) == 34;
            if ($17) {
              state.pos += 2;
              state.setOk(true);
            } else {
              state.fail(const ErrorExpectedTags([$16]));
            }
            if (state.ok) {
              String? $$;
              $$ = '"';
              $11 = $$;
            }
          }
          if (!state.ok) {
            break;
          }
          $10.add($11!);
        }
        state.ignoreErrors = $9;
        state.setOk(true);
        if (state.ok) {
          $1 = $10;
        }
        if (state.ok) {
          // @inline CloseQuote = '"' Spaces ;
          // '"' Spaces
          final $18 = state.pos;
          const $19 = '"';
          final $20 = state.pos < state.input.length &&
              state.input.codeUnitAt(state.pos) == 34;
          if ($20) {
            state.pos++;
            state.setOk(true);
          } else {
            state.fail(const ErrorExpectedTags([$19]));
          }
          if (state.ok) {
            // Spaces
            fastParseSpaces(state);
          }
          if (!state.ok) {
            state.backtrack($18);
          }
          if (state.ok) {
            String? $$;
            final v = $1!;
            $$ = v.join();
            $0 = $$;
          }
        }
      }
    }
    if (!state.ok) {
      if (!$2) {
        state.isRecoverable = false;
      }
      state.backtrack($4);
    }
    state.ignoreErrors = $3;
    return $0;
  }

  /// String
  /// String =
  ///   OpenQuote ↑ v:Chars CloseQuote {}
  ///   ;
  AsyncResult<String> parseString$Async(State<ChunkedParsingSink> state) {
    final $0 = AsyncResult<String>();
    String? $2;
    var $3 = 0;
    late bool $5;
    late bool $6;
    late int $7;
    late int $8;
    late AsyncResult<Object?> $9;
    List<String>? $4;
    late bool $16;
    late List<String> $17;
    String? $15;
    late int $18;
    late int $23;
    late int $29;
    late AsyncResult<Object?> $34;
    void $1() {
      while (true) {
        switch ($3) {
          case 0:
            $7 = state.pos;
            $6 = true;
            $5 = state.ignoreErrors;
            $8 = state.pos;
            $9 = fastParseSpaces$Async(state);
            if (!$9.isComplete) {
              $9.onComplete = $1;
              $3 = 1;
              return;
            }
            $3 = 1;
            break;
          case 1:
            final $36 = state.ok;
            if (!$36) {
              $3 = 2;
              break;
            }
            $3 = 3;
            break;
          case 2:
            if (!state.ok) {
              state.backtrack($8);
            }
            final $37 = state.ok;
            if (!$37) {
              $3 = 4;
              break;
            }
            $6 = false;
            state.ignoreErrors = false;
            state.setOk(true);
            state.input.cut(state.pos);
            final $38 = state.ok;
            if (!$38) {
              $3 = 5;
              break;
            }
            $17 = <String>[];
            $16 = state.ignoreErrors;
            state.ignoreErrors = true;
            $3 = 7;
            break;
          case 3:
            final $11 = state.input;
            if (state.pos >= $11.end && !$11.isClosed) {
              $11.sleep = true;
              $11.handle = $1;
              $3 = 3;
              return;
            }
            const $12 = '"';
            final $13 = state.pos < $11.end &&
                $11.data.codeUnitAt(state.pos - $11.start) == 34;
            if ($13) {
              state.pos++;
              state.setOk(true);
            } else {
              state.fail(const ErrorExpectedTags([$12]));
            }
            $3 = 2;
            break;
          case 4:
            if (!state.ok) {
              if (!$6) {
                state.isRecoverable = false;
              }
              state.backtrack($7);
            }
            state.ignoreErrors = $5;
            $0.value = $2;
            $0.isComplete = true;
            state.input.handle = $0.onComplete;
            $3 = -1;
            return;
          case 5:
            $3 = 4;
            break;
          case 6:
            state.ignoreErrors = $16;
            state.setOk(true);
            if (state.ok) {
              $4 = $17;
            }
            final $41 = state.ok;
            if (!$41) {
              $3 = 11;
              break;
            }
            $29 = state.pos;
            $3 = 12;
            break;
          case 7:
            $18 = state.pos;
            state.input.beginBuffering();
            $23 = 0;
            $3 = 8;
            break;
          case 8:
            final $21 = state.input;
            var $24 = false;
            while (state.pos < $21.end) {
              final $19 = $21.data.runeAt(state.pos - $21.start);
              final $20 = $19 != 34;
              if (!$20) {
                $24 = true;
                break;
              }
              state.pos += $19 > 0xffff ? 2 : 1;
              $23++;
            }
            if (!$24 && !$21.isClosed) {
              $21.sleep = true;
              $21.handle = $1;
              $3 = 8;
              return;
            }
            if ($23 != 0) {
              state.setOk(true);
            } else {
              $21.isClosed
                  ? state.fail(const ErrorUnexpectedEndOfInput())
                  : state.fail(const ErrorUnexpectedCharacter());
            }
            state.input.endBuffering();
            if (state.ok) {
              final input = state.input;
              final start = input.start;
              $15 = input.data.substring($18 - start, state.pos - start);
            }
            final $40 = !state.ok && state.isRecoverable;
            if (!$40) {
              $3 = 9;
              break;
            }
            $3 = 10;
            break;
          case 9:
            if (!state.ok) {
              $3 = 6;
              break;
            }
            $17.add($15!);
            $3 = 7;
            break;
          case 10:
            final $25 = state.input;
            if (state.pos + 1 >= $25.end && !$25.isClosed) {
              $25.sleep = true;
              $25.handle = $1;
              $3 = 10;
              return;
            }
            const $26 = '""';
            final $27 = state.pos + 1 < $25.end &&
                $25.data.codeUnitAt(state.pos - $25.start) == 34 &&
                $25.data.codeUnitAt(state.pos - $25.start + 1) == 34;
            if ($27) {
              state.pos += 2;
              state.setOk(true);
            } else {
              state.fail(const ErrorExpectedTags([$26]));
            }
            if (state.ok) {
              String? $$;
              $$ = '"';
              $15 = $$;
            }
            $3 = 9;
            break;
          case 11:
            $3 = 5;
            break;
          case 12:
            final $30 = state.input;
            if (state.pos >= $30.end && !$30.isClosed) {
              $30.sleep = true;
              $30.handle = $1;
              $3 = 12;
              return;
            }
            const $31 = '"';
            final $32 = state.pos < $30.end &&
                $30.data.codeUnitAt(state.pos - $30.start) == 34;
            if ($32) {
              state.pos++;
              state.setOk(true);
            } else {
              state.fail(const ErrorExpectedTags([$31]));
            }
            final $42 = state.ok;
            if (!$42) {
              $3 = 13;
              break;
            }
            $34 = fastParseSpaces$Async(state);
            if (!$34.isComplete) {
              $34.onComplete = $1;
              $3 = 14;
              return;
            }
            $3 = 14;
            break;
          case 13:
            if (!state.ok) {
              state.backtrack($29);
            }
            if (state.ok) {
              String? $$;
              final v = $4!;
              $$ = v.join();
              $2 = $$;
            }
            $3 = 11;
            break;
          case 14:
            $3 = 13;
            break;
          default:
            throw StateError('Invalid state: ${$3}');
        }
      }
    }

    $1();
    return $0;
  }

  /// Text =
  ///   $TextChar*
  ///   ;
  String? parseText(State<String> state) {
    String? $0;
    // $TextChar*
    final $2 = state.pos;
    final $3 = state.ignoreErrors;
    state.ignoreErrors = true;
    while (true) {
      // @inline TextChar = @verify('Unexpected character', [^"\n\r]) ;
      // @verify('Unexpected character', [^"\n\r])
      final $7 = state.pos;
      int? $5;
      // [^"\n\r]
      if (state.pos < state.input.length) {
        final $9 = state.input.runeAt(state.pos);
        final $10 = !($9 < 13 ? $9 == 10 : $9 <= 13 || $9 == 34);
        if ($10) {
          state.pos += $9 > 0xffff ? 2 : 1;
          state.setOk(true);
          $5 = $9;
        } else {
          state.fail(const ErrorUnexpectedCharacter());
        }
      } else {
        state.fail(const ErrorUnexpectedEndOfInput());
      }
      if (state.ok) {
        // ignore: unused_local_variable
        final $$ = $5!;
        final $6 = (() => $$ != _separatorChar)();
        if (!$6) {
          state.fail(ErrorMessage($7 - state.pos, 'Unexpected character'));
          state.backtrack($7);
        }
      }
      if (!state.ok) {
        break;
      }
    }
    state.ignoreErrors = $3;
    state.setOk(true);
    if (state.ok) {
      $0 = state.input.substring($2, state.pos);
    }
    return $0;
  }

  /// Text =
  ///   $TextChar*
  ///   ;
  AsyncResult<String> parseText$Async(State<ChunkedParsingSink> state) {
    final $0 = AsyncResult<String>();
    String? $2;
    var $3 = 0;
    late int $4;
    late bool $5;
    late int $7;
    int? $6;
    void $1() {
      while (true) {
        switch ($3) {
          case 0:
            $4 = state.pos;
            state.input.beginBuffering();
            $5 = state.ignoreErrors;
            state.ignoreErrors = true;
            $3 = 2;
            break;
          case 1:
            state.ignoreErrors = $5;
            state.setOk(true);
            state.input.endBuffering();
            if (state.ok) {
              final input = state.input;
              final start = input.start;
              $2 = input.data.substring($4 - start, state.pos - start);
            }
            $0.value = $2;
            $0.isComplete = true;
            state.input.handle = $0.onComplete;
            $3 = -1;
            return;
          case 2:
            $7 = state.pos;
            $3 = 3;
            break;
          case 3:
            final $9 = state.input;
            if (state.pos >= $9.end && !$9.isClosed) {
              $9.sleep = true;
              $9.handle = $1;
              $3 = 3;
              return;
            }
            if (state.pos < $9.end) {
              final $10 = $9.data.runeAt(state.pos - $9.start);
              final $11 = !($10 < 13 ? $10 == 10 : $10 <= 13 || $10 == 34);
              if ($11) {
                state.pos += $10 > 0xffff ? 2 : 1;
                $6 = $10;
                state.setOk(true);
              } else {
                state.fail(const ErrorUnexpectedCharacter());
              }
            } else {
              state.fail(const ErrorUnexpectedEndOfInput());
            }
            if (state.ok) {
              // ignore: unused_local_variable
              final $$ = $6!;
              final $8 = (() => $$ != _separatorChar)();
              if (!$8) {
                state
                    .fail(ErrorMessage($7 - state.pos, 'Unexpected character'));
                state.backtrack($7);
              }
            }
            if (!state.ok) {
              $3 = 1;
              break;
            }
            $3 = 2;
            break;
          default:
            throw StateError('Invalid state: ${$3}');
        }
      }
    }

    $1();
    return $0;
  }
}

enum CsvExParserEvent { startEvent, fieldEvent, rowEvent }

void fastParseString(
    void Function(State<String> state) fastParse, String source) {
  final state = State(source);
  fastParse(state);
  if (state.ok) {
    return;
  }

  final parseResult = _createParseResult<String, Object?>(state, null);
  parseResult.getResult();
}

Sink<String> parseAsync<O>(
    AsyncResult<O> Function(State<ChunkedParsingSink> state) parse,
    void Function(ParseResult<ChunkedParsingSink, O> result) onComplete) {
  final input = ChunkedParsingSink();
  final state = State(input);
  final result = parse(state);
  void complete() {
    final parseResult =
        _createParseResult<ChunkedParsingSink, O>(state, result.value);
    onComplete(parseResult);
  }

  if (result.isComplete) {
    complete();
  } else {
    result.onComplete = complete;
  }

  return input;
}

O parseString<O>(O? Function(State<String> state) parse, String source) {
  final state = State(source);
  final result = parse(state);
  if (state.ok) {
    return result as O;
  }

  final parseResult = _createParseResult<String, O>(state, result);
  return parseResult.getResult();
}

ParseResult<I, O> tryParse<I, O>(O? Function(State<I> state) parse, I input) {
  final state = State(input);
  final result = parse(state);
  final parseResult = _createParseResult<I, O>(state, result);
  return parseResult;
}

ParseResult<I, O> _createParseResult<I, O>(State<I> state, O? result) {
  final input = state.input;
  if (state.ok) {
    return ParseResult(
      failPos: state.failPos,
      input: input,
      ok: true,
      pos: state.pos,
      result: result,
    );
  }

  final offset = state.failPos;
  final normalized = _normalize(input, offset, state.getErrors())
      .map((e) => e.getErrorMessage(input, offset))
      .toList();
  String? message;
  if (input is String) {
    message = _errorMessage(input, 0, offset, normalized);
  } else if (input is ChunkedParsingSink) {
    message = _errorMessage(input.data, input.start, offset, normalized);
  } else {
    message = normalized.join('\n');
  }

  return ParseResult(
    errors: normalized,
    failPos: state.failPos,
    input: input,
    errorMessage: message,
    ok: false,
    pos: state.pos,
    result: result,
  );
}

String _errorMessage(
    String source, int inputStart, int offset, List<ErrorMessage> errors) {
  final sb = StringBuffer();
  final errorInfoList = errors
      .map((e) => (length: e.length, message: e.toString()))
      .toSet()
      .toList();
  final offsets =
      errors.map((e) => e.length < 0 ? offset + e.length : offset).toSet();
  final offsetMap = <int, ({int line, int column})>{};
  if (inputStart == 0) {
    var line = 1;
    var lineStart = 0, next = 0, pos = 0;
    while (pos < source.length) {
      final found = offsets.any((e) => pos == e);
      if (found) {
        final column = pos - lineStart + 1;
        offsetMap[pos] = (line: line, column: column);
        offsets.remove(pos);
        if (offsets.isEmpty) {
          break;
        }
      }

      final c = source.codeUnitAt(pos++);
      if (c == 0xa || c == 0xd) {
        next = c == 0xa ? 0xd : 0xa;
        if (pos < source.length && source.codeUnitAt(pos) == next) {
          pos++;
        }

        line++;
        lineStart = pos;
      }
    }
  }

  for (var i = 0; i < errorInfoList.length; i++) {
    int max(int x, int y) => x > y ? x : y;
    int min(int x, int y) => x < y ? x : y;
    if (sb.isNotEmpty) {
      sb.writeln();
      sb.writeln();
    }

    final errorInfo = errorInfoList[i];
    final length = errorInfo.length;
    final message = errorInfo.message;
    final start = min(offset + length, offset);
    final end = max(offset + length, offset);
    final inputLen = source.length;
    final lineLimit = min(80, inputLen);
    final start2 = start;
    final end2 = min(start2 + lineLimit, end);
    final errorLen = end2 - start;
    final extraLen = lineLimit - errorLen;
    final rightLen =
        min(inputStart + inputLen - end2, extraLen - (extraLen >> 1));
    final leftLen =
        min(start - inputStart, max(0, lineLimit - errorLen - rightLen));
    var index = start2 - 1 - inputStart;
    final list = <int>[];
    for (var i = 0; i < leftLen && index >= 0; i++) {
      var cc = source.codeUnitAt(index--);
      if ((cc & 0xFC00) == 0xDC00 && (index > 0)) {
        final pc = source.codeUnitAt(index);
        if ((pc & 0xFC00) == 0xD800) {
          cc = 0x10000 + ((pc & 0x3FF) << 10) + (cc & 0x3FF);
          index--;
        }
      }

      list.add(cc);
    }

    final left = String.fromCharCodes(list.reversed);
    final end3 = min(inputLen, start2 + (lineLimit - leftLen));
    final indicatorLen = max(1, errorLen);
    final right = source.substring(start - inputStart, end3);
    var text = left + right;
    text = text.replaceAll('\n', ' ');
    text = text.replaceAll('\r', ' ');
    text = text.replaceAll('\t', ' ');
    final location = offsetMap[start];
    if (location != null) {
      final line = location.line;
      final column = location.column;
      sb.writeln('line $line, column $column (offset $start): $message');
    } else {
      sb.writeln('offset $start: $message');
    }

    sb.writeln(text);
    sb.write(' ' * leftLen + '^' * indicatorLen);
  }

  return sb.toString();
}

List<ParseError> _normalize<I>(I input, int offset, List<ParseError> errors) {
  final errorList = errors.toList();
  if (errorList.isEmpty) {
    errorList.add(const ErrorUnknownError());
  }

  final expectedTags = errorList.whereType<ErrorExpectedTags>().toList();
  if (expectedTags.isNotEmpty) {
    errorList.removeWhere((e) => e is ErrorExpectedTags);
    final tags = <String>{};
    for (final error in expectedTags) {
      tags.addAll(error.tags);
    }

    final tagList = tags.toList();
    tagList.sort();
    final error = ErrorExpectedTags(tagList);
    errorList.add(error);
  }

  final errorMap = <Object?, ParseError>{};
  for (final error in errorList) {
    Object key = error;
    if (error is ErrorUnexpectedInput) {
      key = (ErrorUnexpectedInput, error.length);
    } else if (error is ErrorUnknownError) {
      key = ErrorUnknownError;
    } else if (error is ErrorUnexpectedCharacter) {
      key = (ErrorUnexpectedCharacter, error.char);
    }

    errorMap[key] = error;
  }

  return errorMap.values.toList();
}

class AsyncResult<T> {
  bool isComplete = false;

  void Function()? onComplete;

  T? value;
}

class ChunkedParsingSink implements Sink<String> {
  int bufferLoad = 0;

  int _cuttingPosition = 0;

  String data = '';

  int end = 0;

  void Function()? handle;

  bool sleep = false;

  int start = 0;

  int _buffering = 0;

  bool _isClosed = false;

  bool get isClosed => _isClosed;

  @override
  void add(String data) {
    if (_isClosed) {
      throw StateError('Chunked data sink already closed');
    }

    this.data = this.data.isNotEmpty ? '${this.data}$data' : data;
    final length = this.data.length;
    end = start + length;
    if (bufferLoad < length) {
      bufferLoad = length;
    }

    sleep = false;
    while (!sleep) {
      final h = handle;
      handle = null;
      if (h == null) {
        break;
      }

      h();
    }

    if (_cuttingPosition > start) {
      this.data = _cuttingPosition != end
          ? this.data.substring(_cuttingPosition - start)
          : '';
      start = _cuttingPosition;
    }
  }

  @pragma('vm:prefer-inline')
  @pragma('dart2js:tryInline')
  int beginBuffering() {
    return _buffering++;
  }

  @override
  void close() {
    if (_isClosed) {
      return;
    }

    _isClosed = true;
    sleep = false;
    while (!sleep) {
      final h = handle;
      handle = null;
      if (h == null) {
        break;
      }

      h();
    }

    if (_buffering != 0) {
      throw StateError('On closing, an incomplete buffering was detected');
    }

    if (data.isNotEmpty) {
      data = '';
    }
  }

  void cut(int position) {
    if (position < start || position > end) {
      throw RangeError.range(position, start, end, 'position');
    }

    if (_buffering == 0) {
      _cuttingPosition = position;
    }
  }

  @pragma('vm:prefer-inline')
  @pragma('dart2js:tryInline')
  void endBuffering() {
    if (--_buffering < 0) {
      throw StateError('Inconsistent buffering completion detected.');
    }
  }
}

class ErrorExpectedEndOfInput extends ParseError {
  static const message = 'Expected an end of input';

  const ErrorExpectedEndOfInput();

  @override
  ErrorMessage getErrorMessage(Object? input, offset) {
    return const ErrorMessage(0, ErrorExpectedEndOfInput.message);
  }
}

class ErrorExpectedTags extends ParseError {
  static const message = 'Expected: {0}';

  final List<String> tags;

  const ErrorExpectedTags(this.tags);

  @override
  ErrorMessage getErrorMessage(Object? input, int? offset) {
    final list = tags.map(ParseError.escape).toList();
    list.sort();
    final argument = list.join(', ');
    return ErrorMessage(0, ErrorExpectedTags.message, [argument]);
  }
}

class ErrorMessage extends ParseError {
  final List<Object?> arguments;

  @override
  final int length;

  final String text;

  const ErrorMessage(this.length, this.text, [this.arguments = const []]);

  @override
  ErrorMessage getErrorMessage(Object? input, int? offset) {
    return this;
  }

  @override
  String toString() {
    var result = text;
    for (var i = 0; i < arguments.length; i++) {
      final argument = arguments[i];
      result = result.replaceAll('{$i}', argument.toString());
    }

    return result;
  }
}

class ErrorUnexpectedCharacter extends ParseError {
  static const message = 'Unexpected character {0}';

  final int? char;

  const ErrorUnexpectedCharacter([this.char]);

  @override
  ErrorMessage getErrorMessage(Object? input, int? offset) {
    var argument = '<?>';
    var char = this.char;
    if (offset != null && offset >= 0) {
      if (input is String) {
        if (offset < input.length) {
          char = input.runeAt(offset);
        } else {
          argument = '<EOF>';
        }
      } else if (input is ChunkedParsingSink) {
        if (offset >= input.start && offset < input.end) {
          final index = offset - input.start;
          char = input.data.runeAt(index);
        } else if (input.isClosed && offset >= input.end) {
          argument = '<EOF>';
        }
      }
    }

    if (char != null) {
      final hexValue = char.toRadixString(16);
      final value = ParseError.escape(char);
      argument = '$value (0x$hexValue)';
    }

    return ErrorMessage(0, ErrorUnexpectedCharacter.message, [argument]);
  }
}

class ErrorUnexpectedEndOfInput extends ParseError {
  static const message = 'Unexpected end of input';

  const ErrorUnexpectedEndOfInput();

  @override
  ErrorMessage getErrorMessage(Object? input, int? offset) {
    return ErrorMessage(length, ErrorUnexpectedEndOfInput.message);
  }
}

class ErrorUnexpectedInput extends ParseError {
  static const message = 'Unexpected input data';

  @override
  final int length;

  const ErrorUnexpectedInput(this.length);

  @override
  ErrorMessage getErrorMessage(Object? input, int? offset) {
    return ErrorMessage(length, ErrorUnexpectedInput.message);
  }
}

class ErrorUnknownError extends ParseError {
  static const message = 'Unknown error';

  const ErrorUnknownError();

  @override
  ErrorMessage getErrorMessage(Object? input, int? offset) {
    return const ErrorMessage(0, ErrorUnknownError.message);
  }
}

abstract class ParseError {
  const ParseError();

  int get length => 0;

  ErrorMessage getErrorMessage(Object? input, int? offset);

  @override
  String toString() {
    final message = getErrorMessage(null, null);
    return message.toString();
  }

  static String escape(Object? value, [bool quote = true]) {
    if (value is int) {
      if (value >= 0 && value <= 0xd7ff ||
          value >= 0xe000 && value <= 0x10ffff) {
        value = String.fromCharCode(value);
      } else {
        return value.toString();
      }
    } else if (value is! String) {
      return value.toString();
    }

    final map = {
      '\b': '\\b',
      '\f': '\\f',
      '\n': '\\n',
      '\r': '\\r',
      '\t': '\\t',
      '\v': '\\v',
    };
    var result = value.toString();
    for (final key in map.keys) {
      result = result.replaceAll(key, map[key]!);
    }

    if (quote) {
      result = "'$result'";
    }

    return result;
  }
}

class ParseResult<I, O> {
  final String errorMessage;

  final List<ErrorMessage> errors;

  final int failPos;

  final I input;

  final bool ok;

  final int pos;

  final O? result;

  ParseResult({
    this.errorMessage = '',
    this.errors = const [],
    required this.failPos,
    required this.input,
    required this.ok,
    required this.pos,
    required this.result,
  });

  O getResult() {
    if (!ok) {
      throw FormatException(errorMessage);
    }

    return result as O;
  }
}

class State<T> {
  int errorCount = 0;

  int failPos = 0;

  bool ignoreErrors = false;

  final T input;

  bool isRecoverable = true;

  int lastFailPos = -1;

  bool ok = false;

  int pos = 0;

  final List<ParseError?> _errors = List.filled(256, null, growable: false);

  State(this.input);

  @pragma('vm:prefer-inline')
  @pragma('dart2js:tryInline')
  void backtrack(int pos) {
    if (isRecoverable) {
      this.pos = pos;
    }
  }

  @pragma('vm:prefer-inline')
  @pragma('dart2js:tryInline')
  bool fail(ParseError error) {
    return failAt(pos, error);
  }

  @pragma('vm:prefer-inline')
  @pragma('dart2js:tryInline')
  bool failAll(List<ParseError> errors) {
    return failAllAt(pos, errors);
  }

  @pragma('vm:prefer-inline')
  @pragma('dart2js:tryInline')
  bool failAllAt(int offset, List<ParseError> errors) {
    ok = false;
    if (!ignoreErrors || !isRecoverable) {
      if (offset >= failPos) {
        if (failPos < offset) {
          failPos = offset;
          errorCount = 0;
        }

        for (var i = 0; i < errors.length; i++) {
          if (errorCount < errors.length) {
            _errors[errorCount++] = errors[i];
          }
        }

        if (lastFailPos < offset) {
          lastFailPos = offset;
        }
      }
    }

    return false;
  }

  @pragma('vm:prefer-inline')
  @pragma('dart2js:tryInline')
  bool failAt(int offset, ParseError error) {
    ok = false;
    if (!ignoreErrors || !isRecoverable) {
      if (offset >= failPos) {
        if (failPos < offset) {
          failPos = offset;
          errorCount = 0;
        }

        if (errorCount < _errors.length) {
          _errors[errorCount++] = error;
        }
      }
    }

    if (lastFailPos < offset) {
      lastFailPos = offset;
    }

    return false;
  }

  @pragma('vm:prefer-inline')
  @pragma('dart2js:tryInline')
  List<ParseError> getErrors() {
    return List.generate(errorCount, (i) => _errors[i]!);
  }

  @pragma('vm:prefer-inline')
  @pragma('dart2js:tryInline')
  void setOk(bool ok) {
    this.ok = !ok ? false : isRecoverable;
  }

  @override
  String toString() {
    if (input case final String input) {
      if (pos >= input.length) {
        return '$ok $pos:';
      }

      var length = input.length - pos;
      length = length > 40 ? 40 : length;
      final string = input.substring(pos, pos + length);
      return '$ok $pos:$string';
    } else if (input case final ChunkedParsingSink input) {
      final source = input.data;
      final pos = this.pos - input.start;
      if (pos < 0 || pos >= source.length) {
        return '$ok $pos:';
      }

      var length = source.length - pos;
      length = length > 40 ? 40 : length;
      final string = source.substring(pos, pos + length);
      return '$ok $pos:$string';
    }

    return super.toString();
  }
}

extension ParseStringExt on String {
  @pragma('vm:prefer-inline')
  @pragma('dart2js:tryInline')
  // ignore: unused_element
  int runeAt(int index) {
    final w1 = codeUnitAt(index++);
    if (w1 > 0xd7ff && w1 < 0xe000) {
      if (index < length) {
        final w2 = codeUnitAt(index);
        if ((w2 & 0xfc00) == 0xdc00) {
          return 0x10000 + ((w1 & 0x3ff) << 10) + (w2 & 0x3ff);
        }
      }

      throw FormatException('Invalid UTF-16 character', this, index - 1);
    }

    return w1;
  }
}
