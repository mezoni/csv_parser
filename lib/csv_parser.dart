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
    int $9 = 0;
    void $1() {
      if ($9 & 0x1 == 0) {
        $9 |= 0x1;
        $2 = 0;
      }
      if ($2 == 0) {
        // '\n'
        // '\n'
        final $3 = state.input;
        if (state.pos >= $3.end && !$3.isClosed) {
          $3.sleep = true;
          $3.handle = $1;
          return;
        }
        const $4 = '\n';
        matchLiteral1Async(state, $4, const ErrorExpectedTags([$4]));
        $2 = state.ok
            ? -1
            : state.isRecoverable
                ? 1
                : -1;
      }
      if ($2 == 1) {
        // '\r\n'
        // '\r\n'
        final $5 = state.input;
        if (state.pos + 1 >= $5.end && !$5.isClosed) {
          $5.sleep = true;
          $5.handle = $1;
          return;
        }
        const $6 = '\r\n';
        matchLiteral2Async(state, $6, const ErrorExpectedTags([$6]));
        $2 = state.ok
            ? -1
            : state.isRecoverable
                ? 2
                : -1;
      }
      if ($2 == 2) {
        // '\r'
        // '\r'
        final $7 = state.input;
        if (state.pos >= $7.end && !$7.isClosed) {
          $7.sleep = true;
          $7.handle = $1;
          return;
        }
        const $8 = '\r';
        matchLiteral1Async(state, $8, const ErrorExpectedTags([$8]));
        $2 = -1;
      }
      $9 &= ~0x1 & 0xffff;
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
    void $1() {
      // [ \t]*
      // [ \t]*
      while (true) {
        // [ \t]
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
  ///   @list1(Field, ',' ↑ v:Field)
  ///   ;
  List<String>? parseRow(State<String> state) {
    beginEvent(CsvParserEvent.rowEvent);
    List<String>? $0;
    // @list1(Field, ',' ↑ v:Field)
    final $2 = <String>[];
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
    if (state.ok) {
      $2.add($3!);
      while (true) {
        String? $4;
        // ',' ↑ v:Field
        final $11 = state.pos;
        var $10 = true;
        const $12 = ',';
        matchLiteral1(state, $12, const ErrorExpectedTags([$12]));
        if (state.ok) {
          $10 = false;
          state.ok = true;
          if (state.ok) {
            String? $9;
            beginEvent(CsvParserEvent.fieldEvent);
            // @event @inline Field = String / Text ;
            // String
            // String
            $9 = parseString(state);
            if (!state.ok && state.isRecoverable) {
              // Text
              // Text
              $9 = parseText(state);
            }
            $9 = endEvent<String>(CsvParserEvent.fieldEvent, $9, state.ok);
            if (state.ok) {
              $4 = $9;
            }
          }
        }
        if (!state.ok) {
          if (!$10) {
            state.isRecoverable = false;
          }
          state.backtrack($11);
        }
        if (!state.ok) {
          break;
        }
        $2.add($4!);
      }
    }
    state.setOk($2.isNotEmpty);
    if (state.ok) {
      $0 = $2;
    }
    $0 = endEvent<List<String>>(CsvParserEvent.rowEvent, $0, state.ok);
    return $0;
  }

  /// @event
  /// Row =
  ///   @list1(Field, ',' ↑ v:Field)
  ///   ;
  AsyncResult<List<String>> parseRow$Async(State<ChunkedParsingSink> state) {
    final $0 = AsyncResult<List<String>>();
    beginEvent(CsvParserEvent.rowEvent);
    List<String>? $2;
    int? $3;
    int? $4;
    List<String>? $5;
    int? $8;
    AsyncResult<String>? $9;
    int $11 = 0;
    AsyncResult<String>? $12;
    int? $15;
    int? $16;
    bool? $17;
    String? $14;
    int? $20;
    AsyncResult<String>? $21;
    AsyncResult<String>? $23;
    void $1() {
      // @list1(Field, ',' ↑ v:Field)
      // @list1(Field, ',' ↑ v:Field)
      if ($3 == null) {
        $3 = state.pos;
        $4 = 0;
        $5 = [];
      }
      while (true) {
        if ($4 == 0) {
          String? $6;
          // Field
          // Field
          if ($11 & 0x8 == 0) {
            $11 |= 0x8;
            beginEvent(CsvParserEvent.fieldEvent);
          }
          // String / Text
          if ($11 & 0x4 == 0) {
            $11 |= 0x4;
            $8 = 0;
          }
          if ($8 == 0) {
            // String
            // String
            if ($11 & 0x1 == 0) {
              $11 |= 0x1;
              $9 = parseString$Async(state);
              final $10 = $9!;
              if (!$10.isComplete) {
                $10.onComplete = $1;
                return;
              }
            }
            $6 = $9!.value;
            $11 &= ~0x1 & 0xffff;
            $8 = state.ok
                ? -1
                : state.isRecoverable
                    ? 1
                    : -1;
          }
          if ($8 == 1) {
            // Text
            // Text
            if ($11 & 0x2 == 0) {
              $11 |= 0x2;
              $12 = parseText$Async(state);
              final $13 = $12!;
              if (!$13.isComplete) {
                $13.onComplete = $1;
                return;
              }
            }
            $6 = $12!.value;
            $11 &= ~0x2 & 0xffff;
            $8 = -1;
          }
          $11 &= ~0x4 & 0xffff;
          $6 = endEvent<String>(CsvParserEvent.fieldEvent, $6, state.ok);
          $11 &= ~0x8 & 0xffff;
          if (!state.ok) {
            break;
          }
          $5!.add($6!);
          $6 = null;
          $4 = 1;
        }
        if ($4 == 1) {
          String? $7;
          // ',' ↑ v:Field
          if ($11 & 0x100 == 0) {
            $11 |= 0x100;
            $15 = 0;
            $16 = state.pos;
            $17 = true;
          }
          if ($15 == 0) {
            // ','
            final $18 = state.input;
            if (state.pos >= $18.end && !$18.isClosed) {
              $18.sleep = true;
              $18.handle = $1;
              return;
            }
            const $19 = ',';
            matchLiteral1Async(state, $19, const ErrorExpectedTags([$19]));
            $15 = state.ok ? 1 : -1;
          }
          if ($15 == 1) {
            $17 = false;
            // ↑
            state.ok = true;
            state.input.cut(state.pos);
            $15 = state.ok ? 2 : -1;
          }
          if ($15 == 2) {
            // Field
            if ($11 & 0x80 == 0) {
              $11 |= 0x80;
              beginEvent(CsvParserEvent.fieldEvent);
            }
            // String / Text
            if ($11 & 0x40 == 0) {
              $11 |= 0x40;
              $20 = 0;
            }
            if ($20 == 0) {
              // String
              // String
              if ($11 & 0x10 == 0) {
                $11 |= 0x10;
                $21 = parseString$Async(state);
                final $22 = $21!;
                if (!$22.isComplete) {
                  $22.onComplete = $1;
                  return;
                }
              }
              $14 = $21!.value;
              $11 &= ~0x10 & 0xffff;
              $20 = state.ok
                  ? -1
                  : state.isRecoverable
                      ? 1
                      : -1;
            }
            if ($20 == 1) {
              // Text
              // Text
              if ($11 & 0x20 == 0) {
                $11 |= 0x20;
                $23 = parseText$Async(state);
                final $24 = $23!;
                if (!$24.isComplete) {
                  $24.onComplete = $1;
                  return;
                }
              }
              $14 = $23!.value;
              $11 &= ~0x20 & 0xffff;
              $20 = -1;
            }
            $11 &= ~0x40 & 0xffff;
            $14 = endEvent<String>(CsvParserEvent.fieldEvent, $14, state.ok);
            $11 &= ~0x80 & 0xffff;
            $15 = -1;
          }
          if (state.ok) {
            $7 = $14;
          } else {
            if (!$17!) {
              state.isRecoverable = false;
            }
            state.backtrack($16!);
          }
          $11 &= ~0x100 & 0xffff;
          if (!state.ok) {
            $4 = -1;
            break;
          }
          $5!.add($7!);
          $7 = null;
        }
      }
      state.setOk($5!.isNotEmpty);
      if (state.ok) {
        $2 = $5;
        $5 = null;
      }
      $3 = null;
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
      while (true) {
        List<String>? $4;
        // RowEnding ↑ v:Row
        final $9 = state.pos;
        var $8 = true;
        // @inline RowEnding = Eol !@eof() ;
        // Eol !@eof()
        final $10 = state.pos;
        // Eol
        fastParseEol(state);
        if (state.ok) {
          final $11 = state.pos;
          state.ok = state.pos >= state.input.length;
          if (!state.ok) {
            state.fail(const ErrorExpectedEndOfInput());
          }
          state.setOk(!state.ok);
          if (!state.ok) {
            final length = $11 - state.pos;
            state.fail(switch (length) {
              0 => const ErrorUnexpectedInput(0),
              1 => const ErrorUnexpectedInput(-1),
              2 => const ErrorUnexpectedInput(-2),
              _ => ErrorUnexpectedInput(length)
            });
            state.backtrack($11);
          }
        }
        if (!state.ok) {
          state.backtrack($10);
        }
        if (state.ok) {
          $8 = false;
          state.ok = true;
          if (state.ok) {
            List<String>? $7;
            // Row
            $7 = parseRow(state);
            if (state.ok) {
              $4 = $7;
            }
          }
        }
        if (!state.ok) {
          if (!$8) {
            state.isRecoverable = false;
          }
          state.backtrack($9);
        }
        if (!state.ok) {
          break;
        }
        $2.add($4!);
      }
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
    int? $3;
    int? $4;
    List<List<String>>? $5;
    AsyncResult<List<String>>? $8;
    int $10 = 0;
    int? $12;
    int? $13;
    bool? $14;
    int? $15;
    int? $16;
    AsyncResult<Object?>? $17;
    int? $19;
    List<String>? $11;
    AsyncResult<List<String>>? $21;
    void $1() {
      // v:@list1(Row, RowEnding ↑ v:Row)
      // @list1(Row, RowEnding ↑ v:Row)
      if ($3 == null) {
        $3 = state.pos;
        $4 = 0;
        $5 = [];
      }
      while (true) {
        if ($4 == 0) {
          List<String>? $6;
          // Row
          // Row
          if ($10 & 0x1 == 0) {
            $10 |= 0x1;
            $8 = parseRow$Async(state);
            final $9 = $8!;
            if (!$9.isComplete) {
              $9.onComplete = $1;
              return;
            }
          }
          $6 = $8!.value;
          $10 &= ~0x1 & 0xffff;
          if (!state.ok) {
            break;
          }
          $5!.add($6!);
          $6 = null;
          $4 = 1;
        }
        if ($4 == 1) {
          List<String>? $7;
          // RowEnding ↑ v:Row
          if ($10 & 0x10 == 0) {
            $10 |= 0x10;
            $12 = 0;
            $13 = state.pos;
            $14 = true;
          }
          if ($12 == 0) {
            // RowEnding
            // Eol !@eof()
            // Eol !@eof()
            if ($10 & 0x4 == 0) {
              $10 |= 0x4;
              $15 = 0;
              $16 = state.pos;
            }
            if ($15 == 0) {
              // Eol
              if ($10 & 0x2 == 0) {
                $10 |= 0x2;
                $17 = fastParseEol$Async(state);
                final $18 = $17!;
                if (!$18.isComplete) {
                  $18.onComplete = $1;
                  return;
                }
              }
              $10 &= ~0x2 & 0xffff;
              $15 = state.ok ? 1 : -1;
            }
            if ($15 == 1) {
              // !@eof()
              if ($19 == null) {
                $19 = state.pos;
                state.input.beginBuffering();
              }
              // @eof()
              final $20 = state.input;
              if (state.pos >= $20.end && !$20.isClosed) {
                $20.sleep = true;
                $20.handle = $1;
                return;
              }
              state.ok = state.pos >= $20.end;
              if (!state.ok) {
                state.fail(const ErrorExpectedEndOfInput());
              }
              state.setOk(!state.ok);
              if (!state.ok) {
                final length = $19! - state.pos;
                state.fail(switch (length) {
                  0 => const ErrorUnexpectedInput(0),
                  1 => const ErrorUnexpectedInput(-1),
                  2 => const ErrorUnexpectedInput(-2),
                  _ => ErrorUnexpectedInput(length)
                });
                state.backtrack($19!);
              }
              state.input.endBuffering();
              $19 = null;
              $15 = -1;
            }
            if (!state.ok) {
              state.backtrack($16!);
            }
            $10 &= ~0x4 & 0xffff;
            $12 = state.ok ? 1 : -1;
          }
          if ($12 == 1) {
            $14 = false;
            // ↑
            state.ok = true;
            state.input.cut(state.pos);
            $12 = state.ok ? 2 : -1;
          }
          if ($12 == 2) {
            // Row
            if ($10 & 0x8 == 0) {
              $10 |= 0x8;
              $21 = parseRow$Async(state);
              final $22 = $21!;
              if (!$22.isComplete) {
                $22.onComplete = $1;
                return;
              }
            }
            $11 = $21!.value;
            $10 &= ~0x8 & 0xffff;
            $12 = -1;
          }
          if (state.ok) {
            $7 = $11;
          } else {
            if (!$14!) {
              state.isRecoverable = false;
            }
            state.backtrack($13!);
          }
          $10 &= ~0x10 & 0xffff;
          if (!state.ok) {
            $4 = -1;
            break;
          }
          $5!.add($7!);
          $7 = null;
        }
      }
      state.setOk($5!.isNotEmpty);
      if (state.ok) {
        $2 = $5;
        $5 = null;
      }
      $3 = null;
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
    final $2 = state.pos;
    List<List<String>>? $1;
    // Rows
    $1 = parseRows(state);
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
          $0 = $1;
        }
      }
    }
    if (!state.ok) {
      state.backtrack($2);
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
    final $3 = state.pos;
    var $2 = true;
    // @inline OpenQuote = Spaces '"' ;
    // Spaces '"'
    final $4 = state.pos;
    // Spaces
    fastParseSpaces(state);
    if (state.ok) {
      const $5 = '"';
      matchLiteral1(state, $5, const ErrorExpectedTags([$5]));
    }
    if (!state.ok) {
      state.backtrack($4);
    }
    if (state.ok) {
      $2 = false;
      state.ok = true;
      if (state.ok) {
        List<String>? $1;
        // @inline Chars = ($[^"]+ / '""' <String>{})* ;
        // ($[^"]+ / '""' <String>{})*
        final $7 = <String>[];
        while (true) {
          String? $8;
          // $[^"]+
          final $10 = state.pos;
          var $11 = false;
          while (true) {
            state.ok = state.pos < state.input.length;
            if (state.ok) {
              final $12 = state.input.runeAt(state.pos);
              state.ok = $12 != 34;
              if (state.ok) {
                state.pos += $12 > 0xffff ? 2 : 1;
              } else {
                state.fail(const ErrorUnexpectedCharacter());
              }
            } else {
              state.fail(const ErrorUnexpectedEndOfInput());
            }
            if (!state.ok) {
              break;
            }
            $11 = true;
          }
          state.setOk($11);
          if (state.ok) {
            $8 = state.input.substring($10, state.pos);
          }
          if (!state.ok && state.isRecoverable) {
            // '""' <String>{}
            const $14 = '""';
            matchLiteral2(state, $14, const ErrorExpectedTags([$14]));
            if (state.ok) {
              String? $$;
              $$ = '"';
              $8 = $$;
            }
          }
          if (!state.ok) {
            break;
          }
          $7.add($8!);
        }
        state.setOk(true);
        if (state.ok) {
          $1 = $7;
        }
        if (state.ok) {
          // @inline CloseQuote = '"' Spaces ;
          // '"' Spaces
          final $15 = state.pos;
          const $16 = '"';
          matchLiteral1(state, $16, const ErrorExpectedTags([$16]));
          if (state.ok) {
            // Spaces
            fastParseSpaces(state);
          }
          if (!state.ok) {
            state.backtrack($15);
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
      state.backtrack($3);
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
    bool? $6;
    int? $7;
    int? $8;
    AsyncResult<Object?>? $9;
    int $11 = 0;
    List<String>? $3;
    List<String>? $14;
    String? $15;
    int? $16;
    int? $17;
    bool? $18;
    int? $23;
    int? $24;
    AsyncResult<Object?>? $27;
    void $1() {
      // OpenQuote ↑ v:Chars CloseQuote {}
      if ($11 & 0x40 == 0) {
        $11 |= 0x40;
        $4 = 0;
        $5 = state.pos;
        $6 = true;
      }
      if ($4 == 0) {
        // OpenQuote
        // Spaces '"'
        // Spaces '"'
        if ($11 & 0x2 == 0) {
          $11 |= 0x2;
          $7 = 0;
          $8 = state.pos;
        }
        if ($7 == 0) {
          // Spaces
          if ($11 & 0x1 == 0) {
            $11 |= 0x1;
            $9 = fastParseSpaces$Async(state);
            final $10 = $9!;
            if (!$10.isComplete) {
              $10.onComplete = $1;
              return;
            }
          }
          $11 &= ~0x1 & 0xffff;
          $7 = state.ok ? 1 : -1;
        }
        if ($7 == 1) {
          // '"'
          final $12 = state.input;
          if (state.pos >= $12.end && !$12.isClosed) {
            $12.sleep = true;
            $12.handle = $1;
            return;
          }
          const $13 = '"';
          matchLiteral1Async(state, $13, const ErrorExpectedTags([$13]));
          $7 = -1;
        }
        if (!state.ok) {
          state.backtrack($8!);
        }
        $11 &= ~0x2 & 0xffff;
        $4 = state.ok ? 1 : -1;
      }
      if ($4 == 1) {
        $6 = false;
        // ↑
        state.ok = true;
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
          if ($11 & 0x8 == 0) {
            $11 |= 0x8;
            $16 = 0;
          }
          if ($16 == 0) {
            // $[^"]+
            // $[^"]+
            if ($11 & 0x4 == 0) {
              $11 |= 0x4;
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
            $11 &= ~0x4 & 0xffff;
            $16 = state.ok
                ? -1
                : state.isRecoverable
                    ? 1
                    : -1;
          }
          if ($16 == 1) {
            // '""' <String>{}
            // '""'
            final $21 = state.input;
            if (state.pos + 1 >= $21.end && !$21.isClosed) {
              $21.sleep = true;
              $21.handle = $1;
              return;
            }
            const $22 = '""';
            matchLiteral2Async(state, $22, const ErrorExpectedTags([$22]));
            if (state.ok) {
              String? $$;
              $$ = '"';
              $15 = $$;
            }
            $16 = -1;
          }
          $11 &= ~0x8 & 0xffff;
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
        if ($11 & 0x20 == 0) {
          $11 |= 0x20;
          $23 = 0;
          $24 = state.pos;
        }
        if ($23 == 0) {
          // '"'
          final $25 = state.input;
          if (state.pos >= $25.end && !$25.isClosed) {
            $25.sleep = true;
            $25.handle = $1;
            return;
          }
          const $26 = '"';
          matchLiteral1Async(state, $26, const ErrorExpectedTags([$26]));
          $23 = state.ok ? 1 : -1;
        }
        if ($23 == 1) {
          // Spaces
          if ($11 & 0x10 == 0) {
            $11 |= 0x10;
            $27 = fastParseSpaces$Async(state);
            final $28 = $27!;
            if (!$28.isComplete) {
              $28.onComplete = $1;
              return;
            }
          }
          $11 &= ~0x10 & 0xffff;
          $23 = -1;
        }
        if (!state.ok) {
          state.backtrack($24!);
        }
        $11 &= ~0x20 & 0xffff;
        $4 = -1;
      }
      if (state.ok) {
        String? $$;
        final v = $3!;
        $$ = v.join();
        $2 = $$;
      } else {
        if (!$6!) {
          state.isRecoverable = false;
        }
        state.backtrack($5!);
      }
      $11 &= ~0x40 & 0xffff;
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
  final List<ParseError?> errors = List.filled(64, null, growable: false);

  int errorCount = 0;

  int failPos = 0;

  final T input;

  bool isRecoverable = true;

  int lastFailPos = -1;

  bool ok = false;

  int pos = 0;

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
    ok = false;
    if (lastFailPos < pos) {
      lastFailPos = pos;
    }

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
    if (lastFailPos < pos) {
      lastFailPos = pos;
    }

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
    if (lastFailPos < pos) {
      lastFailPos = pos;
    }

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
    if (lastFailPos < pos) {
      lastFailPos = pos;
    }

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
