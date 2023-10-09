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
    Object? $4;
    Object? $6;
    Object? $8;
    int $9 = 0;
    void $1() {
      if ($9 & 0x1 == 0) {
        $9 |= 0x1;
        $2 = 0;
      }
      if ($2 == 0) {
        // '\n'
        // '\n'
        $4 ??= state.input.beginBuffering();
        final $3 = state.input;
        if (state.pos + 1 < $3.end || $3.isClosed) {
          matchLiteral1Async(state, 10, '\n', const ErrorExpectedTags(['\n']));
        } else {
          $3.sleep = true;
          $3.handle = $1;
          return;
        }
        state.input.endBuffering(state.pos);
        $4 = null;
        $2 = state.ok ? -1 : 1;
      }
      if ($2 == 1) {
        // '\r\n'
        // '\r\n'
        $6 ??= state.input.beginBuffering();
        final $5 = state.input;
        if (state.pos + 1 < $5.end || $5.isClosed) {
          const string = '\r\n';
          matchLiteralAsync(state, string, const ErrorExpectedTags([string]));
        } else {
          $5.sleep = true;
          $5.handle = $1;
          return;
        }
        state.input.endBuffering(state.pos);
        $6 = null;
        $2 = state.ok ? -1 : 2;
      }
      if ($2 == 2) {
        // '\r'
        // '\r'
        $8 ??= state.input.beginBuffering();
        final $7 = state.input;
        if (state.pos + 1 < $7.end || $7.isClosed) {
          matchLiteral1Async(state, 13, '\r', const ErrorExpectedTags(['\r']));
        } else {
          $7.sleep = true;
          $7.handle = $1;
          return;
        }
        state.input.endBuffering(state.pos);
        $8 = null;
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
    final $2 = state.input;
    while (state.pos < $2.length) {
      final $1 = $2.codeUnitAt(state.pos);
      state.ok = $1 == 9 || $1 == 32;
      if (!state.ok) {
        break;
      }
      state.pos++;
    }
    state.fail(const ErrorUnexpectedCharacter());
    state.ok = true;
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
        $4 ??= state.input.beginBuffering();
        // [ \t]
        final $3 = state.input;
        final $2 = readChar16Async(state);
        switch ($2) {
          case null:
            $3.sleep = true;
            $3.handle = $1;
            return;
          case >= 0:
            state.ok = $2 == 9 || $2 == 32;
            if (state.ok) {
              state.pos++;
            } else {
              state.fail(const ErrorUnexpectedCharacter());
            }
        }
        state.input.endBuffering(state.pos);
        $4 = null;
        if (!state.ok) {
          break;
        }
      }
      state.ok = true;
      $0.isComplete = true;
      state.input.handle = $0.onComplete;
      return;
    }

    $1();
    return $0;
  }

  /// @event
  /// Row =
  ///   @sepBy(Field, ',')
  ///   ;
  List<String>? parseRow(State<String> state) {
    beginEvent(CsvParserEvent.rowEvent);
    List<String>? $0;
    // @sepBy(Field, ',')
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
      if (!state.ok) {
        // Text
        // Text
        $3 = parseText(state);
      }
      $3 = endEvent<String>(CsvParserEvent.fieldEvent, $3, state.ok);
      if (!state.ok) {
        state.pos = $4;
        break;
      }
      $2.add($3!);
      $4 = state.pos;
      // ','
      const $9 = ',';
      state.ok = state.pos < state.input.length &&
          state.input.codeUnitAt(state.pos) == 44;
      if (state.ok) {
        state.pos++;
      } else {
        state.fail(const ErrorExpectedTags([$9]));
      }
      if (!state.ok) {
        break;
      }
    }
    state.ok = true;
    if (state.ok) {
      $0 = $2;
    }
    $0 = endEvent<List<String>>(CsvParserEvent.rowEvent, $0, state.ok);
    return $0;
  }

  /// @event
  /// Row =
  ///   @sepBy(Field, ',')
  ///   ;
  AsyncResult<List<String>> parseRow$Async(State<ChunkedParsingSink> state) {
    final $0 = AsyncResult<List<String>>();
    beginEvent(CsvParserEvent.rowEvent);
    List<String>? $2;
    Object? $3;
    Object? $4;
    int? $5;
    List<String>? $6;
    int? $8;
    int? $9;
    AsyncResult<String>? $10;
    int $12 = 0;
    AsyncResult<String>? $13;
    Object? $16;
    void $1() {
      // @sepBy(Field, ',')
      // @sepBy(Field, ',')
      if ($3 == null) {
        $3 = true;
        state.input.beginBuffering();
        $6 = [];
        $8 = state.pos;
        $5 = 0;
      }
      while (true) {
        if ($5 == 0) {
          String? $7;
          // Field
          // Field
          if ($12 & 0x8 == 0) {
            $12 |= 0x8;
            beginEvent(CsvParserEvent.fieldEvent);
          }
          // String / Text
          if ($12 & 0x4 == 0) {
            $12 |= 0x4;
            $9 = 0;
          }
          if ($9 == 0) {
            // String
            // String
            if ($12 & 0x1 == 0) {
              $12 |= 0x1;
              $10 = parseString$Async(state);
              final $11 = $10!;
              if (!$11.isComplete) {
                $11.onComplete = $1;
                return;
              }
            }
            $7 = $10!.value;
            $12 &= ~0x1 & 0xffff;
            $9 = state.ok ? -1 : 1;
          }
          if ($9 == 1) {
            // Text
            // Text
            if ($12 & 0x2 == 0) {
              $12 |= 0x2;
              $13 = parseText$Async(state);
              final $14 = $13!;
              if (!$14.isComplete) {
                $14.onComplete = $1;
                return;
              }
            }
            $7 = $13!.value;
            $12 &= ~0x2 & 0xffff;
            $9 = -1;
          }
          $12 &= ~0x4 & 0xffff;
          $7 = endEvent<String>(CsvParserEvent.fieldEvent, $7, state.ok);
          $12 &= ~0x8 & 0xffff;
          if (!state.ok) {
            state.pos = $8!;
            state.input.endBuffering(state.pos);
            $7 = null;
            break;
          }
          $6!.add($7!);
          $7 = null;
          state.input.endBuffering(state.pos);
          $5 = 1;
        }
        if ($5 == 1) {
          if ($4 == null) {
            $4 = true;
            state.input.beginBuffering();
            $8 = state.pos;
          }
          // ','
          // ','
          $16 ??= state.input.beginBuffering();
          final $15 = state.input;
          if (state.pos + 1 < $15.end || $15.isClosed) {
            matchLiteral1Async(state, 44, ',', const ErrorExpectedTags([',']));
          } else {
            $15.sleep = true;
            $15.handle = $1;
            return;
          }
          state.input.endBuffering(state.pos);
          $16 = null;
          $4 = null;
          if (!state.ok) {
            state.input.endBuffering(state.pos);
            break;
          }
          $5 = 0;
        }
      }
      state.ok = true;
      if (state.ok) {
        $2 = $6;
        $6 = null;
      }
      $4 = null;
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
  ///   v:@sepBy(Row, RowEnding) Eol?
  ///   ;
  List<List<String>>? parseRows(State<String> state) {
    List<List<String>>? $0;
    // v:@sepBy(Row, RowEnding) Eol?
    final $1 = state.pos;
    List<List<String>>? $2;
    final $3 = <List<String>>[];
    var $5 = state.pos;
    while (true) {
      List<String>? $4;
      // Row
      // Row
      $4 = parseRow(state);
      if (!state.ok) {
        state.pos = $5;
        break;
      }
      $3.add($4!);
      $5 = state.pos;
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
        final $15 = state.input;
        if (state.pos < $15.length) {
          final $14 = $15.runeAt(state.pos);
          state.pos += $14 > 0xffff ? 2 : 1;
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
        break;
      }
    }
    state.ok = true;
    if (state.ok) {
      $2 = $3;
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
    List<List<String>>? $2;
    int? $4;
    int? $5;
    List<List<String>>? $3;
    Object? $6;
    Object? $7;
    int? $8;
    List<List<String>>? $9;
    int? $11;
    AsyncResult<List<String>>? $12;
    int $14 = 0;
    int? $15;
    int? $16;
    AsyncResult<Object?>? $17;
    int? $19;
    int? $20;
    AsyncResult<Object?>? $22;
    Object? $24;
    void $1() {
      // v:@sepBy(Row, RowEnding) Eol?
      if ($14 & 0x40 == 0) {
        $14 |= 0x40;
        $4 = 0;
        $5 = state.pos;
      }
      if ($4 == 0) {
        // @sepBy(Row, RowEnding)
        if ($6 == null) {
          $6 = true;
          state.input.beginBuffering();
          $9 = [];
          $11 = state.pos;
          $8 = 0;
        }
        while (true) {
          if ($8 == 0) {
            List<String>? $10;
            // Row
            // Row
            if ($14 & 0x1 == 0) {
              $14 |= 0x1;
              $12 = parseRow$Async(state);
              final $13 = $12!;
              if (!$13.isComplete) {
                $13.onComplete = $1;
                return;
              }
            }
            $10 = $12!.value;
            $14 &= ~0x1 & 0xffff;
            if (!state.ok) {
              state.pos = $11!;
              state.input.endBuffering(state.pos);
              $10 = null;
              break;
            }
            $9!.add($10!);
            $10 = null;
            state.input.endBuffering(state.pos);
            $8 = 1;
          }
          if ($8 == 1) {
            if ($7 == null) {
              $7 = true;
              state.input.beginBuffering();
              $11 = state.pos;
            }
            // RowEnding
            // RowEnding
            // Eol !Eof
            // Eol !Eof
            if ($14 & 0x10 == 0) {
              $14 |= 0x10;
              $15 = 0;
              $16 = state.pos;
            }
            if ($15 == 0) {
              // Eol
              if ($14 & 0x2 == 0) {
                $14 |= 0x2;
                $17 = fastParseEol$Async(state);
                final $18 = $17!;
                if (!$18.isComplete) {
                  $18.onComplete = $1;
                  return;
                }
              }
              $14 &= ~0x2 & 0xffff;
              $15 = state.ok ? 1 : -1;
            }
            if ($15 == 1) {
              // !Eof
              if ($14 & 0x8 == 0) {
                $14 |= 0x8;
                state.input.beginBuffering();
                $19 = state.pos;
              }
              // Eof
              // !.
              // !.
              // !.
              if ($14 & 0x4 == 0) {
                $14 |= 0x4;
                $20 = state.pos;
              }
              // .
              final $21 = state.input;
              if (state.pos < $21.end || $21.isClosed) {
                if (state.pos >= $21.start) {
                  state.ok = state.pos < $21.end;
                  if (state.ok) {
                    final c = $21.data.runeAt(state.pos - $21.start);
                    state.pos += c > 0xffff ? 2 : 1;
                  } else {
                    state.fail(const ErrorUnexpectedEndOfInput());
                  }
                } else {
                  state.fail(ErrorBacktracking(state.pos));
                }
              } else {
                $21.sleep = true;
                $21.handle = $1;
                return;
              }
              state.ok = !state.ok;
              if (!state.ok) {
                final length = $20! - state.pos;
                state.fail(switch (length) {
                  0 => const ErrorUnexpectedInput(0),
                  1 => const ErrorUnexpectedInput(1),
                  2 => const ErrorUnexpectedInput(2),
                  _ => ErrorUnexpectedInput(length)
                });
              }
              state.pos = $20!;
              $14 &= ~0x4 & 0xffff;
              state.ok = !state.ok;
              if (!state.ok) {
                final length = $19! - state.pos;
                state.fail(switch (length) {
                  0 => const ErrorUnexpectedInput(0),
                  1 => const ErrorUnexpectedInput(1),
                  2 => const ErrorUnexpectedInput(2),
                  _ => ErrorUnexpectedInput(length)
                });
              }
              state.pos = $19!;
              state.input.endBuffering(state.pos);
              $14 &= ~0x8 & 0xffff;
              $15 = -1;
            }
            if (!state.ok) {
              state.pos = $16!;
            }
            $14 &= ~0x10 & 0xffff;
            $7 = null;
            if (!state.ok) {
              state.input.endBuffering(state.pos);
              break;
            }
            $8 = 0;
          }
        }
        state.ok = true;
        if (state.ok) {
          $3 = $9;
          $9 = null;
        }
        $7 = null;
        $4 = state.ok ? 1 : -1;
      }
      if ($4 == 1) {
        // Eol?
        $24 ??= state.input.beginBuffering();
        // Eol
        if ($14 & 0x20 == 0) {
          $14 |= 0x20;
          $22 = fastParseEol$Async(state);
          final $23 = $22!;
          if (!$23.isComplete) {
            $23.onComplete = $1;
            return;
          }
        }
        $14 &= ~0x20 & 0xffff;
        if (!state.ok) {
          state.ok = true;
        }
        state.input.endBuffering(state.pos);
        $24 = null;
        $4 = -1;
      }
      if (state.ok) {
        $2 = $3;
      } else {
        state.pos = $5!;
      }
      $14 &= ~0x40 & 0xffff;
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
  ///   v:Rows Eof
  ///   ;
  List<List<String>>? parseStart(State<String> state) {
    beginEvent(CsvParserEvent.startEvent);
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
      final $7 = state.input;
      if (state.pos < $7.length) {
        final $6 = $7.runeAt(state.pos);
        state.pos += $6 > 0xffff ? 2 : 1;
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
    $0 = endEvent<List<List<String>>>(CsvParserEvent.startEvent, $0, state.ok);
    return $0;
  }

  /// @event
  /// Start =
  ///   v:Rows Eof
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
    int? $9;
    void $1() {
      // v:Rows Eof
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
        // Eof
        // !.
        // !.
        // !.
        if ($8 & 0x2 == 0) {
          $8 |= 0x2;
          state.input.beginBuffering();
          $9 = state.pos;
        }
        // .
        final $10 = state.input;
        if (state.pos < $10.end || $10.isClosed) {
          if (state.pos >= $10.start) {
            state.ok = state.pos < $10.end;
            if (state.ok) {
              final c = $10.data.runeAt(state.pos - $10.start);
              state.pos += c > 0xffff ? 2 : 1;
            } else {
              state.fail(const ErrorUnexpectedEndOfInput());
            }
          } else {
            state.fail(ErrorBacktracking(state.pos));
          }
        } else {
          $10.sleep = true;
          $10.handle = $1;
          return;
        }
        state.ok = !state.ok;
        if (!state.ok) {
          final length = $9! - state.pos;
          state.fail(switch (length) {
            0 => const ErrorUnexpectedInput(0),
            1 => const ErrorUnexpectedInput(1),
            2 => const ErrorUnexpectedInput(2),
            _ => ErrorUnexpectedInput(length)
          });
        }
        state.pos = $9!;
        state.input.endBuffering(state.pos);
        $8 &= ~0x2 & 0xffff;
        $4 = -1;
      }
      if (state.ok) {
        $2 = $3;
      } else {
        state.pos = $5!;
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
  ///   OpenQuote v:Chars CloseQuote {}
  ///   ;
  String? parseString(State<String> state) {
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
      state.ok = state.pos < state.input.length &&
          state.input.codeUnitAt(state.pos) == 34;
      if (state.ok) {
        state.pos++;
      } else {
        state.fail(const ErrorExpectedTags([$4]));
      }
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
        final $12 = state.pos;
        final $11 = state.input;
        while (state.pos < $11.length) {
          final $10 = $11.runeAt(state.pos);
          state.ok = $10 != 34;
          if (!state.ok) {
            break;
          }
          state.pos += $10 > 0xffff ? 2 : 1;
        }
        state.fail(const ErrorUnexpectedCharacter());
        state.ok = state.pos > $12;
        if (state.ok) {
          $7 = state.input.substring($9, state.pos);
        }
        if (!state.ok) {
          // '""' <String>{}
          const $14 = '""';
          state.ok = state.pos < state.input.length &&
              state.input.codeUnitAt(state.pos) == 34 &&
              state.input.startsWith($14, state.pos);
          if (state.ok) {
            state.pos += 2;
          } else {
            state.fail(const ErrorExpectedTags([$14]));
          }
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
        final $15 = state.pos;
        const $16 = '"';
        state.ok = state.pos < state.input.length &&
            state.input.codeUnitAt(state.pos) == 34;
        if (state.ok) {
          state.pos++;
        } else {
          state.fail(const ErrorExpectedTags([$16]));
        }
        if (state.ok) {
          // Spaces
          fastParseSpaces(state);
        }
        if (!state.ok) {
          state.pos = $15;
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
    String? $2;
    int? $4;
    int? $5;
    int? $6;
    int? $7;
    AsyncResult<Object?>? $8;
    int $10 = 0;
    Object? $12;
    List<String>? $3;
    List<String>? $13;
    String? $14;
    int? $15;
    int? $16;
    bool? $17;
    Object? $21;
    int? $22;
    int? $23;
    Object? $25;
    AsyncResult<Object?>? $26;
    void $1() {
      // OpenQuote v:Chars CloseQuote {}
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
          $12 ??= state.input.beginBuffering();
          final $11 = state.input;
          if (state.pos + 1 < $11.end || $11.isClosed) {
            matchLiteral1Async(state, 34, '"', const ErrorExpectedTags(['"']));
          } else {
            $11.sleep = true;
            $11.handle = $1;
            return;
          }
          state.input.endBuffering(state.pos);
          $12 = null;
          $6 = -1;
        }
        if (!state.ok) {
          state.pos = $7!;
        }
        $10 &= ~0x2 & 0xffff;
        $4 = state.ok ? 1 : -1;
      }
      if ($4 == 1) {
        // Chars
        // ($[^"]+ / '""' <String>{})*
        // ($[^"]+ / '""' <String>{})*
        // ($[^"]+ / '""' <String>{})*
        $13 ??= [];
        while (true) {
          $21 ??= state.input.beginBuffering();
          // ($[^"]+ / '""' <String>{})
          // $[^"]+ / '""' <String>{}
          if ($10 & 0x8 == 0) {
            $10 |= 0x8;
            $15 = 0;
          }
          if ($15 == 0) {
            // $[^"]+
            // $[^"]+
            if ($10 & 0x4 == 0) {
              $10 |= 0x4;
              $16 = state.pos;
            }
            // [^"]+
            $17 ??= false;
            while (true) {
              // [^"]
              final $19 = state.input;
              final $18 = readChar32Async(state);
              switch ($18) {
                case null:
                  $19.sleep = true;
                  $19.handle = $1;
                  return;
                case >= 0:
                  state.ok = $18 != 34;
                  if (state.ok) {
                    state.pos += $18 > 0xffff ? 2 : 1;
                  } else {
                    state.fail(const ErrorUnexpectedCharacter());
                  }
              }
              if (!state.ok) {
                break;
              }
              $17 = true;
            }
            state.ok = $17!;
            $17 = null;
            if (state.ok) {
              final input = state.input;
              final start = input.start;
              $14 = input.data.substring($16! - start, state.pos - start);
            }
            $10 &= ~0x4 & 0xffff;
            $15 = state.ok ? -1 : 1;
          }
          if ($15 == 1) {
            // '""' <String>{}
            // '""'
            final $20 = state.input;
            if (state.pos + 1 < $20.end || $20.isClosed) {
              const string = '""';
              matchLiteralAsync(
                  state, string, const ErrorExpectedTags([string]));
            } else {
              $20.sleep = true;
              $20.handle = $1;
              return;
            }
            if (state.ok) {
              String? $$;
              $$ = '"';
              $14 = $$;
            }
            $15 = -1;
          }
          $10 &= ~0x8 & 0xffff;
          state.input.endBuffering(state.pos);
          $21 = null;
          if (!state.ok) {
            $14 = null;
            break;
          }
          $13!.add($14!);
          $14 = null;
        }
        state.ok = true;
        if (state.ok) {
          $3 = $13;
        }
        $13 = null;
        $13 = null;
        $4 = state.ok ? 2 : -1;
      }
      if ($4 == 2) {
        // CloseQuote
        // '"' Spaces
        // '"' Spaces
        if ($10 & 0x20 == 0) {
          $10 |= 0x20;
          $22 = 0;
          $23 = state.pos;
        }
        if ($22 == 0) {
          // '"'
          $25 ??= state.input.beginBuffering();
          final $24 = state.input;
          if (state.pos + 1 < $24.end || $24.isClosed) {
            matchLiteral1Async(state, 34, '"', const ErrorExpectedTags(['"']));
          } else {
            $24.sleep = true;
            $24.handle = $1;
            return;
          }
          state.input.endBuffering(state.pos);
          $25 = null;
          $22 = state.ok ? 1 : -1;
        }
        if ($22 == 1) {
          // Spaces
          if ($10 & 0x10 == 0) {
            $10 |= 0x10;
            $26 = fastParseSpaces$Async(state);
            final $27 = $26!;
            if (!$27.isComplete) {
              $27.onComplete = $1;
              return;
            }
          }
          $10 &= ~0x10 & 0xffff;
          $22 = -1;
        }
        if (!state.ok) {
          state.pos = $23!;
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
        state.pos = $5!;
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
    final $4 = state.input;
    while (state.pos < $4.length) {
      final $3 = $4.runeAt(state.pos);
      state.ok = !($3 == 13 || $3 == 10 || $3 == 34 || $3 == 44);
      if (!state.ok) {
        break;
      }
      state.pos += $3 > 0xffff ? 2 : 1;
    }
    state.fail(const ErrorUnexpectedCharacter());
    state.ok = true;
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
        final $4 = readChar32Async(state);
        switch ($4) {
          case null:
            $5.sleep = true;
            $5.handle = $1;
            return;
          case >= 0:
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
      state.ok = true;
      if (state.ok) {
        final input = state.input;
        final start = input.start;
        $2 = input.data.substring($3! - start, state.pos - start);
      }
      state.input.endBuffering(state.pos);
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
  int? matchChar(State<String> state, int char, ParseError error) {
    final input = state.input;
    state.ok = state.pos < input.length && input.runeAt(state.pos) == char;
    if (state.ok) {
      state.pos += char > 0xffff ? 2 : 1;
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
  String? matchLiteral(State<String> state, String string, ParseError error) {
    final input = state.input;
    state.ok = input.startsWith(string, state.pos);
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
  String? matchLiteral1(
      State<String> state, int char, String string, ParseError error) {
    final input = state.input;
    state.ok = state.pos < input.length && input.runeAt(state.pos) == char;
    if (state.ok) {
      state.pos += char > 0xffff ? 2 : 1;
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

  @pragma('vm:prefer-inline')
  @pragma('dart2js:tryInline')
  int? readChar16Async(State<ChunkedParsingSink> state) {
    final input = state.input;
    if (state.pos < input.end || input.isClosed) {
      state.ok = state.pos < input.end;
      if (state.pos >= input.start) {
        if (state.ok) {
          return input.data.codeUnitAt(state.pos - input.start);
        } else {
          state.fail(const ErrorUnexpectedEndOfInput());
        }
      } else {
        state.fail(ErrorBacktracking(state.pos));
      }
      return -1;
    }
    return null;
  }

  @pragma('vm:prefer-inline')
  @pragma('dart2js:tryInline')
  int? readChar32Async(State<ChunkedParsingSink> state) {
    final input = state.input;
    if (state.pos < input.end || input.isClosed) {
      state.ok = state.pos < input.end;
      if (state.pos >= input.start) {
        if (state.ok) {
          return input.data.runeAt(state.pos - input.start);
        } else {
          state.fail(const ErrorUnexpectedEndOfInput());
        }
      } else {
        state.fail(ErrorBacktracking(state.pos));
      }
      return -1;
    }
    return null;
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
    final source = _StringWrapper(
      invalidChar: 32,
      leftPadding: 0,
      rightPadding: 0,
      source: input,
    );
    message = _errorMessage(source, offset, normalized);
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
      key = (ErrorBacktracking, error.length);
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
      if (input is String) {
        if (offset < input.length) {
          char = input.runeAt(offset);
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
