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
  ///     [\n\r]
  ///   / '\r\n'
  ///   ;
  void fastParseEol(State<StringReader> state) {
    // [\n\r]
    state.ok = state.pos < state.input.length;
    if (state.ok) {
      final $1 = state.input.readChar(state.pos);
      state.ok = $1 == 10 || $1 == 13;
      if (state.ok) {
        state.pos += state.input.count;
      } else {
        state.fail(const ErrorUnexpectedCharacter());
      }
    } else {
      state.fail(const ErrorUnexpectedEndOfInput());
    }
    if (!state.ok) {
      // '\r\n'
      const $3 = '\r\n';
      matchLiteral(state, $3, const ErrorExpectedTags([$3]));
    }
  }

  /// Eol =
  ///     [\n\r]
  ///   / '\r\n'
  ///   ;
  AsyncResult<Object?> fastParseEol$Async(State<ChunkedParsingSink> state) {
    final $0 = AsyncResult<Object?>();
    var $1 = 0;
    void $2() {
      while (true) {
        switch ($1) {
          case 0:
            //  // [\n\r]
            //  // [\n\r]
            state.input.beginBuffering();
            $1 = 2;
            break;
          case 2:
            final $3 = state.input;
            if (state.pos + 1 < $3.end || $3.isClosed) {
              state.ok = state.pos < $3.end;
              if (state.pos >= $3.start) {
                if (state.ok) {
                  final c = $3.data.runeAt(state.pos - $3.start);
                  state.ok = c == 10 || c == 13;
                  if (state.ok) {
                    state.pos += c > 0xffff ? 2 : 1;
                  } else {
                    state.fail(const ErrorUnexpectedCharacter());
                  }
                } else {
                  state.fail(const ErrorUnexpectedEndOfInput());
                }
              } else {
                state.fail(ErrorBacktracking(state.pos));
              }
              $3.endBuffering(state.pos);
            } else {
              $3.sleep = true;
              $3.handle = $2;
              return;
            }
            if (state.ok) {
              $1 = 1;
              break;
            }
            //  // '\r\n'
            //  // '\r\n'
            state.input.beginBuffering();
            $1 = 3;
            break;
          case 3:
            final $4 = state.input;
            if (state.pos + 1 < $4.end || $4.isClosed) {
              const string = '\r\n';
              matchLiteralAsync(
                  state, string, const ErrorExpectedTags([string]));
              $4.endBuffering(state.pos);
            } else {
              $4.sleep = true;
              $4.handle = $2;
              return;
            }
            $1 = 1;
            break;
          case 1:
            $0.isComplete = true;
            state.input.handle = $0.onComplete;
            $1 = -1;
            return;
          default:
            throw StateError('Invalid state: ${$1}');
        }
      }
    }

    $2();
    return $0;
  }

  /// Spaces =
  ///   [ \t]*
  ///   ;
  void fastParseSpaces(State<StringReader> state) {
    // [ \t]*
    while (state.pos < state.input.length) {
      final $1 = state.input.readChar(state.pos);
      state.ok = $1 == 9 || $1 == 32;
      if (!state.ok) {
        break;
      }
      state.pos += state.input.count;
    }
    state.fail(const ErrorUnexpectedCharacter());
    state.ok = true;
  }

  /// Spaces =
  ///   [ \t]*
  ///   ;
  AsyncResult<Object?> fastParseSpaces$Async(State<ChunkedParsingSink> state) {
    final $0 = AsyncResult<Object?>();
    var $1 = 0;
    void $2() {
      while (true) {
        switch ($1) {
          case 0:
            //  // [ \t]*
            //  // [ \t]*
            state.input.beginBuffering();
            //  // [ \t]
            state.input.beginBuffering();
            $1 = 1;
            break;
          case 1:
            final $3 = state.input;
            if (state.pos + 1 < $3.end || $3.isClosed) {
              state.ok = state.pos < $3.end;
              if (state.pos >= $3.start) {
                if (state.ok) {
                  final c = $3.data.runeAt(state.pos - $3.start);
                  state.ok = c == 9 || c == 32;
                  if (state.ok) {
                    state.pos += c > 0xffff ? 2 : 1;
                  } else {
                    state.fail(const ErrorUnexpectedCharacter());
                  }
                } else {
                  state.fail(const ErrorUnexpectedEndOfInput());
                }
              } else {
                state.fail(ErrorBacktracking(state.pos));
              }
              $3.endBuffering(state.pos);
            } else {
              $3.sleep = true;
              $3.handle = $2;
              return;
            }
            state.input.endBuffering(state.pos);
            if (!state.ok) {
              $1 = 2;
              break;
            }
            $1 = 0;
            break;
          case 2:
            state.ok = true;
            $0.isComplete = true;
            state.input.handle = $0.onComplete;
            $1 = -1;
            return;
          default:
            throw StateError('Invalid state: ${$1}');
        }
      }
    }

    $2();
    return $0;
  }

  /// @event
  /// Field =
  ///     String
  ///   / Text
  ///   ;
  String? parseField(State<StringReader> state) {
    beginEvent(CsvExParserEvent.fieldEvent);
    String? $0;
    // String
    // String
    $0 = parseString(state);
    if (!state.ok) {
      // Text
      // Text
      $0 = parseText(state);
    }
    $0 = endEvent<String>(CsvExParserEvent.fieldEvent, $0, state.ok);
    return $0;
  }

  /// @event
  /// Field =
  ///     String
  ///   / Text
  ///   ;
  AsyncResult<String> parseField$Async(State<ChunkedParsingSink> state) {
    final $0 = AsyncResult<String>();
    beginEvent(CsvExParserEvent.fieldEvent);
    String? $3;
    AsyncResult<String>? $4;
    AsyncResult<String>? $6;
    var $1 = 0;
    void $2() {
      while (true) {
        switch ($1) {
          case 0:
            //  // String
            //  // String
            $1 = -1;
            $4 = parseString$Async(state);
            final $5 = $4!;
            $1 = 2;
            if ($5.isComplete) {
              break;
            }
            $5.onComplete = $2;
            return;
          case 2:
            $3 = $4!.value;
            $4 = null;
            if (state.ok) {
              $1 = 1;
              break;
            }
            //  // Text
            //  // Text
            $1 = -1;
            $6 = parseText$Async(state);
            final $7 = $6!;
            $1 = 3;
            if ($7.isComplete) {
              break;
            }
            $7.onComplete = $2;
            return;
          case 3:
            $3 = $6!.value;
            $6 = null;
            $1 = 1;
            break;
          case 1:
            $3 = endEvent<String>(CsvExParserEvent.fieldEvent, $3, state.ok);
            $0.value = $3;
            $0.isComplete = true;
            state.input.handle = $0.onComplete;
            $1 = -1;
            return;
          default:
            throw StateError('Invalid state: ${$1}');
        }
      }
    }

    $2();
    return $0;
  }

  /// @event
  /// Row =
  ///   @sepBy(Field, Sep)
  ///   ;
  List<String>? parseRow(State<StringReader> state) {
    beginEvent(CsvExParserEvent.rowEvent);
    List<String>? $0;
    // @sepBy(Field, Sep)
    final $3 = <String>[];
    String? $4;
    // Field
    // Field
    $4 = parseField(state);
    if (state.ok) {
      $3.add($4!);
      while (true) {
        final $2 = state.pos;
        // Sep
        // @inline Sep = @matchString() ;
        // @matchString()
        final $8 = _separator;
        matchLiteral(state, $8, ErrorExpectedTags([$8]));
        if (!state.ok) {
          $0 = $3;
          break;
        }
        // Field
        // Field
        $4 = parseField(state);
        if (!state.ok) {
          state.pos = $2;
          break;
        }
        $3.add($4!);
      }
    }
    state.ok = true;
    if (state.ok) {
      $0 = $3;
    }
    $0 = endEvent<List<String>>(CsvExParserEvent.rowEvent, $0, state.ok);
    return $0;
  }

  /// @event
  /// Row =
  ///   @sepBy(Field, Sep)
  ///   ;
  AsyncResult<List<String>> parseRow$Async(State<ChunkedParsingSink> state) {
    final $0 = AsyncResult<List<String>>();
    beginEvent(CsvExParserEvent.rowEvent);
    List<String>? $3;
    String? $4;
    AsyncResult<String>? $5;
    int? $7;
    AsyncResult<String>? $10;
    var $1 = 0;
    void $2() {
      while (true) {
        switch ($1) {
          case 0:
            //  // @sepBy(Field, Sep)
            //  // @sepBy(Field, Sep)
            state.input.beginBuffering();
            //  // Field
            //  // Field
            //  // Field
            $1 = -1;
            $5 = parseField$Async(state);
            final $6 = $5!;
            $1 = 2;
            if ($6.isComplete) {
              break;
            }
            $6.onComplete = $2;
            return;
          case 2:
            $4 = $5!.value;
            $5 = null;
            state.input.endBuffering(state.pos);
            $3 = [];
            if (!state.ok) {
              $1 = 1;
              break;
            }
            $3!.add($4!);
            $1 = 3;
            break;
          case 3:
            $7 = state.pos;
            state.input.beginBuffering();
            //  // Sep
            //  // Sep
            //  // Sep
            //  // @matchString()
            //  // @matchString()
            //  // @matchString()
            state.input.beginBuffering();
            $1 = 4;
            break;
          case 4:
            final $8 = state.input;
            final $9 = _separator;
            if (state.pos + $9.length - 1 < $8.end || $8.isClosed) {
              matchLiteralAsync(state, $9, ErrorExpectedTags([$9]));
              $8.endBuffering(state.pos);
            } else {
              $8.sleep = true;
              $8.handle = $2;
              return;
            }
            if (!state.ok) {
              state.input.endBuffering(state.pos);
              $1 = 1;
              break;
            }
            //  // Field
            //  // Field
            //  // Field
            $1 = -1;
            $10 = parseField$Async(state);
            final $11 = $10!;
            $1 = 5;
            if ($11.isComplete) {
              break;
            }
            $11.onComplete = $2;
            return;
          case 5:
            $4 = $10!.value;
            $10 = null;
            if (!state.ok) {
              state.pos = $7!;
              state.input.endBuffering(state.pos);
              $1 = 1;
              break;
            }
            state.input.endBuffering(state.pos);
            $3!.add($4!);
            $1 = 3;
            break;
          case 1:
            state.ok = true;
            $3 =
                endEvent<List<String>>(CsvExParserEvent.rowEvent, $3, state.ok);
            $0.value = $3;
            $0.isComplete = true;
            state.input.handle = $0.onComplete;
            $1 = -1;
            return;
          default:
            throw StateError('Invalid state: ${$1}');
        }
      }
    }

    $2();
    return $0;
  }

  /// Rows =
  ///   v:@sepBy(Row, RowEnding) Eol?
  ///   ;
  List<List<String>>? parseRows(State<StringReader> state) {
    List<List<String>>? $0;
    // v:@sepBy(Row, RowEnding) Eol?
    final $1 = state.pos;
    List<List<String>>? $2;
    final $4 = <List<String>>[];
    List<String>? $5;
    // Row
    // Row
    $5 = parseRow(state);
    if (state.ok) {
      $4.add($5!);
      while (true) {
        final $3 = state.pos;
        // RowEnding
        // @inline RowEnding = Eol !Eof ;
        // Eol !Eof
        final $8 = state.pos;
        // Eol
        fastParseEol(state);
        if (state.ok) {
          final $9 = state.pos;
          // @inline Eof = !. ;
          // !.
          final $12 = state.pos;
          final $14 = state.input;
          if (state.pos < $14.length) {
            $14.readChar(state.pos);
            state.pos += $14.count;
            state.ok = true;
          } else {
            state.fail(const ErrorUnexpectedEndOfInput());
          }
          state.ok = !state.ok;
          if (!state.ok) {
            final length = $12 - state.pos;
            state.fail(switch (length) {
              0 => const ErrorUnexpectedInput(0),
              1 => const ErrorUnexpectedInput(1),
              2 => const ErrorUnexpectedInput(2),
              _ => ErrorUnexpectedInput(length)
            });
          }
          state.pos = $12;
          state.ok = !state.ok;
          if (!state.ok) {
            final length = $9 - state.pos;
            state.fail(switch (length) {
              0 => const ErrorUnexpectedInput(0),
              1 => const ErrorUnexpectedInput(1),
              2 => const ErrorUnexpectedInput(2),
              _ => ErrorUnexpectedInput(length)
            });
          }
          state.pos = $9;
        }
        if (!state.ok) {
          state.pos = $8;
        }
        if (!state.ok) {
          $2 = $4;
          break;
        }
        // Row
        // Row
        $5 = parseRow(state);
        if (!state.ok) {
          state.pos = $3;
          break;
        }
        $4.add($5!);
      }
    }
    state.ok = true;
    if (state.ok) {
      $2 = $4;
    }
    if (state.ok) {
      // Eol
      fastParseEol(state);
      state.ok = true;
      if (state.ok) {
        $0 = $2;
      }
    }
    if (!state.ok) {
      state.pos = $1;
    }
    return $0;
  }

  /// Rows =
  ///   v:@sepBy(Row, RowEnding) Eol?
  ///   ;
  AsyncResult<List<List<String>>> parseRows$Async(
      State<ChunkedParsingSink> state) {
    final $0 = AsyncResult<List<List<String>>>();
    List<List<String>>? $3;
    int? $5;
    List<List<String>>? $4;
    List<String>? $6;
    AsyncResult<List<String>>? $7;
    int? $9;
    int? $10;
    AsyncResult<Object?>? $11;
    int? $13;
    int? $14;
    AsyncResult<List<String>>? $16;
    AsyncResult<Object?>? $18;
    var $1 = 0;
    void $2() {
      while (true) {
        switch ($1) {
          case 0:
            //  // v:@sepBy(Row, RowEnding) Eol?
            $5 = state.pos;
            //  // @sepBy(Row, RowEnding)
            state.input.beginBuffering();
            //  // Row
            //  // Row
            //  // Row
            $1 = -1;
            $7 = parseRow$Async(state);
            final $8 = $7!;
            $1 = 3;
            if ($8.isComplete) {
              break;
            }
            $8.onComplete = $2;
            return;
          case 3:
            $6 = $7!.value;
            $7 = null;
            state.input.endBuffering(state.pos);
            $4 = [];
            if (!state.ok) {
              $1 = 2;
              break;
            }
            $4!.add($6!);
            $1 = 4;
            break;
          case 4:
            $9 = state.pos;
            state.input.beginBuffering();
            //  // RowEnding
            //  // RowEnding
            //  // RowEnding
            //  // Eol !Eof
            //  // Eol !Eof
            $10 = state.pos;
            //  // Eol
            $1 = -1;
            $11 = fastParseEol$Async(state);
            $1 = 6;
            final $12 = $11!;
            if ($12.isComplete) {
              break;
            }
            $12.onComplete = $2;
            return;
          case 6:
            $11 = null;
            if (!state.ok) {
              $1 = 5;
              break;
            }
            //  // !Eof
            $13 = state.pos;
            state.input.beginBuffering();
            //  // Eof
            //  // !.
            //  // !.
            //  // !.
            $14 = state.pos;
            state.input.beginBuffering();
            //  // .
            state.input.beginBuffering();
            $1 = 7;
            break;
          case 7:
            final $15 = state.input;
            if (state.pos + 1 >= $15.end && !$15.isClosed) {
              $15.sleep = true;
              $15.handle = $2;
              return;
            }

            if (state.pos >= $15.start) {
              state.ok = state.pos < $15.end;
              if (state.ok) {
                final c = $15.data.runeAt(state.pos - $15.start);
                state.pos += c > 0xffff ? 2 : 1;
              } else {
                state.fail(const ErrorUnexpectedEndOfInput());
              }
            } else {
              state.fail(ErrorBacktracking(state.pos));
            }
            $15.endBuffering(state.pos);
            state.input.endBuffering($14!);
            state.ok = !state.ok;
            if (!state.ok) {
              final length = $14! - state.pos;
              state.fail(switch (length) {
                0 => const ErrorUnexpectedInput(0),
                1 => const ErrorUnexpectedInput(1),
                2 => const ErrorUnexpectedInput(2),
                _ => ErrorUnexpectedInput(length)
              });
            }
            state.pos = $14!;
            state.input.endBuffering($13!);
            state.ok = !state.ok;
            if (!state.ok) {
              final length = $13! - state.pos;
              state.fail(switch (length) {
                0 => const ErrorUnexpectedInput(0),
                1 => const ErrorUnexpectedInput(1),
                2 => const ErrorUnexpectedInput(2),
                _ => ErrorUnexpectedInput(length)
              });
            }
            state.pos = $13!;
            if (!state.ok) {
              state.pos = $10!;
              $1 = 5;
              break;
            }
            $1 = 5;
            break;
          case 5:
            if (!state.ok) {
              state.input.endBuffering(state.pos);
              $1 = 2;
              break;
            }
            //  // Row
            //  // Row
            //  // Row
            $1 = -1;
            $16 = parseRow$Async(state);
            final $17 = $16!;
            $1 = 8;
            if ($17.isComplete) {
              break;
            }
            $17.onComplete = $2;
            return;
          case 8:
            $6 = $16!.value;
            $16 = null;
            if (!state.ok) {
              state.pos = $9!;
              state.input.endBuffering(state.pos);
              $1 = 2;
              break;
            }
            state.input.endBuffering(state.pos);
            $4!.add($6!);
            $1 = 4;
            break;
          case 2:
            state.ok = true;
            if (!state.ok) {
              $1 = 1;
              break;
            }
            //  // Eol?
            state.input.beginBuffering();
            //  // Eol
            $1 = -1;
            $18 = fastParseEol$Async(state);
            $1 = 9;
            final $19 = $18!;
            if ($19.isComplete) {
              break;
            }
            $19.onComplete = $2;
            return;
          case 9:
            $18 = null;
            state.input.endBuffering(state.pos);
            if (!state.ok) {
              state.ok = true;
            }
            if (!state.ok) {
              state.pos = $5!;
              $1 = 1;
              break;
            }
            $3 = $4;
            $1 = 1;
            break;
          case 1:
            $0.value = $3;
            $0.isComplete = true;
            state.input.handle = $0.onComplete;
            $1 = -1;
            return;
          default:
            throw StateError('Invalid state: ${$1}');
        }
      }
    }

    $2();
    return $0;
  }

  /// @event
  /// Start =
  ///   v:Rows Eof
  ///   ;
  List<List<String>>? parseStart(State<StringReader> state) {
    beginEvent(CsvExParserEvent.startEvent);
    List<List<String>>? $0;
    // v:Rows Eof
    final $1 = state.pos;
    List<List<String>>? $2;
    // Rows
    $2 = parseRows(state);
    if (state.ok) {
      // @inline Eof = !. ;
      // !.
      final $4 = state.pos;
      final $6 = state.input;
      if (state.pos < $6.length) {
        $6.readChar(state.pos);
        state.pos += $6.count;
        state.ok = true;
      } else {
        state.fail(const ErrorUnexpectedEndOfInput());
      }
      state.ok = !state.ok;
      if (!state.ok) {
        final length = $4 - state.pos;
        state.fail(switch (length) {
          0 => const ErrorUnexpectedInput(0),
          1 => const ErrorUnexpectedInput(1),
          2 => const ErrorUnexpectedInput(2),
          _ => ErrorUnexpectedInput(length)
        });
      }
      state.pos = $4;
      if (state.ok) {
        $0 = $2;
      }
    }
    if (!state.ok) {
      state.pos = $1;
    }
    $0 =
        endEvent<List<List<String>>>(CsvExParserEvent.startEvent, $0, state.ok);
    return $0;
  }

  /// @event
  /// Start =
  ///   v:Rows Eof
  ///   ;
  AsyncResult<List<List<String>>> parseStart$Async(
      State<ChunkedParsingSink> state) {
    final $0 = AsyncResult<List<List<String>>>();
    beginEvent(CsvExParserEvent.startEvent);
    List<List<String>>? $3;
    int? $5;
    List<List<String>>? $4;
    AsyncResult<List<List<String>>>? $6;
    int? $8;
    var $1 = 0;
    void $2() {
      while (true) {
        switch ($1) {
          case 0:
            //  // v:Rows Eof
            $5 = state.pos;
            //  // Rows
            $1 = -1;
            $6 = parseRows$Async(state);
            final $7 = $6!;
            $1 = 2;
            if ($7.isComplete) {
              break;
            }
            $7.onComplete = $2;
            return;
          case 2:
            $4 = $6!.value;
            $6 = null;
            if (!state.ok) {
              $1 = 1;
              break;
            }
            //  // Eof
            //  // !.
            //  // !.
            //  // !.
            $8 = state.pos;
            state.input.beginBuffering();
            //  // .
            state.input.beginBuffering();
            $1 = 3;
            break;
          case 3:
            final $9 = state.input;
            if (state.pos + 1 >= $9.end && !$9.isClosed) {
              $9.sleep = true;
              $9.handle = $2;
              return;
            }

            if (state.pos >= $9.start) {
              state.ok = state.pos < $9.end;
              if (state.ok) {
                final c = $9.data.runeAt(state.pos - $9.start);
                state.pos += c > 0xffff ? 2 : 1;
              } else {
                state.fail(const ErrorUnexpectedEndOfInput());
              }
            } else {
              state.fail(ErrorBacktracking(state.pos));
            }
            $9.endBuffering(state.pos);
            state.input.endBuffering($8!);
            state.ok = !state.ok;
            if (!state.ok) {
              final length = $8! - state.pos;
              state.fail(switch (length) {
                0 => const ErrorUnexpectedInput(0),
                1 => const ErrorUnexpectedInput(1),
                2 => const ErrorUnexpectedInput(2),
                _ => ErrorUnexpectedInput(length)
              });
            }
            state.pos = $8!;
            if (!state.ok) {
              state.pos = $5!;
              $1 = 1;
              break;
            }
            $3 = $4;
            $1 = 1;
            break;
          case 1:
            $3 = endEvent<List<List<String>>>(
                CsvExParserEvent.startEvent, $3, state.ok);
            $0.value = $3;
            $0.isComplete = true;
            state.input.handle = $0.onComplete;
            $1 = -1;
            return;
          default:
            throw StateError('Invalid state: ${$1}');
        }
      }
    }

    $2();
    return $0;
  }

  /// String
  /// String =
  ///   OpenQuote v:Chars CloseQuote {}
  ///   ;
  String? parseString(State<StringReader> state) {
    String? $0;
    // OpenQuote v:Chars CloseQuote {}
    final $1 = state.pos;
    // @inline OpenQuote = Spaces '"' ;
    // Spaces '"'
    final $3 = state.pos;
    // Spaces
    fastParseSpaces(state);
    if (state.ok) {
      const $4 = '"';
      matchLiteral1(state, 34, $4, const ErrorExpectedTags([$4]));
    }
    if (!state.ok) {
      state.pos = $3;
    }
    if (state.ok) {
      List<String>? $2;
      // @inline Chars = ($[^"]+ / '""' <String>{})* ;
      // ($[^"]+ / '""' <String>{})*
      final $6 = <String>[];
      while (true) {
        String? $7;
        // $[^"]+
        final $9 = state.pos;
        var $10 = false;
        while (true) {
          state.ok = state.pos < state.input.length;
          if (state.ok) {
            final $11 = state.input.readChar(state.pos);
            state.ok = $11 != 34;
            if (state.ok) {
              state.pos += state.input.count;
            } else {
              state.fail(const ErrorUnexpectedCharacter());
            }
          } else {
            state.fail(const ErrorUnexpectedEndOfInput());
          }
          if (!state.ok) {
            break;
          }
          $10 = true;
        }
        state.ok = $10;
        if (state.ok) {
          $7 = state.input.substring($9, state.pos);
        }
        if (!state.ok) {
          // '""' <String>{}
          const $13 = '""';
          matchLiteral(state, $13, const ErrorExpectedTags([$13]));
          if (state.ok) {
            String? $$;
            $$ = '"';
            $7 = $$;
          }
        }
        if (!state.ok) {
          state.ok = true;
          break;
        }
        $6.add($7!);
      }
      if (state.ok) {
        $2 = $6;
      }
      if (state.ok) {
        // @inline CloseQuote = '"' Spaces ;
        // '"' Spaces
        final $14 = state.pos;
        const $15 = '"';
        matchLiteral1(state, 34, $15, const ErrorExpectedTags([$15]));
        if (state.ok) {
          // Spaces
          fastParseSpaces(state);
        }
        if (!state.ok) {
          state.pos = $14;
        }
        if (state.ok) {
          String? $$;
          final v = $2!;
          $$ = v.join();
          $0 = $$;
        }
      }
    }
    if (!state.ok) {
      state.pos = $1;
    }
    return $0;
  }

  /// String
  /// String =
  ///   OpenQuote v:Chars CloseQuote {}
  ///   ;
  AsyncResult<String> parseString$Async(State<ChunkedParsingSink> state) {
    final $0 = AsyncResult<String>();
    String? $3;
    int? $5;
    int? $6;
    AsyncResult<Object?>? $7;
    List<String>? $4;
    List<String>? $10;
    String? $11;
    int? $12;
    bool? $13;
    int? $16;
    AsyncResult<Object?>? $18;
    var $1 = 0;
    void $2() {
      while (true) {
        switch ($1) {
          case 0:
            //  // OpenQuote v:Chars CloseQuote {}
            $5 = state.pos;
            //  // OpenQuote
            //  // Spaces '"'
            //  // Spaces '"'
            $6 = state.pos;
            //  // Spaces
            $1 = -1;
            $7 = fastParseSpaces$Async(state);
            $1 = 3;
            final $8 = $7!;
            if ($8.isComplete) {
              break;
            }
            $8.onComplete = $2;
            return;
          case 3:
            $7 = null;
            if (!state.ok) {
              $1 = 2;
              break;
            }
            //  // '"'
            state.input.beginBuffering();
            $1 = 4;
            break;
          case 4:
            final $9 = state.input;
            if (state.pos + 1 < $9.end || $9.isClosed) {
              matchLiteral1Async(
                  state, 34, '"', const ErrorExpectedTags(['"']));
              $9.endBuffering(state.pos);
            } else {
              $9.sleep = true;
              $9.handle = $2;
              return;
            }
            if (!state.ok) {
              state.pos = $6!;
              $1 = 2;
              break;
            }
            $1 = 2;
            break;
          case 2:
            if (!state.ok) {
              $1 = 1;
              break;
            }
            //  // Chars
            //  // ($[^"]+ / '""' <String>{})*
            //  // ($[^"]+ / '""' <String>{})*
            //  // ($[^"]+ / '""' <String>{})*
            $10 = [];
            $1 = 5;
            break;
          case 5:
            state.input.beginBuffering();
            //  // ($[^"]+ / '""' <String>{})
            $11 = null;
            //  // $[^"]+ / '""' <String>{}
            $11 = null;
            //  // $[^"]+
            $11 = null;
            //  // $[^"]+
            $11 = null;
            $12 = state.pos;
            state.input.beginBuffering();
            //  // [^"]+
            $13 = false;
            $1 = 7;
            break;
          case 7:
            state.input.beginBuffering();
            //  // [^"]
            state.input.beginBuffering();
            $1 = 8;
            break;
          case 8:
            final $14 = state.input;
            if (state.pos + 1 < $14.end || $14.isClosed) {
              state.ok = state.pos < $14.end;
              if (state.pos >= $14.start) {
                if (state.ok) {
                  final c = $14.data.runeAt(state.pos - $14.start);
                  state.ok = c != 34;
                  if (state.ok) {
                    state.pos += c > 0xffff ? 2 : 1;
                  } else {
                    state.fail(const ErrorUnexpectedCharacter());
                  }
                } else {
                  state.fail(const ErrorUnexpectedEndOfInput());
                }
              } else {
                state.fail(ErrorBacktracking(state.pos));
              }
              $14.endBuffering(state.pos);
            } else {
              $14.sleep = true;
              $14.handle = $2;
              return;
            }
            state.input.endBuffering(state.pos);
            if (!state.ok) {
              $1 = 9;
              break;
            }
            $13 = true;
            $1 = 7;
            break;
          case 9:
            state.ok = $13!;
            state.input.endBuffering(state.pos);
            if (state.ok) {
              final input = state.input;
              final start = input.start;
              $11 = input.data.substring($12! - start, state.pos - start);
            }
            if (state.ok) {
              $1 = 6;
              break;
            }
            //  // '""' <String>{}
            $11 = null;
            //  // '""'
            state.input.beginBuffering();
            $1 = 10;
            break;
          case 10:
            final $15 = state.input;
            if (state.pos + 1 < $15.end || $15.isClosed) {
              const string = '""';
              matchLiteralAsync(
                  state, string, const ErrorExpectedTags([string]));
              $15.endBuffering(state.pos);
            } else {
              $15.sleep = true;
              $15.handle = $2;
              return;
            }
            if (state.ok) {
              String? $$;
              $$ = '"';
              $11 = $$;
            }
            $1 = 6;
            break;
          case 6:
            state.input.endBuffering(state.pos);
            if (!state.ok) {
              $1 = 11;
              break;
            }
            $10!.add($11!);
            $1 = 5;
            break;
          case 11:
            $4 = $10;
            $10 = null;
            state.ok = true;
            if (!state.ok) {
              state.pos = $5!;
              $1 = 1;
              break;
            }
            //  // CloseQuote
            //  // '"' Spaces
            //  // '"' Spaces
            $16 = state.pos;
            //  // '"'
            state.input.beginBuffering();
            $1 = 13;
            break;
          case 13:
            final $17 = state.input;
            if (state.pos + 1 < $17.end || $17.isClosed) {
              matchLiteral1Async(
                  state, 34, '"', const ErrorExpectedTags(['"']));
              $17.endBuffering(state.pos);
            } else {
              $17.sleep = true;
              $17.handle = $2;
              return;
            }
            if (!state.ok) {
              $1 = 12;
              break;
            }
            //  // Spaces
            $1 = -1;
            $18 = fastParseSpaces$Async(state);
            $1 = 14;
            final $19 = $18!;
            if ($19.isComplete) {
              break;
            }
            $19.onComplete = $2;
            return;
          case 14:
            $18 = null;
            if (!state.ok) {
              state.pos = $16!;
              $1 = 12;
              break;
            }
            $1 = 12;
            break;
          case 12:
            if (!state.ok) {
              state.pos = $5!;
              $1 = 1;
              break;
            }
            String? $$;
            final v = $4!;
            $$ = v.join();
            $3 = $$;
            $1 = 1;
            break;
          case 1:
            $0.value = $3;
            $0.isComplete = true;
            state.input.handle = $0.onComplete;
            $1 = -1;
            return;
          default:
            throw StateError('Invalid state: ${$1}');
        }
      }
    }

    $2();
    return $0;
  }

  /// Text =
  ///   $TextChar*
  ///   ;
  String? parseText(State<StringReader> state) {
    String? $0;
    // $TextChar*
    final $2 = state.pos;
    while (true) {
      // @inline TextChar = @verify([^"\n\r]) ;
      // @verify([^"\n\r])
      final $7 = state.pos;
      final $6 = state.failPos;
      final $5 = state.errorCount;
      int? $4;
      // [^"\n\r]
      state.ok = state.pos < state.input.length;
      if (state.ok) {
        final $9 = state.input.readChar(state.pos);
        state.ok = $9 != 10 && $9 != 13 && $9 != 34;
        if (state.ok) {
          state.pos += state.input.count;
          $4 = $9;
        } else {
          state.fail(const ErrorUnexpectedCharacter());
        }
      } else {
        state.fail(const ErrorUnexpectedEndOfInput());
      }
      if (state.ok) {
        final pos = $7;
        // ignore: unused_local_variable
        final $$ = $4!;
        ParseError? error;
        if ($$ == _separatorChar) {
          error = ErrorUnexpectedCharacter();
        }
        if (error != null) {
          if ($6 <= pos) {
            state.failPos = $6;
            state.errorCount = $5;
          }
          state.failAt(pos, error);
        }
      }
      if (!state.ok) {
        state.pos = $7;
      }
      if (!state.ok) {
        state.ok = true;
        break;
      }
    }
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
    String? $3;
    int? $4;
    int? $6;
    int? $7;
    int? $8;
    int? $5;
    var $1 = 0;
    void $2() {
      while (true) {
        switch ($1) {
          case 0:
            //  // $TextChar*
            //  // $TextChar*
            $4 = state.pos;
            state.input.beginBuffering();
            //  // TextChar*
            $1 = 1;
            break;
          case 1:
            state.input.beginBuffering();
            //  // TextChar
            //  // @verify([^"\n\r])
            //  // @verify([^"\n\r])
            //  // @verify([^"\n\r])
            $6 = state.pos;
            $7 = state.failPos;
            $8 = state.errorCount;
            state.input.beginBuffering();
            //  // [^"\n\r]
            $5 = null;
            //  // [^"\n\r]
            $5 = null;
            //  // [^"\n\r]
            $5 = null;
            state.input.beginBuffering();
            $1 = 2;
            break;
          case 2:
            final $9 = state.input;
            if (state.pos + 1 < $9.end || $9.isClosed) {
              $5 = null;
              state.ok = state.pos < $9.end;
              if (state.pos >= $9.start) {
                if (state.ok) {
                  final c = $9.data.runeAt(state.pos - $9.start);
                  state.ok = c != 10 && c != 13 && c != 34;
                  if (state.ok) {
                    state.pos += c > 0xffff ? 2 : 1;
                    $5 = c;
                  } else {
                    state.fail(const ErrorUnexpectedCharacter());
                  }
                } else {
                  state.fail(const ErrorUnexpectedEndOfInput());
                }
              } else {
                state.fail(ErrorBacktracking(state.pos));
              }
              $9.endBuffering(state.pos);
            } else {
              $9.sleep = true;
              $9.handle = $2;
              return;
            }
            if (state.ok) {
              final pos = $6!;
              // ignore: unused_local_variable
              final $$ = $5!;
              ParseError? error;
              if ($$ == _separatorChar) {
                error = ErrorUnexpectedCharacter();
              }
              if (error != null) {
                final failPos = $7!;
                if (failPos <= pos) {
                  state.failPos = failPos;
                  state.errorCount = $8!;
                }
                state.failAt(pos, error);
              }
            }
            if (!state.ok) {
              state.pos = $6!;
            }
            state.input.endBuffering(state.pos);
            state.input.endBuffering(state.pos);
            if (!state.ok) {
              $1 = 3;
              break;
            }
            $1 = 1;
            break;
          case 3:
            state.ok = true;
            state.input.endBuffering(state.pos);
            if (state.ok) {
              final input = state.input;
              final start = input.start;
              $3 = input.data.substring($4! - start, state.pos - start);
            }
            $0.value = $3;
            $0.isComplete = true;
            state.input.handle = $0.onComplete;
            $1 = -1;
            return;
          default:
            throw StateError('Invalid state: ${$1}');
        }
      }
    }

    $2();
    return $0;
  }

  @pragma('vm:prefer-inline')
  @pragma('dart2js:tryInline')
  int? matchChar(State<StringReader> state, int char, ParseError error) {
    final input = state.input;
    state.ok = input.matchChar(char, state.pos);
    if (state.ok) {
      state.pos += input.count;
      return char;
    } else {
      state.fail(error);
    }
    return null;
  }

  @pragma('vm:prefer-inline')
  @pragma('dart2js:tryInline')
  int? matchCharAsync(
      State<ChunkedParsingSink> state, int char, ParseError error) {
    final input = state.input;
    if (state.pos < input.start) {
      state.fail(ErrorBacktracking(state.pos));
      return null;
    }
    state.ok = state.pos < input.end;
    if (state.ok) {
      final c = input.data.runeAt(state.pos - input.start);
      state.ok = c == char;
      if (state.ok) {
        state.pos += c > 0xffff ? 2 : 1;
        return char;
      }
    }
    if (!state.ok) {
      state.fail(error);
    }
    return null;
  }

  @pragma('vm:prefer-inline')
  @pragma('dart2js:tryInline')
  String? matchLiteral(
      State<StringReader> state, String string, ParseError error) {
    final input = state.input;
    state.ok = input.startsWith(string, state.pos);
    if (state.ok) {
      state.pos += input.count;
      return string;
    } else {
      state.fail(error);
    }
    return null;
  }

  @pragma('vm:prefer-inline')
  @pragma('dart2js:tryInline')
  String? matchLiteral1(
      State<StringReader> state, int char, String string, ParseError error) {
    final input = state.input;
    state.ok = state.pos < input.length && input.readChar(state.pos) == char;
    if (state.ok) {
      state.pos += input.count;
      state.ok = true;
      return string;
    }
    state.fail(error);
    return null;
  }

  @pragma('vm:prefer-inline')
  @pragma('dart2js:tryInline')
  String? matchLiteral1Async(State<ChunkedParsingSink> state, int char,
      String string, ParseError error) {
    final input = state.input;
    if (state.pos < input.start) {
      state.fail(ErrorBacktracking(state.pos));
      return null;
    }
    state.ok = state.pos < input.end &&
        input.data.runeAt(state.pos - input.start) == char;
    if (state.ok) {
      state.pos += char > 0xffff ? 2 : 1;
      return string;
    }
    state.fail(error);
    return null;
  }

  @pragma('vm:prefer-inline')
  @pragma('dart2js:tryInline')
  String? matchLiteralAsync(
      State<ChunkedParsingSink> state, String string, ParseError error) {
    final input = state.input;
    if (state.pos < input.start) {
      state.fail(ErrorBacktracking(state.pos));
      return null;
    }
    state.ok = state.pos <= input.end &&
        input.data.startsWith(string, state.pos - input.start);
    if (state.ok) {
      state.pos += string.length;
      return string;
    }
    state.fail(error);
    return null;
  }
}

enum CsvExParserEvent { startEvent, fieldEvent, rowEvent }

void fastParseString(
    void Function(State<StringReader> state) fastParse, String source) {
  final input = StringReader(source);
  final result = tryParse(fastParse, input);
  result.getResult();
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

O parseString<O>(O? Function(State<StringReader> state) parse, String source) {
  final input = StringReader(source);
  final result = tryParse(parse, input);
  return result.getResult();
}

ParseResult<I, O> tryParse<I, O>(O? Function(State<I> state) parse, I input) {
  final result = _parse<I, O>(parse, input);
  return result;
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
  if (input is StringReader) {
    if (input.hasSource) {
      final source2 = _StringWrapper(
        invalidChar: 32,
        leftPadding: 0,
        rightPadding: 0,
        source: input.source,
      );
      message = _errorMessage(source2, offset, normalized);
    } else {
      message = _errorMessageWithoutSource(input, offset, normalized);
    }
  } else if (input is ChunkedParsingSink) {
    final source2 = _StringWrapper(
      invalidChar: 32,
      leftPadding: input.start,
      rightPadding: 0,
      source: input.data,
    );
    message = _errorMessage(source2, offset, normalized);
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
    _StringWrapper source, int offset, List<ErrorMessage> errors) {
  final sb = StringBuffer();
  final errorInfoList = errors
      .map((e) => (length: e.length, message: e.toString()))
      .toSet()
      .toList();
  final hasFullSource = source.leftPadding == 0 && source.rightPadding == 0;
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
    var row = 1;
    var lineStart = 0, next = 0, pos = 0;
    if (hasFullSource) {
      while (pos < source.length) {
        final c = source.codeUnitAt(pos++);
        if (c == 0xa || c == 0xd) {
          next = c == 0xa ? 0xd : 0xa;
          if (pos < source.length && source.codeUnitAt(pos) == next) {
            pos++;
          }
          if (pos - 1 >= start) {
            break;
          }
          row++;
          lineStart = pos;
        }
      }
    }

    final inputLen = source.length;
    final lineLimit = min(80, inputLen);
    final start2 = start;
    final end2 = min(start2 + lineLimit, end);
    final errorLen = end2 - start;
    final extraLen = lineLimit - errorLen;
    final rightLen = min(inputLen - end2, extraLen - (extraLen >> 1));
    final leftLen = min(start, max(0, lineLimit - errorLen - rightLen));
    var index = start2 - 1;
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

    final column = start - lineStart + 1;
    final left = String.fromCharCodes(list.reversed);
    final end3 = min(inputLen, start2 + (lineLimit - leftLen));
    final indicatorLen = max(1, errorLen);
    final right = source.substring(start2, end3);
    var text = left + right;
    text = text.replaceAll('\n', ' ');
    text = text.replaceAll('\r', ' ');
    text = text.replaceAll('\t', ' ');
    if (hasFullSource) {
      sb.writeln('line $row, column $column: $message');
    } else {
      sb.writeln('offset $start: $message');
    }

    sb.writeln(text);
    sb.write(' ' * leftLen + '^' * indicatorLen);
  }

  return sb.toString();
}

String _errorMessageWithoutSource(
    StringReader input, int offset, List<ErrorMessage> errors) {
  final sb = StringBuffer();
  final errorInfoList = errors
      .map((e) => (length: e.length, message: e.toString()))
      .toSet()
      .toList();
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
    final inputLen = input.length;
    final lineLimit = min(80, inputLen);
    final start2 = start;
    final end2 = min(start2 + lineLimit, end);
    final errorLen = end2 - start;
    final indicatorLen = max(1, errorLen);
    var text = input.substring(start, lineLimit);
    text = text.replaceAll('\n', ' ');
    text = text.replaceAll('\r', ' ');
    text = text.replaceAll('\t', ' ');
    sb.writeln('offset $offset: $message');
    sb.writeln(text);
    sb.write('^' * indicatorLen);
  }

  return sb.toString();
}

List<ParseError> _normalize<I>(I input, int offset, List<ParseError> errors) {
  final errorList = errors.toList();
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
    if (error is ErrorExpectedCharacter) {
      key = (ErrorExpectedCharacter, error.char);
    } else if (error is ErrorUnexpectedInput) {
      key = (ErrorUnexpectedInput, error.length);
    } else if (error is ErrorUnknownError) {
      key = ErrorUnknownError;
    } else if (error is ErrorUnexpectedCharacter) {
      key = (ErrorUnexpectedCharacter, error.char);
    } else if (error is ErrorBacktracking) {
      key = (ErrorBacktracking, error.position);
    }

    errorMap[key] = error;
  }

  return errorMap.values.toList();
}

ParseResult<I, O> _parse<I, O>(O? Function(State<I> input) parse, I input) {
  final state = State(input);
  final result = parse(state);
  return _createParseResult<I, O>(state, result);
}

class AsyncResult<T> {
  bool isComplete = false;

  void Function()? onComplete;

  T? value;
}

abstract interface class ByteReader {
  int get length;

  int readByte(int offset);
}

class ChunkedParsingSink implements Sink<String> {
  int bufferLoad = 0;

  String data = '';

  int end = 0;

  void Function()? handle;

  bool sleep = false;

  int start = 0;

  int _buffering = 0;

  bool _isClosed = false;

  int _lastPosition = 0;

  bool get isClosed => _isClosed;

  @override
  void add(String data) {
    if (_isClosed) {
      throw StateError('Chunked data sink already closed');
    }

    if (_lastPosition > start) {
      if (_lastPosition == end) {
        this.data = '';
      } else {
        this.data = this.data.substring(_lastPosition - start);
      }

      start = _lastPosition;
    }

    if (this.data.isEmpty) {
      this.data = data;
    } else {
      this.data = '${this.data}$data';
    }

    end = start + this.data.length;
    if (bufferLoad < this.data.length) {
      bufferLoad = this.data.length;
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

    if (_buffering == 0) {
      if (_lastPosition > start) {
        if (_lastPosition == end) {
          this.data = '';
        } else {
          this.data = this.data.substring(_lastPosition - start);
        }

        start = _lastPosition;
      }
    }
  }

  @pragma('vm:prefer-inline')
  @pragma('dart2js:tryInline')
  void beginBuffering() {
    _buffering++;
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

  @pragma('vm:prefer-inline')
  @pragma('dart2js:tryInline')
  void endBuffering(int position) {
    _buffering--;
    if (_buffering == 0) {
      if (_lastPosition < position) {
        _lastPosition = position;
      }
    } else if (_buffering < 0) {
      throw StateError('Inconsistent buffering completion detected.');
    }
  }
}

class ErrorBacktracking extends ParseError {
  static const message = 'Backtracking error to position {{0}}';

  final int position;

  const ErrorBacktracking(this.position);

  @override
  ErrorMessage getErrorMessage(Object? input, int? offset) {
    return ErrorMessage(0, ErrorBacktracking.message, [position]);
  }
}

class ErrorExpectedCharacter extends ParseError {
  static const message = 'Expected a character {0}';

  final int char;

  const ErrorExpectedCharacter(this.char);

  @override
  ErrorMessage getErrorMessage(Object? input, int? offset) {
    final value = ParseError.escape(char);
    final hexValue = char.toRadixString(16);
    final argument = '$value (0x$hexValue)';
    return ErrorMessage(0, ErrorExpectedCharacter.message, [argument]);
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
    if (offset != null && offset > 0) {
      if (input is StringReader && input.hasSource) {
        if (offset < input.length) {
          char = input.readChar(offset);
        } else {
          argument = '<EOF>';
        }
      } else if (input is ChunkedParsingSink) {
        final data = input.data;
        final length = input.isClosed ? input.end : -1;
        if (length != -1) {
          if (offset < length) {
            final source = _StringWrapper(
              invalidChar: 32,
              leftPadding: input.start,
              rightPadding: 0,
              source: data,
            );
            if (source.hasCodeUnitAt(offset)) {
              char = source.runeAt(offset);
            }
          } else {
            argument = '<EOF>';
          }
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
  Object? context;

  final List<ParseError?> errors = List.filled(64, null, growable: false);

  int errorCount = 0;

  int failPos = 0;

  final T input;

  bool ok = false;

  int pos = 0;

  State(this.input);

  @pragma('vm:prefer-inline')
  @pragma('dart2js:tryInline')
  bool fail(ParseError error) {
    ok = false;
    if (pos >= failPos) {
      if (failPos < pos) {
        failPos = pos;
        errorCount = 0;
      }
      if (errorCount < errors.length) {
        errors[errorCount++] = error;
      }
    }
    return false;
  }

  @pragma('vm:prefer-inline')
  @pragma('dart2js:tryInline')
  bool failAll(List<ParseError> errors) {
    ok = false;
    if (pos >= failPos) {
      if (failPos < pos) {
        failPos = pos;
        errorCount = 0;
      }
      for (var i = 0; i < errors.length; i++) {
        if (errorCount < errors.length) {
          this.errors[errorCount++] = errors[i];
        }
      }
    }
    return false;
  }

  @pragma('vm:prefer-inline')
  @pragma('dart2js:tryInline')
  bool failAllAt(int offset, List<ParseError> errors) {
    ok = false;
    if (offset >= failPos) {
      if (failPos < offset) {
        failPos = offset;
        errorCount = 0;
      }
      for (var i = 0; i < errors.length; i++) {
        if (errorCount < errors.length) {
          this.errors[errorCount++] = errors[i];
        }
      }
    }
    return false;
  }

  @pragma('vm:prefer-inline')
  @pragma('dart2js:tryInline')
  bool failAt(int offset, ParseError error) {
    ok = false;
    if (offset >= failPos) {
      if (failPos < offset) {
        failPos = offset;
        errorCount = 0;
      }
      if (errorCount < errors.length) {
        errors[errorCount++] = error;
      }
    }
    return false;
  }

  List<ParseError> getErrors() {
    return List.generate(errorCount, (i) => errors[i]!);
  }

  @override
  String toString() {
    if (input case final StringReader input) {
      if (input.hasSource) {
        final source = input.source;
        if (pos >= source.length) {
          return '$pos:';
        }
        var length = source.length - pos;
        length = length > 40 ? 40 : length;
        final string = source.substring(pos, pos + length);
        return '$pos:$string';
      }
    } else if (input case final ChunkedParsingSink input) {
      final source = input.data;
      final pos = this.pos - input.start;
      if (pos < 0 || pos >= source.length) {
        return '$pos:';
      }
      var length = source.length - pos;
      length = length > 40 ? 40 : length;
      final string = source.substring(pos, pos + length);
      return '$pos:$string';
    }

    return super.toString();
  }

  @pragma('vm:prefer-inline')
  @pragma('dart2js:tryInline')
  // ignore: unused_element
  bool _canHandleError(int failPos, int errorCount) {
    return failPos == this.failPos
        ? errorCount < this.errorCount
        : failPos < this.failPos;
  }

  @pragma('vm:prefer-inline')
  @pragma('dart2js:tryInline')
  // ignore: unused_element
  void _rollbackErrors(int failPos, int errorCount) {
    if (this.failPos == failPos) {
      this.errorCount = errorCount;
    } else if (this.failPos > failPos) {
      this.errorCount = 0;
    }
  }
}

abstract interface class StringReader {
  factory StringReader(String source) {
    return _StringReader(source);
  }

  int get count;

  bool get hasSource;

  int get length;

  String get source;

  int indexOf(String string, int start);

  bool matchChar(int char, int offset);

  int readChar(int offset);

  bool startsWith(String string, [int index = 0]);

  String substring(int start, [int? end]);
}

class _StringReader implements StringReader {
  @override
  final bool hasSource = true;

  @override
  final int length;

  @override
  int count = 0;

  @override
  final String source;

  _StringReader(this.source) : length = source.length;

  @override
  int indexOf(String string, int start) {
    return source.indexOf(string, start);
  }

  @override
  @pragma('vm:prefer-inline')
  @pragma('dart2js:tryInline')
  bool matchChar(int char, int offset) {
    if (offset < length) {
      final c = source.runeAt(offset);
      count = char > 0xffff ? 2 : 1;
      if (c == char) {
        return true;
      }
    }

    return false;
  }

  @override
  @pragma('vm:prefer-inline')
  @pragma('dart2js:tryInline')
  int readChar(int offset) {
    final result = source.runeAt(offset);
    count = result > 0xffff ? 2 : 1;
    return result;
  }

  @override
  @pragma('vm:prefer-inline')
  @pragma('dart2js:tryInline')
  bool startsWith(String string, [int index = 0]) {
    if (source.startsWith(string, index)) {
      count = string.length;
      return true;
    }

    return false;
  }

  @override
  @pragma('vm:prefer-inline')
  @pragma('dart2js:tryInline')
  String substring(int start, [int? end]) {
    final result = source.substring(start, end);
    count = result.length;
    return result;
  }

  @override
  String toString() {
    return source;
  }
}

class _StringWrapper {
  final int invalidChar;

  final int leftPadding;

  final int length;

  final int rightPadding;

  final String source;

  _StringWrapper({
    required this.invalidChar,
    required this.leftPadding,
    required this.rightPadding,
    required this.source,
  }) : length = leftPadding + source.length + rightPadding;

  int codeUnitAt(int index) {
    if (index < 0 || index > length - 1) {
      throw RangeError.range(index, 0, length, 'index');
    }

    final offset = index - leftPadding;
    if (offset >= 0 && offset < source.length) {
      return source.codeUnitAt(offset);
    }

    return invalidChar;
  }

  bool hasCodeUnitAt(int index) {
    if (index < 0 || index > length - 1) {
      throw RangeError.range(index, 0, length, 'index');
    }

    return index >= leftPadding && index <= rightPadding && source.isNotEmpty;
  }

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

  String substring(int start, int end) {
    if (start < 0 || start > length) {
      throw RangeError.range(start, 0, length, 'index');
    }

    if (end < start || end > length) {
      throw RangeError.range(end, start, length, 'end');
    }

    final codeUnits = List.generate(end - start, (i) => codeUnitAt(start + i));
    return String.fromCharCodes(codeUnits);
  }
}

extension StringExt on String {
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
