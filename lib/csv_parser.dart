class CsvParser {
  const CsvParser();

  void beginEvent(CsvParserEvent event) {
    return;
  }

  R? endEvent<R>(CsvParserEvent event, R? result, bool ok) {
    return result;
  }

  /// Eol =
  ///     '\n'
  ///   / '\r\n'
  ///   / '\r'
  ///   ;
  void fastParseEol(State<String> state) {
    final $5 = state.pos;
    state.ok = false;
    final $1 = state.input;
    if (state.pos < $1.length) {
      final $0 = $1.runeAt(state.pos);
      state.pos += $0 > 0xffff ? 2 : 1;
      switch ($0) {
        case 10:
          state.ok = true;
          break;
        case 13:
          state.ok = state.pos < $1.length && $1.runeAt(state.pos) == 10;
          if (state.ok) {
            state.pos += 1;
          } else {
            state.ok = true;
          }
          break;
      }
    }
    if (!state.ok) {
      state.pos = $5;
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
    int? $2;
    Object? $5;
    Object? $8;
    Object? $11;
    int $12 = 0;
    void $1() {
      if ($12 & 0x1 == 0) {
        $12 |= 0x1;
        $2 = 0;
      }
      if ($2 == 0) {
        // '\n'
        // '\n'
        $5 ??= state.input.beginBuffering();
        final $3 = state.input;
        if (state.pos >= $3.end && !$3.isClosed) {
          $3.sleep = true;
          $3.handle = $1;
          return;
        }
        const $4 = '\n';
        matchLiteral1Async(state, $4, const ErrorExpectedTags([$4]));
        state.input.endBuffering();
        $5 = null;
        $2 = state.ok
            ? -1
            : state.isRecoverable
                ? 1
                : -1;
      }
      if ($2 == 1) {
        // '\r\n'
        // '\r\n'
        $8 ??= state.input.beginBuffering();
        final $6 = state.input;
        if (state.pos + 1 >= $6.end && !$6.isClosed) {
          $6.sleep = true;
          $6.handle = $1;
          return;
        }
        const $7 = '\r\n';
        matchLiteral2Async(state, $7, const ErrorExpectedTags([$7]));
        state.input.endBuffering();
        $8 = null;
        $2 = state.ok
            ? -1
            : state.isRecoverable
                ? 2
                : -1;
      }
      if ($2 == 2) {
        // '\r'
        // '\r'
        $11 ??= state.input.beginBuffering();
        final $9 = state.input;
        if (state.pos >= $9.end && !$9.isClosed) {
          $9.sleep = true;
          $9.handle = $1;
          return;
        }
        const $10 = '\r';
        matchLiteral1Async(state, $10, const ErrorExpectedTags([$10]));
        state.input.endBuffering();
        $11 = null;
        $2 = -1;
      }
      $12 &= ~0x1 & 0xffff;
      $0.isComplete = true;
      state.input.handle = $0.onComplete;
      return;
    }

    $1();
    return $0;
  }

  /// Spaces =
  ///   [ \t]*
  ///   ;
  void fastParseSpaces(State<String> state) {
    // [ \t]*
    while (true) {
      state.ok = state.pos < state.input.length;
      if (state.ok) {
        final $1 = state.input.codeUnitAt(state.pos);
        state.ok = $1 == 9 || $1 == 32;
        if (state.ok) {
          state.pos++;
        } else {
          state.fail(const ErrorUnexpectedCharacter());
        }
      } else {
        state.fail(const ErrorUnexpectedEndOfInput());
      }
      if (!state.ok) {
        break;
      }
    }
    state.setOk(true);
  }

  /// Spaces =
  ///   [ \t]*
  ///   ;
  AsyncResult<Object?> fastParseSpaces$Async(State<ChunkedParsingSink> state) {
    final $0 = AsyncResult<Object?>();
    Object? $4;
    void $1() {
      // [ \t]*
      // [ \t]*
      while (true) {
        // [ \t]
        $4 ??= state.input.beginBuffering();
        final $3 = state.input;
        if (state.pos >= $3.end && !$3.isClosed) {
          $3.sleep = true;
          $3.handle = $1;
          return;
        }
        final $2 = readChar16Async(state);
        if ($2 >= 0) {
          state.ok = $2 == 9 || $2 == 32;
          if (state.ok) {
            state.pos++;
          } else {
            state.fail(const ErrorUnexpectedCharacter());
          }
        }
        state.input.endBuffering();
        $4 = null;
        if (!state.ok) {
          break;
        }
      }
      state.setOk(true);
      $0.isComplete = true;
      state.input.handle = $0.onComplete;
      return;
    }

    $1();
    return $0;
  }

  @pragma('vm:prefer-inline')
  @pragma('dart2js:tryInline')
  String? matchLiteral(State<String> state, String string, ParseError error) {
    if (string.isEmpty) {
      state.ok = true;
      return '';
    }
    final input = state.input;
    final pos = state.pos;
    state.ok = pos < input.length &&
        input.codeUnitAt(pos) == string.codeUnitAt(0) &&
        input.startsWith(string, pos);
    if (state.ok) {
      state.pos += string.length;
      return string;
    } else {
      state.fail(error);
    }
    return null;
  }

  @pragma('vm:prefer-inline')
  @pragma('dart2js:tryInline')
  String? matchLiteral1(State<String> state, String string, ParseError error) {
    final input = state.input;
    final pos = state.pos;
    state.ok =
        pos < input.length && input.codeUnitAt(pos) == string.codeUnitAt(0);
    if (state.ok) {
      state.pos++;
      state.ok = true;
      return string;
    }
    state.fail(error);
    return null;
  }

  @pragma('vm:prefer-inline')
  @pragma('dart2js:tryInline')
  String? matchLiteral1Async(
      State<ChunkedParsingSink> state, String string, ParseError error) {
    final input = state.input;
    final start = input.start;
    final pos = state.pos;
    state.ok = pos < input.end &&
        input.data.codeUnitAt(pos - start) == string.codeUnitAt(0);
    if (state.ok) {
      state.pos++;
      return string;
    }
    state.fail(error);
    return null;
  }

  @pragma('vm:prefer-inline')
  @pragma('dart2js:tryInline')
  String? matchLiteral2(State<String> state, String string, ParseError error) {
    final input = state.input;
    final pos = state.pos;
    final pos2 = pos + 1;
    state.ok = pos2 < input.length &&
        input.codeUnitAt(pos) == string.codeUnitAt(0) &&
        input.codeUnitAt(pos2) == string.codeUnitAt(1);
    if (state.ok) {
      state.pos += 2;
      state.ok = true;
      return string;
    }
    state.fail(error);
    return null;
  }

  @pragma('vm:prefer-inline')
  @pragma('dart2js:tryInline')
  String? matchLiteral2Async(
      State<ChunkedParsingSink> state, String string, ParseError error) {
    final input = state.input;
    final start = input.start;
    final data = input.data;
    final pos = state.pos;
    final index = pos - start;
    state.ok = pos + 1 < input.end &&
        data.codeUnitAt(index) == string.codeUnitAt(0) &&
        data.codeUnitAt(index + 1) == string.codeUnitAt(1);
    if (state.ok) {
      state.pos += 2;
      return string;
    }
    state.fail(error);
    return null;
  }

  /// @event
  /// Row =
  ///   @sepBy1(Field, ',' ↑)
  ///   ;
  List<String>? parseRow(State<String> state) {
    beginEvent(CsvParserEvent.rowEvent);
    List<String>? $0;
    // @sepBy1(Field, ',' ↑)
    final $2 = <String>[];
    var $4 = state.pos;
    while (true) {
      String? $3;
      // Field
      beginEvent(CsvParserEvent.fieldEvent);
      // @event @inline Field = String / Text ;
      // String
      // String
      $3 = parseString(state);
      if (!state.ok && state.isRecoverable) {
        // Text
        // Text
        $3 = parseText(state);
      }
      $3 = endEvent<String>(CsvParserEvent.fieldEvent, $3, state.ok);
      if (!state.ok) {
        state.backtrack($4);
        break;
      }
      $2.add($3!);
      $4 = state.pos;
      // ',' ↑
      final $8 = state.pos;
      const $9 = ',';
      matchLiteral1(state, $9, const ErrorExpectedTags([$9]));
      if (state.ok) {
        state.cut(state.pos);
      }
      if (!state.ok) {
        state.backtrack($8);
      }
      if (!state.ok) {
        break;
      }
    }
    state.setOk($2.isNotEmpty);
    if (state.ok) {
      $0 = $2;
    } else {}
    $0 = endEvent<List<String>>(CsvParserEvent.rowEvent, $0, state.ok);
    return $0;
  }

  /// @event
  /// Row =
  ///   @sepBy1(Field, ',' ↑)
  ///   ;
  AsyncResult<List<String>> parseRow$Async(State<ChunkedParsingSink> state) {
    final $0 = AsyncResult<List<String>>();
    beginEvent(CsvParserEvent.rowEvent);
    List<String>? $2;
    int? $3;
    List<String>? $4;
    int? $6;
    int? $7;
    AsyncResult<String>? $8;
    int $10 = 0;
    AsyncResult<String>? $11;
    int? $13;
    int? $14;
    Object? $17;
    void $1() {
      // @sepBy1(Field, ',' ↑)
      // @sepBy1(Field, ',' ↑)
      if ($10 & 0x20 == 0) {
        $10 |= 0x20;
        $4 = [];
        $6 = state.pos;
        $3 = 0;
      }
      while (true) {
        if ($3 == 0) {
          String? $5;
          // Field
          // Field
          if ($10 & 0x8 == 0) {
            $10 |= 0x8;
            beginEvent(CsvParserEvent.fieldEvent);
          }
          // String / Text
          if ($10 & 0x4 == 0) {
            $10 |= 0x4;
            $7 = 0;
          }
          if ($7 == 0) {
            // String
            // String
            if ($10 & 0x1 == 0) {
              $10 |= 0x1;
              $8 = parseString$Async(state);
              final $9 = $8!;
              if (!$9.isComplete) {
                $9.onComplete = $1;
                return;
              }
            }
            $5 = $8!.value;
            $10 &= ~0x1 & 0xffff;
            $7 = state.ok
                ? -1
                : state.isRecoverable
                    ? 1
                    : -1;
          }
          if ($7 == 1) {
            // Text
            // Text
            if ($10 & 0x2 == 0) {
              $10 |= 0x2;
              $11 = parseText$Async(state);
              final $12 = $11!;
              if (!$12.isComplete) {
                $12.onComplete = $1;
                return;
              }
            }
            $5 = $11!.value;
            $10 &= ~0x2 & 0xffff;
            $7 = -1;
          }
          $10 &= ~0x4 & 0xffff;
          $5 = endEvent<String>(CsvParserEvent.fieldEvent, $5, state.ok);
          $10 &= ~0x8 & 0xffff;
          if (!state.ok) {
            state.backtrack($6!);
            $5 = null;
            break;
          }
          $4!.add($5!);
          $5 = null;
          $6 = state.pos;
          $3 = 1;
        }
        if ($3 == 1) {
          // ',' ↑
          if ($10 & 0x10 == 0) {
            $10 |= 0x10;
            $13 = 0;
            $14 = state.pos;
          }
          if ($13 == 0) {
            // ','
            $17 ??= state.input.beginBuffering();
            final $15 = state.input;
            if (state.pos >= $15.end && !$15.isClosed) {
              $15.sleep = true;
              $15.handle = $1;
              return;
            }
            const $16 = ',';
            matchLiteral1Async(state, $16, const ErrorExpectedTags([$16]));
            state.input.endBuffering();
            $17 = null;
            $13 = state.ok ? 1 : -1;
          }
          if ($13 == 1) {
            // ↑
            state.cut(state.pos);
            state.input.cut(state.pos);
            $13 = -1;
          }
          if (!state.ok) {
            state.backtrack($14!);
          }
          $10 &= ~0x10 & 0xffff;
          if (!state.ok) {
            break;
          }
          $3 = 0;
        }
      }
      state.setOk($4!.isNotEmpty);
      if (state.ok) {
        $2 = $4;
        $4 = null;
      }
      $10 &= ~0x20 & 0xffff;
      $2 = endEvent<List<String>>(CsvParserEvent.rowEvent, $2, state.ok);
      $0.value = $2;
      $0.isComplete = true;
      state.input.handle = $0.onComplete;
      return;
    }

    $1();
    return $0;
  }

  /// Rows =
  ///   v:@sepBy1(Row, Eol ↑)
  ///   ;
  List<List<String>>? parseRows(State<String> state) {
    List<List<String>>? $0;
    // v:@sepBy1(Row, Eol ↑)
    final $2 = <List<String>>[];
    var $4 = state.pos;
    while (true) {
      List<String>? $3;
      // Row
      // Row
      $3 = parseRow(state);
      if (!state.ok) {
        state.backtrack($4);
        break;
      }
      $2.add($3!);
      $4 = state.pos;
      // Eol ↑
      final $6 = state.pos;
      // Eol
      fastParseEol(state);
      if (state.ok) {
        state.cut(state.pos);
      }
      if (!state.ok) {
        state.backtrack($6);
      }
      if (!state.ok) {
        break;
      }
    }
    state.setOk($2.isNotEmpty);
    if (state.ok) {
      $0 = $2;
    } else {}
    return $0;
  }

  /// Rows =
  ///   v:@sepBy1(Row, Eol ↑)
  ///   ;
  AsyncResult<List<List<String>>> parseRows$Async(
      State<ChunkedParsingSink> state) {
    final $0 = AsyncResult<List<List<String>>>();
    List<List<String>>? $2;
    int? $3;
    List<List<String>>? $4;
    int? $6;
    AsyncResult<List<String>>? $7;
    int $9 = 0;
    int? $10;
    int? $11;
    AsyncResult<Object?>? $12;
    void $1() {
      // v:@sepBy1(Row, Eol ↑)
      // @sepBy1(Row, Eol ↑)
      if ($9 & 0x8 == 0) {
        $9 |= 0x8;
        $4 = [];
        $6 = state.pos;
        $3 = 0;
      }
      while (true) {
        if ($3 == 0) {
          List<String>? $5;
          // Row
          // Row
          if ($9 & 0x1 == 0) {
            $9 |= 0x1;
            $7 = parseRow$Async(state);
            final $8 = $7!;
            if (!$8.isComplete) {
              $8.onComplete = $1;
              return;
            }
          }
          $5 = $7!.value;
          $9 &= ~0x1 & 0xffff;
          if (!state.ok) {
            state.backtrack($6!);
            $5 = null;
            break;
          }
          $4!.add($5!);
          $5 = null;
          $6 = state.pos;
          $3 = 1;
        }
        if ($3 == 1) {
          // Eol ↑
          if ($9 & 0x4 == 0) {
            $9 |= 0x4;
            $10 = 0;
            $11 = state.pos;
          }
          if ($10 == 0) {
            // Eol
            if ($9 & 0x2 == 0) {
              $9 |= 0x2;
              $12 = fastParseEol$Async(state);
              final $13 = $12!;
              if (!$13.isComplete) {
                $13.onComplete = $1;
                return;
              }
            }
            $9 &= ~0x2 & 0xffff;
            $10 = state.ok ? 1 : -1;
          }
          if ($10 == 1) {
            // ↑
            state.cut(state.pos);
            state.input.cut(state.pos);
            $10 = -1;
          }
          if (!state.ok) {
            state.backtrack($11!);
          }
          $9 &= ~0x4 & 0xffff;
          if (!state.ok) {
            break;
          }
          $3 = 0;
        }
      }
      state.setOk($4!.isNotEmpty);
      if (state.ok) {
        $2 = $4;
        $4 = null;
      }
      $9 &= ~0x8 & 0xffff;
      $0.value = $2;
      $0.isComplete = true;
      state.input.handle = $0.onComplete;
      return;
    }

    $1();
    return $0;
  }

  /// @event
  /// Start =
  ///   v:Rows Eol? @eof()
  ///   ;
  List<List<String>>? parseStart(State<String> state) {
    beginEvent(CsvParserEvent.startEvent);
    List<List<String>>? $0;
    // v:Rows Eol? @eof()
    final $1 = state.pos;
    List<List<String>>? $2;
    // Rows
    $2 = parseRows(state);
    if (state.ok) {
      // Eol
      fastParseEol(state);
      if (!state.ok) {
        state.setOk(true);
      }
      if (state.ok) {
        state.ok = state.pos >= state.input.length;
        if (!state.ok) {
          state.fail(const ErrorExpectedEndOfInput());
        }
        if (state.ok) {
          $0 = $2;
        }
      }
    }
    if (!state.ok) {
      state.backtrack($1);
    }
    $0 = endEvent<List<List<String>>>(CsvParserEvent.startEvent, $0, state.ok);
    return $0;
  }

  /// @event
  /// Start =
  ///   v:Rows Eol? @eof()
  ///   ;
  AsyncResult<List<List<String>>> parseStart$Async(
      State<ChunkedParsingSink> state) {
    final $0 = AsyncResult<List<List<String>>>();
    beginEvent(CsvParserEvent.startEvent);
    List<List<String>>? $2;
    int? $4;
    int? $5;
    List<List<String>>? $3;
    AsyncResult<List<List<String>>>? $6;
    int $8 = 0;
    AsyncResult<Object?>? $9;
    void $1() {
      // v:Rows Eol? @eof()
      if ($8 & 0x4 == 0) {
        $8 |= 0x4;
        $4 = 0;
        $5 = state.pos;
      }
      if ($4 == 0) {
        // Rows
        if ($8 & 0x1 == 0) {
          $8 |= 0x1;
          $6 = parseRows$Async(state);
          final $7 = $6!;
          if (!$7.isComplete) {
            $7.onComplete = $1;
            return;
          }
        }
        $3 = $6!.value;
        $8 &= ~0x1 & 0xffff;
        $4 = state.ok ? 1 : -1;
      }
      if ($4 == 1) {
        // Eol?
        // Eol
        if ($8 & 0x2 == 0) {
          $8 |= 0x2;
          $9 = fastParseEol$Async(state);
          final $10 = $9!;
          if (!$10.isComplete) {
            $10.onComplete = $1;
            return;
          }
        }
        $8 &= ~0x2 & 0xffff;
        if (!state.ok) {
          state.setOk(true);
        }
        $4 = state.ok ? 2 : -1;
      }
      if ($4 == 2) {
        // @eof()
        final $11 = state.input;
        if (state.pos >= $11.end && !$11.isClosed) {
          $11.sleep = true;
          $11.handle = $1;
          return;
        }
        state.ok = state.pos >= $11.end;
        if (!state.ok) {
          state.fail(const ErrorExpectedEndOfInput());
        }
        $4 = -1;
      }
      if (state.ok) {
        $2 = $3;
      } else {
        state.backtrack($5!);
      }
      $8 &= ~0x4 & 0xffff;
      $2 =
          endEvent<List<List<String>>>(CsvParserEvent.startEvent, $2, state.ok);
      $0.value = $2;
      $0.isComplete = true;
      state.input.handle = $0.onComplete;
      return;
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
    final $1 = state.pos;
    // @inline OpenQuote = Spaces '"' ;
    // Spaces '"'
    final $3 = state.pos;
    // Spaces
    fastParseSpaces(state);
    if (state.ok) {
      const $4 = '"';
      matchLiteral1(state, $4, const ErrorExpectedTags([$4]));
    }
    if (!state.ok) {
      state.backtrack($3);
    }
    if (state.ok) {
      state.cut(state.pos);
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
              final $11 = state.input.runeAt(state.pos);
              state.ok = $11 != 34;
              if (state.ok) {
                state.pos += $11 > 0xffff ? 2 : 1;
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
          state.setOk($10);
          if (state.ok) {
            $7 = state.input.substring($9, state.pos);
          }
          if (!state.ok && state.isRecoverable) {
            // '""' <String>{}
            const $13 = '""';
            matchLiteral2(state, $13, const ErrorExpectedTags([$13]));
            if (state.ok) {
              String? $$;
              $$ = '"';
              $7 = $$;
            }
          }
          if (!state.ok) {
            break;
          }
          $6.add($7!);
        }
        state.setOk(true);
        if (state.ok) {
          $2 = $6;
        }
        if (state.ok) {
          // @inline CloseQuote = '"' Spaces ;
          // '"' Spaces
          final $14 = state.pos;
          const $15 = '"';
          matchLiteral1(state, $15, const ErrorExpectedTags([$15]));
          if (state.ok) {
            // Spaces
            fastParseSpaces(state);
          }
          if (!state.ok) {
            state.backtrack($14);
          }
          if (state.ok) {
            String? $$;
            final v = $2!;
            $$ = v.join();
            $0 = $$;
          }
        }
      }
    }
    if (!state.ok) {
      state.backtrack($1);
    }
    return $0;
  }

  /// String
  /// String =
  ///   OpenQuote ↑ v:Chars CloseQuote {}
  ///   ;
  AsyncResult<String> parseString$Async(State<ChunkedParsingSink> state) {
    final $0 = AsyncResult<String>();
    String? $2;
    int? $4;
    int? $5;
    int? $6;
    int? $7;
    AsyncResult<Object?>? $8;
    int $10 = 0;
    Object? $13;
    List<String>? $3;
    List<String>? $14;
    String? $15;
    int? $16;
    int? $17;
    bool? $18;
    Object? $23;
    int? $24;
    int? $25;
    Object? $28;
    AsyncResult<Object?>? $29;
    void $1() {
      // OpenQuote ↑ v:Chars CloseQuote {}
      if ($10 & 0x40 == 0) {
        $10 |= 0x40;
        $4 = 0;
        $5 = state.pos;
      }
      if ($4 == 0) {
        // OpenQuote
        // Spaces '"'
        // Spaces '"'
        if ($10 & 0x2 == 0) {
          $10 |= 0x2;
          $6 = 0;
          $7 = state.pos;
        }
        if ($6 == 0) {
          // Spaces
          if ($10 & 0x1 == 0) {
            $10 |= 0x1;
            $8 = fastParseSpaces$Async(state);
            final $9 = $8!;
            if (!$9.isComplete) {
              $9.onComplete = $1;
              return;
            }
          }
          $10 &= ~0x1 & 0xffff;
          $6 = state.ok ? 1 : -1;
        }
        if ($6 == 1) {
          // '"'
          $13 ??= state.input.beginBuffering();
          final $11 = state.input;
          if (state.pos >= $11.end && !$11.isClosed) {
            $11.sleep = true;
            $11.handle = $1;
            return;
          }
          const $12 = '"';
          matchLiteral1Async(state, $12, const ErrorExpectedTags([$12]));
          state.input.endBuffering();
          $13 = null;
          $6 = -1;
        }
        if (!state.ok) {
          state.backtrack($7!);
        }
        $10 &= ~0x2 & 0xffff;
        $4 = state.ok ? 1 : -1;
      }
      if ($4 == 1) {
        // ↑
        state.cut(state.pos);
        state.input.cut(state.pos);
        $4 = state.ok ? 2 : -1;
      }
      if ($4 == 2) {
        // Chars
        // ($[^"]+ / '""' <String>{})*
        // ($[^"]+ / '""' <String>{})*
        // ($[^"]+ / '""' <String>{})*
        $14 ??= [];
        while (true) {
          // ($[^"]+ / '""' <String>{})
          // $[^"]+ / '""' <String>{}
          if ($10 & 0x8 == 0) {
            $10 |= 0x8;
            $16 = 0;
          }
          if ($16 == 0) {
            // $[^"]+
            // $[^"]+
            if ($10 & 0x4 == 0) {
              $10 |= 0x4;
              state.input.beginBuffering();
              $17 = state.pos;
            }
            // [^"]+
            $18 ??= false;
            while (true) {
              // [^"]
              final $20 = state.input;
              if (state.pos >= $20.end && !$20.isClosed) {
                $20.sleep = true;
                $20.handle = $1;
                return;
              }
              final $19 = readChar32Async(state);
              if ($19 >= 0) {
                state.ok = $19 != 34;
                if (state.ok) {
                  state.pos += $19 > 0xffff ? 2 : 1;
                } else {
                  state.fail(const ErrorUnexpectedCharacter());
                }
              }
              if (!state.ok) {
                break;
              }
              $18 = true;
            }
            state.setOk($18!);
            $18 = null;
            if (state.ok) {
              final input = state.input;
              final start = input.start;
              final pos = $17!;
              $15 = input.data.substring(pos - start, state.pos - start);
            }
            state.input.endBuffering();
            $10 &= ~0x4 & 0xffff;
            $16 = state.ok
                ? -1
                : state.isRecoverable
                    ? 1
                    : -1;
          }
          if ($16 == 1) {
            // '""' <String>{}
            // '""'
            $23 ??= state.input.beginBuffering();
            final $21 = state.input;
            if (state.pos + 1 >= $21.end && !$21.isClosed) {
              $21.sleep = true;
              $21.handle = $1;
              return;
            }
            const $22 = '""';
            matchLiteral2Async(state, $22, const ErrorExpectedTags([$22]));
            state.input.endBuffering();
            $23 = null;
            if (state.ok) {
              String? $$;
              $$ = '"';
              $15 = $$;
            }
            $16 = -1;
          }
          $10 &= ~0x8 & 0xffff;
          if (!state.ok) {
            $15 = null;
            break;
          }
          $14!.add($15!);
          $15 = null;
        }
        state.setOk(true);
        if (state.ok) {
          $3 = $14;
        }
        $14 = null;
        $14 = null;
        $4 = state.ok ? 3 : -1;
      }
      if ($4 == 3) {
        // CloseQuote
        // '"' Spaces
        // '"' Spaces
        if ($10 & 0x20 == 0) {
          $10 |= 0x20;
          $24 = 0;
          $25 = state.pos;
        }
        if ($24 == 0) {
          // '"'
          $28 ??= state.input.beginBuffering();
          final $26 = state.input;
          if (state.pos >= $26.end && !$26.isClosed) {
            $26.sleep = true;
            $26.handle = $1;
            return;
          }
          const $27 = '"';
          matchLiteral1Async(state, $27, const ErrorExpectedTags([$27]));
          state.input.endBuffering();
          $28 = null;
          $24 = state.ok ? 1 : -1;
        }
        if ($24 == 1) {
          // Spaces
          if ($10 & 0x10 == 0) {
            $10 |= 0x10;
            $29 = fastParseSpaces$Async(state);
            final $30 = $29!;
            if (!$30.isComplete) {
              $30.onComplete = $1;
              return;
            }
          }
          $10 &= ~0x10 & 0xffff;
          $24 = -1;
        }
        if (!state.ok) {
          state.backtrack($25!);
        }
        $10 &= ~0x20 & 0xffff;
        $4 = -1;
      }
      if (state.ok) {
        String? $$;
        final v = $3!;
        $$ = v.join();
        $2 = $$;
      } else {
        state.backtrack($5!);
      }
      $10 &= ~0x40 & 0xffff;
      $0.value = $2;
      $0.isComplete = true;
      state.input.handle = $0.onComplete;
      return;
    }

    $1();
    return $0;
  }

  /// Text =
  ///   $[^,"\n\r]*
  ///   ;
  String? parseText(State<String> state) {
    String? $0;
    // $[^,"\n\r]*
    final $2 = state.pos;
    while (true) {
      state.ok = state.pos < state.input.length;
      if (state.ok) {
        final $3 = state.input.runeAt(state.pos);
        state.ok = !($3 == 13 || $3 == 10 || $3 == 34 || $3 == 44);
        if (state.ok) {
          state.pos += $3 > 0xffff ? 2 : 1;
        } else {
          state.fail(const ErrorUnexpectedCharacter());
        }
      } else {
        state.fail(const ErrorUnexpectedEndOfInput());
      }
      if (!state.ok) {
        break;
      }
    }
    state.setOk(true);
    if (state.ok) {
      $0 = state.input.substring($2, state.pos);
    }
    return $0;
  }

  /// Text =
  ///   $[^,"\n\r]*
  ///   ;
  AsyncResult<String> parseText$Async(State<ChunkedParsingSink> state) {
    final $0 = AsyncResult<String>();
    String? $2;
    int? $3;
    int $6 = 0;
    void $1() {
      // $[^,"\n\r]*
      // $[^,"\n\r]*
      if ($6 & 0x1 == 0) {
        $6 |= 0x1;
        state.input.beginBuffering();
        $3 = state.pos;
      }
      // [^,"\n\r]*
      while (true) {
        // [^,"\n\r]
        final $5 = state.input;
        if (state.pos >= $5.end && !$5.isClosed) {
          $5.sleep = true;
          $5.handle = $1;
          return;
        }
        final $4 = readChar32Async(state);
        if ($4 >= 0) {
          state.ok = !($4 == 13 || $4 == 10 || $4 == 34 || $4 == 44);
          if (state.ok) {
            state.pos += $4 > 0xffff ? 2 : 1;
          } else {
            state.fail(const ErrorUnexpectedCharacter());
          }
        }
        if (!state.ok) {
          break;
        }
      }
      state.setOk(true);
      if (state.ok) {
        final input = state.input;
        final start = input.start;
        final pos = $3!;
        $2 = input.data.substring(pos - start, state.pos - start);
      }
      state.input.endBuffering();
      $6 &= ~0x1 & 0xffff;
      $0.value = $2;
      $0.isComplete = true;
      state.input.handle = $0.onComplete;
      return;
    }

    $1();
    return $0;
  }

  @pragma('vm:prefer-inline')
  @pragma('dart2js:tryInline')
  int readChar16Async(State<ChunkedParsingSink> state) {
    final input = state.input;
    final start = input.start;
    final pos = state.pos;
    if (pos < input.end) {
      return input.data.codeUnitAt(pos - start);
    } else {
      state.fail(const ErrorUnexpectedEndOfInput());
    }
    return -1;
  }

  @pragma('vm:prefer-inline')
  @pragma('dart2js:tryInline')
  int readChar32Async(State<ChunkedParsingSink> state) {
    final input = state.input;
    final start = input.start;
    final pos = state.pos;
    if (pos < input.end) {
      return input.data.runeAt(pos - start);
    } else {
      state.fail(const ErrorUnexpectedEndOfInput());
    }
    return -1;
  }
}

enum CsvParserEvent { startEvent, fieldEvent, rowEvent }

void fastParseString(
    void Function(State<String> state) fastParse, String source) {
  final result = tryParse(fastParse, source);
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

O parseString<O>(O? Function(State<String> state) parse, String source) {
  final result = tryParse(parse, source);
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
      errors.map((e) => e.length < 0 ? offset - e.length : offset).toSet();
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

    if (this.data.isEmpty) {
      this.data = data;
    } else {
      this.data = '${this.data}$data';
    }

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
      if (_cuttingPosition == end) {
        this.data = '';
      } else {
        this.data = this.data.substring(_cuttingPosition - start);
      }

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
        if (offset >= input.start && offset <= input.end) {
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
  Object? context;

  int cuttingPos = 0;

  final List<ParseError?> errors = List.filled(64, null, growable: false);

  int errorCount = 0;

  int failPos = 0;

  final T input;

  bool isRecoverable = true;

  bool ok = false;

  int pos = 0;

  State(this.input);

  @pragma('vm:prefer-inline')
  @pragma('dart2js:tryInline')
  void backtrack(int pos) {
    if (pos >= cuttingPos) {
      this.pos = pos;
      return;
    }
    isRecoverable = false;
  }

  @pragma('vm:prefer-inline')
  @pragma('dart2js:tryInline')
  // ignore: unused_element
  bool canHandleError(int failPos, int errorCount) {
    return failPos == this.failPos
        ? errorCount < this.errorCount
        : failPos < this.failPos;
  }

  @pragma('vm:prefer-inline')
  @pragma('dart2js:tryInline')
  void cut(int pos) {
    if (cuttingPos < pos) {
      cuttingPos = pos;
    }
  }

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

  @pragma('vm:prefer-inline')
  @pragma('dart2js:tryInline')
  // ignore: unused_element
  void rollbackErrors(int failPos, int errorCount) {
    if (this.failPos == failPos) {
      this.errorCount = errorCount;
    } else if (this.failPos > failPos) {
      this.errorCount = 0;
    }
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
        return '$pos:';
      }
      var length = input.length - pos;
      length = length > 40 ? 40 : length;
      final string = input.substring(pos, pos + length);
      return '$pos:$string';
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
